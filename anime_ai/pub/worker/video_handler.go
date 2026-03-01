// Package worker 实现镜头视频生成任务的真实 Handler。
package worker

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider_usage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/realtime"
	"github.com/TeHeal/ai-anime/anime_ai/pub/storage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// VideoTaskPayload 镜头视频生成任务载荷，ID 使用 string（UUID）
type VideoTaskPayload struct {
	TaskID      string `json:"task_id"`        // 任务追踪 ID，用于进度推送
	ShotVideoID string `json:"shot_video_id"`  // 镜头视频 ID，完成后更新
	ShotID      string `json:"shot_id"`        // 镜头 ID，完成后释放锁
	Provider    string `json:"provider"`
	Model       string `json:"model"`
	Prompt      string `json:"prompt"`
	ImageURL    string `json:"image_url,omitempty"` // 参考图片 URL（图生视频）
	Duration    int    `json:"duration,omitempty"`
	ProjectID   string `json:"project_id"`
	UserID      string `json:"user_id"`
}

// VideoRouter 文生视频路由接口，用于依赖注入
type VideoRouter interface {
	Submit(ctx context.Context, req capability.VideoRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*capability.VideoResult, error)
}

// ShotVideoUpdater 镜头视频状态更新接口（供 Worker 使用），shot_video.Store 已满足
type ShotVideoUpdater interface {
	UpdateStatus(ctx context.Context, id, status, videoURL, taskID string) error
}

// VideoTaskDeps 镜头视频任务 Handler 依赖
type VideoTaskDeps struct {
	VideoRouter      VideoRouter
	Storage          storage.Storage
	ShotVideoUpdater ShotVideoUpdater            // 镜头视频状态更新
	ShotLocker       crossmodule.ShotLocker      // 可选，任务完成/失败时释放锁（README 2.3）
	RealtimeHub      *realtime.Hub
	TaskNotifier     TaskNotifier                // 可选，任务完成时写入通知表
	UsageRecorder    provider_usage.Recorder     // 可选，AI 用量记录（README 8.3）
}

// VideoTaskHandler 镜头视频生成任务 Handler
type VideoTaskHandler struct {
	log  *zap.Logger
	deps VideoTaskDeps
}

// NewVideoTaskHandler 创建镜头视频任务 Handler
func NewVideoTaskHandler(log *zap.Logger, deps VideoTaskDeps) *VideoTaskHandler {
	return &VideoTaskHandler{
		log:  log.Named("video_worker"),
		deps: deps,
	}
}

