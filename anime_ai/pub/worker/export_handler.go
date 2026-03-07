// Package worker 成片导出任务 Handler（README 成片阶段）
package worker

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"time"

	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg/ffmpeg"
	"anime_ai/pub/realtime"
	"anime_ai/pub/storage"
	"anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// ExportTaskPayload 成片导出任务载荷
type ExportTaskPayload struct {
	CompositeTaskID string `json:"composite_task_id"`
	ProjectID       string `json:"project_id"`
	EpisodeID       string `json:"episode_id"`
	UserID          string `json:"user_id"`
}

// ExportTaskDeps 成片导出 Handler 依赖
type ExportTaskDeps struct {
	CompositeUpdater crossmodule.CompositeExportUpdater
	ShotReader       crossmodule.ExportShotReader
	ShotVideoReader  crossmodule.ExportShotVideoReader
	Storage          storage.Storage
	Broadcaster      realtime.Broadcaster
	TaskNotifier     TaskNotifier
}

// ExportTaskHandler 成片导出任务 Handler
type ExportTaskHandler struct {
	log  *zap.Logger
	deps ExportTaskDeps
}

// NewExportTaskHandler 创建成片导出 Handler
func NewExportTaskHandler(log *zap.Logger, deps ExportTaskDeps) *ExportTaskHandler {
	return &ExportTaskHandler{
		log:  log.Named("export_worker"),
		deps: deps,
	}
}