// Handle 处理镜头视频生成任务
func (h *VideoTaskHandler) Handle(ctx context.Context, t *asynq.Task) error {
	var payload VideoTaskPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("解析 payload: %w", err)
	}

	h.log.Info("处理镜头视频任务",
		zap.String("task_id", payload.TaskID),
		zap.String("shot_video_id", payload.ShotVideoID),
		zap.String("provider", payload.Provider),
		zap.String("model", payload.Model),
	)

	h.broadcastProgress(payload, 10, "running")

	// 提交到 VideoRouter
	providerName, providerTaskID, err := h.deps.VideoRouter.Submit(ctx, capability.VideoRequest{
		ImageURL: payload.ImageURL,
		Prompt:   payload.Prompt,
		Model:    payload.Model,
		Duration: payload.Duration,
	}, payload.Provider)
	if err != nil {
		h.failShotVideo(ctx, payload, "供应商不可用: "+err.Error())
		return nil
	}

	h.broadcastProgress(payload, 30, "running")

	// 轮询直到完成（视频生成时间较长，增大轮询次数与间隔）
	result, err := PollUntilDone(ctx, h.log, payload.TaskID, PollConfig{
		MaxAttempts:  120,
		Interval:     5 * time.Second,
		BaseProgress: 30,
		Label:        "video",
	}, func(ctx context.Context) (*PollResult, error) {
		res, err := h.deps.VideoRouter.Query(ctx, providerTaskID)
		if err != nil {
			return nil, err
		}
		pr := &PollResult{Status: res.Status, Error: res.Error}
		if res.VideoURL != "" {
			pr.ResultURL = res.VideoURL
		}
		return pr, nil
	}, func(progress int, status string) {
		h.broadcastProgress(payload, progress, status)
	})

	if err != nil {
		h.failShotVideo(ctx, payload, err.Error())
		if ctx.Err() != nil {
			return ctx.Err()
		}
		return nil
	}

	if result.Status == "failed" {
		h.failShotVideo(ctx, payload, result.Error)
		return nil
	}

	remoteURL := result.ResultURL
	localURL := remoteURL

	if remoteURL != "" && h.deps.Storage != nil {
		if downloaded, err := DownloadToLocal(ctx, h.log, h.deps.Storage, remoteURL, payload.TaskID, "resource/generated", ".mp4"); err != nil {
			h.log.Warn("下载生成视频到本地失败，使用远程 URL",
				zap.String("task_id", payload.TaskID),
				zap.Error(err))
		} else {
			localURL = downloaded
		}
	}

	// 更新镜头视频状态
	if h.deps.ShotVideoUpdater != nil {
		if err := h.deps.ShotVideoUpdater.UpdateStatus(ctx, payload.ShotVideoID, "completed", localURL, payload.TaskID); err != nil {
			h.log.Error("更新镜头视频状态失败", zap.String("shot_video_id", payload.ShotVideoID), zap.Error(err))
		}
	}

	// 释放镜头锁（README 2.3）
	h.releaseShotLock(payload.ShotID, payload.UserID)

	h.broadcastProgress(payload, 100, "completed")

	// 任务完成写入站内通知（README 2.6）
	if h.deps.TaskNotifier != nil {
		h.deps.TaskNotifier.NotifyTaskComplete(ctx, payload.UserID, "video", payload.TaskID,
			"镜头视频生成完成",
			"镜头视频任务已完成，可前往项目查看",
			"/projects/"+payload.ProjectID+"/shot-videos")
	}

	// AI 用量记录（README 8.3）
	if h.deps.UsageRecorder != nil && payload.ProjectID != "" {
		dur := payload.Duration
		if dur <= 0 {
			dur = 5
		}
		h.deps.UsageRecorder.RecordVideo(ctx, payload.ProjectID, payload.UserID,
			providerName, payload.Model, dur)
	}

	h.log.Info("镜头视频任务完成",
		zap.String("task_id", payload.TaskID),
		zap.String("shot_video_id", payload.ShotVideoID),
		zap.String("local_url", localURL),
	)
	return nil
}

func (h *VideoTaskHandler) broadcastProgress(payload VideoTaskPayload, progress int, status string) {
	if h.deps.RealtimeHub == nil {
		return
	}
	var projectID *string
	if payload.ProjectID != "" {
		projectID = &payload.ProjectID
	}
	data := map[string]interface{}{
		"taskId":        payload.TaskID,
		"type":          "video",
		"progress":      progress,
		"status":        status,
		"title":         "镜头视频生成",
		"shot_video_id": payload.ShotVideoID,
	}
	switch {
	case progress >= 100 && status == "completed":
		h.deps.RealtimeHub.BroadcastTaskComplete(payload.UserID, projectID, payload.TaskID, data)
	case status == "failed":
		h.deps.RealtimeHub.BroadcastTaskError(payload.UserID, projectID, payload.TaskID, data)
	default:
		h.deps.RealtimeHub.BroadcastTaskProgress(payload.UserID, projectID, payload.TaskID, data)
	}
}

func (h *VideoTaskHandler) failShotVideo(ctx context.Context, payload VideoTaskPayload, errMsg string) {
	h.log.Error("镜头视频任务失败",
		zap.String("task_id", payload.TaskID),
		zap.String("shot_video_id", payload.ShotVideoID),
		zap.String("error", errMsg),
	)
	if h.deps.ShotVideoUpdater != nil {
		if err := h.deps.ShotVideoUpdater.UpdateStatus(ctx, payload.ShotVideoID, "failed", "", ""); err != nil {
			h.log.Warn("更新镜头视频失败状态异常", zap.String("shot_video_id", payload.ShotVideoID), zap.Error(err))
		}
	}
	h.releaseShotLock(payload.ShotID, payload.UserID)
	h.broadcastProgress(payload, 0, "failed")
}

func (h *VideoTaskHandler) releaseShotLock(shotID, userID string) {
	if h.deps.ShotLocker != nil && shotID != "" && userID != "" {
		if err := h.deps.ShotLocker.UnlockShot(shotID, userID); err != nil {
			h.log.Warn("释放镜头锁失败", zap.String("shot_id", shotID), zap.Error(err))
		}
	}
}

// RegisterVideoHandler 在 mux 中注册镜头视频 Handler
func RegisterVideoHandler(mux *asynq.ServeMux, h *VideoTaskHandler) {
	mux.HandleFunc(tasktypes.TypeVideoGeneration, h.Handle)
}