// Handle 处理成片导出任务
func (h *ExportTaskHandler) Handle(ctx context.Context, t *asynq.Task) error {
	var payload ExportTaskPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("解析 payload: %w", err)
	}

	h.log.Info("处理成片导出任务",
		zap.String("composite_task_id", payload.CompositeTaskID),
		zap.String("episode_id", payload.EpisodeID),
	)

	if h.deps.CompositeUpdater == nil {
		h.log.Warn("CompositeUpdater 未配置，跳过")
		return nil
	}

	// 更新为导出中
	if err := h.deps.CompositeUpdater.UpdateStatus(ctx, payload.CompositeTaskID, crossmodule.CompositeStatusExporting, "", ""); err != nil {
		h.log.Warn("更新导出状态失败", zap.String("composite_task_id", payload.CompositeTaskID), zap.Error(err))
	}
	h.broadcastProgress(payload, 5, "exporting")

	tmpDir, err := os.MkdirTemp("", "export-*")
	if err != nil {
		h.fail(ctx, payload, "创建临时目录失败: "+err.Error())
		return nil
	}
	defer os.RemoveAll(tmpDir)

	// 查询项目所有镜头
	if h.deps.ShotReader == nil {
		h.fail(ctx, payload, "ShotReader 未配置")
		return nil
	}
	shots, err := h.deps.ShotReader.ListShotsByProject(ctx, payload.ProjectID)
	if err != nil {
		h.fail(ctx, payload, "查询镜头列表失败: "+err.Error())
		return nil
	}
	if len(shots) == 0 {
		h.fail(ctx, payload, "项目中没有镜头")
		return nil
	}

	// 按 sort_index 排序
	sort.Slice(shots, func(i, j int) bool { return shots[i].SortIndex < shots[j].SortIndex })
	h.broadcastProgress(payload, 10, "exporting")

	// 收集每个镜头的视频文件路径
	var videoPaths []string
	var subtitleItems []ffmpeg.SubtitleItem
	var cumulativeMs int64

	for i, shot := range shots {
		if ctx.Err() != nil {
			h.fail(ctx, payload, "任务被取消")
			return ctx.Err()
		}

		// 获取镜头视频
		var videoURL string
		if h.deps.ShotVideoReader != nil {
			videoInfo, err := h.deps.ShotVideoReader.GetLatestApprovedVideo(ctx, shot.ID)
			if err != nil {
				h.log.Warn("获取镜头视频失败，跳过",
					zap.String("shot_id", shot.ID), zap.Error(err))
				continue
			}
			if videoInfo != nil && videoInfo.VideoURL != "" {
				videoURL = videoInfo.VideoURL
			}
		}

		if videoURL == "" {
			h.log.Info("镜头无视频，跳过", zap.String("shot_id", shot.ID))
			continue
		}

		// 下载视频到临时目录
		localPath := filepath.Join(tmpDir, fmt.Sprintf("shot_%04d.mp4", i))
		if err := h.downloadFile(ctx, videoURL, localPath); err != nil {
			h.log.Warn("下载镜头视频失败，跳过",
				zap.String("shot_id", shot.ID),
				zap.String("url", videoURL),
				zap.Error(err))
			continue
		}
		videoPaths = append(videoPaths, localPath)

		// 获取视频时长
		durationSec := float64(shot.Duration)
		if durationSec <= 0 {
			if d, err := ffmpeg.GetDuration(ctx, localPath); err == nil && d > 0 {
				durationSec = d
			} else {
				durationSec = 5.0
			}
		}
		durationMs := int64(durationSec * 1000)

		// 生成字幕条目
		if shot.Dialogue != "" {
			subtitleItems = append(subtitleItems, ffmpeg.SubtitleItem{
				Index:     len(subtitleItems) + 1,
				StartMs:   cumulativeMs,
				EndMs:     cumulativeMs + durationMs,
				Character: shot.CharacterName,
				Text:      shot.Dialogue,
			})
		}
		cumulativeMs += durationMs

		// 推送进度（10-60%）
		progress := 10 + (i+1)*50/len(shots)
		h.broadcastProgress(payload, progress, "exporting")
	}

	if len(videoPaths) == 0 {
		h.fail(ctx, payload, "没有可用的镜头视频")
		return nil
	}

	h.broadcastProgress(payload, 65, "exporting")

	// 拼接视频
	concatOutput := filepath.Join(tmpDir, "concat.mp4")
	if err := ffmpeg.ConcatVideos(ctx, videoPaths, concatOutput); err != nil {
		h.fail(ctx, payload, "拼接视频失败: "+err.Error())
		return nil
	}
	h.broadcastProgress(payload, 75, "exporting")

	// 烧录字幕（如果有台词）
	finalVideo := concatOutput
	if len(subtitleItems) > 0 {
		subtitlePath := filepath.Join(tmpDir, "subtitles.ass")
		if err := ffmpeg.GenerateASS(subtitleItems, subtitlePath); err != nil {
			h.log.Warn("生成字幕文件失败，跳过字幕", zap.Error(err))
		} else {
			subtitledOutput := filepath.Join(tmpDir, "subtitled.mp4")
			if err := ffmpeg.BurnSubtitles(ctx, concatOutput, subtitlePath, subtitledOutput); err != nil {
				h.log.Warn("烧录字幕失败，使用无字幕版本", zap.Error(err))
			} else {
				finalVideo = subtitledOutput
			}
		}
	}
	h.broadcastProgress(payload, 85, "exporting")

	// 上传到存储
	var outputURL string
	if h.deps.Storage != nil {
		storagePath := fmt.Sprintf("composite/%s/%s.mp4", payload.ProjectID, payload.CompositeTaskID)
		f, err := os.Open(finalVideo)
		if err != nil {
			h.fail(ctx, payload, "打开最终视频失败: "+err.Error())
			return nil
		}
		defer f.Close()

		url, err := h.deps.Storage.Put(ctx, storagePath, f, "video/mp4")
		if err != nil {
			h.fail(ctx, payload, "上传成片失败: "+err.Error())
			return nil
		}
		outputURL = url
	}
	h.broadcastProgress(payload, 95, "exporting")

	// 更新任务状态为完成
	if err := h.deps.CompositeUpdater.UpdateStatus(ctx, payload.CompositeTaskID, crossmodule.CompositeStatusDone, outputURL, ""); err != nil {
		h.log.Warn("更新导出完成状态失败", zap.String("composite_task_id", payload.CompositeTaskID), zap.Error(err))
	}

	h.broadcastComplete(payload, outputURL)

	if h.deps.TaskNotifier != nil {
		h.deps.TaskNotifier.NotifyTaskComplete(ctx, payload.UserID, "export", payload.CompositeTaskID,
			"成片导出完成",
			"成片导出已完成，可前往项目查看",
			"/projects/"+payload.ProjectID+"/composite")
	}

	h.log.Info("成片导出任务完成",
		zap.String("composite_task_id", payload.CompositeTaskID),
		zap.String("output_url", outputURL),
		zap.Int("shot_count", len(videoPaths)),
	)
	return nil
}

// downloadFile 下载远程文件到本地路径；若 URL 是本地路径则直接复制
func (h *ExportTaskHandler) downloadFile(ctx context.Context, url, localPath string) error {
	// 如果是本地存储路径（以 / 开头且不含 ://），尝试直接从 Storage 读取
	if h.deps.Storage != nil && !isHTTPURL(url) {
		rc, err := h.deps.Storage.Get(ctx, url)
		if err == nil {
			defer rc.Close()
			return writeToFile(rc, localPath)
		}
	}

	// HTTP 下载
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("创建 HTTP 请求: %w", err)
	}
	client := &http.Client{Timeout: 120 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("HTTP 下载: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("下载返回状态码 %d", resp.StatusCode)
	}
	return writeToFile(resp.Body, localPath)
}

func writeToFile(r io.Reader, path string) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = io.Copy(f, r)
	return err
}

func isHTTPURL(url string) bool {
	return len(url) > 7 && (url[:7] == "http://" || url[:8] == "https://")
}

func (h *ExportTaskHandler) fail(ctx context.Context, payload ExportTaskPayload, errMsg string) {
	h.log.Error("成片导出失败",
		zap.String("composite_task_id", payload.CompositeTaskID),
		zap.String("error", errMsg),
	)
	if err := h.deps.CompositeUpdater.UpdateStatus(ctx, payload.CompositeTaskID, crossmodule.CompositeStatusFailed, "", errMsg); err != nil {
		h.log.Warn("更新导出失败状态失败", zap.String("composite_task_id", payload.CompositeTaskID), zap.Error(err))
	}
	h.broadcastError(payload, errMsg)
}

func (h *ExportTaskHandler) broadcastProgress(payload ExportTaskPayload, progress int, status string) {
	if h.deps.Broadcaster == nil {
		return
	}
	var projectID *string
	if payload.ProjectID != "" {
		projectID = &payload.ProjectID
	}
	h.deps.Broadcaster.BroadcastTaskProgress(payload.UserID, projectID, payload.CompositeTaskID, map[string]interface{}{
		"taskId":   payload.CompositeTaskID,
		"type":     "export",
		"progress": progress,
		"status":   status,
		"title":    "成片导出",
	})
}

func (h *ExportTaskHandler) broadcastComplete(payload ExportTaskPayload, outputURL string) {
	if h.deps.Broadcaster == nil {
		return
	}
	var projectID *string
	if payload.ProjectID != "" {
		projectID = &payload.ProjectID
	}
	h.deps.Broadcaster.BroadcastTaskComplete(payload.UserID, projectID, payload.CompositeTaskID, map[string]interface{}{
		"taskId":    payload.CompositeTaskID,
		"type":      "export",
		"progress":  100,
		"status":    "done",
		"title":     "成片导出完成",
		"outputUrl": outputURL,
	})
}

func (h *ExportTaskHandler) broadcastError(payload ExportTaskPayload, errMsg string) {
	if h.deps.Broadcaster == nil {
		return
	}
	var projectID *string
	if payload.ProjectID != "" {
		projectID = &payload.ProjectID
	}
	h.deps.Broadcaster.BroadcastTaskError(payload.UserID, projectID, payload.CompositeTaskID, map[string]interface{}{
		"taskId":   payload.CompositeTaskID,
		"type":     "export",
		"progress": 0,
		"status":   "failed",
		"title":    "成片导出失败",
		"error":    errMsg,
	})
}

// RegisterExportHandler 注册成片导出 Handler
func RegisterExportHandler(mux *asynq.ServeMux, h *ExportTaskHandler) {
	mux.HandleFunc(tasktypes.TypeExport, h.Handle)
}
