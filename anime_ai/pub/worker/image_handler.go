// Package worker 实现镜图生成任务的真实 Handler。
package worker

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/module/shot_image"
	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider_usage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/realtime"
	"github.com/TeHeal/ai-anime/anime_ai/pub/storage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// ImageTaskPayload 镜图生成任务载荷，ID 使用 string（UUID）
type ImageTaskPayload struct {
	TaskID      string   `json:"task_id"`       // 任务追踪 ID，用于进度推送
	ShotImageID string   `json:"shot_image_id"` // 镜图 ID，完成后更新
	Provider    string   `json:"provider"`
	Model       string   `json:"model"`
	Prompt      string   `json:"prompt"`
	Width       int      `json:"width,omitempty"`
	Height      int      `json:"height,omitempty"`
	Count       int      `json:"count,omitempty"`
	ProjectID   string   `json:"project_id"`
	UserID      string   `json:"user_id"`
	NegativePrompt     string   `json:"negative_prompt,omitempty"`
	ReferenceImageURLs []string `json:"reference_image_urls,omitempty"`
	Size               string   `json:"size,omitempty"`
	Seed               int64    `json:"seed,omitempty"`
	AspectRatio        string   `json:"aspect_ratio,omitempty"`
}

// TaskNotifier 任务完成时写入站内通知（README 2.6）
type TaskNotifier interface {
	NotifyTaskComplete(ctx context.Context, userID string, taskType string, taskID string, title string, body string, linkURL string)
}

// ImageTaskDeps 镜图任务 Handler 依赖
type ImageTaskDeps struct {
	ImageRouter    ImageRouter
	Storage        storage.Storage
	ShotImageStore shot_image.ShotImageStore
	ShotLocker     crossmodule.ShotLocker // 可选，任务完成/失败时释放锁（README 2.3）
	RealtimeHub    *realtime.Hub
	TaskNotifier   TaskNotifier // 可选，任务完成时写入通知表
	UsageRecorder  provider_usage.Recorder // 可选，AI 用量记录（README 8.3）
}

// ImageRouter 文生图路由接口，用于依赖注入
type ImageRouter interface {
	Submit(ctx context.Context, req capability.ImageRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*capability.ImageResult, error)
}

// ImageTaskHandler 镜图生成任务 Handler
type ImageTaskHandler struct {
	log  *zap.Logger
	deps ImageTaskDeps
}

// NewImageTaskHandler 创建镜图任务 Handler
func NewImageTaskHandler(log *zap.Logger, deps ImageTaskDeps) *ImageTaskHandler {
	return &ImageTaskHandler{
		log:  log.Named("image_worker"),
		deps: deps,
	}
}

// Handle 处理镜图生成任务
func (h *ImageTaskHandler) Handle(ctx context.Context, t *asynq.Task) error {
	var payload ImageTaskPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("解析 payload: %w", err)
	}

	h.log.Info("处理镜图任务",
		zap.String("task_id", payload.TaskID),
		zap.String("shot_image_id", payload.ShotImageID),
		zap.String("provider", payload.Provider),
		zap.String("model", payload.Model),
	)

	// 推送初始进度
	h.broadcastProgress(payload, 10, "running")

	// 提交到 ImageRouter
	providerName, providerTaskID, err := h.deps.ImageRouter.Submit(ctx, capability.ImageRequest{
		Prompt:             payload.Prompt,
		NegativePrompt:     payload.NegativePrompt,
		Model:              payload.Model,
		Width:              payload.Width,
		Height:             payload.Height,
		Count:              payload.Count,
		ReferenceImageURLs: payload.ReferenceImageURLs,
		Size:               payload.Size,
		Seed:               payload.Seed,
		AspectRatio:        payload.AspectRatio,
	}, payload.Provider)
	if err != nil {
		h.failShotImage(payload, "供应商不可用: "+err.Error())
		return nil
	}

	h.broadcastProgress(payload, 30, "running")

	// 轮询直到完成
	result, err := PollUntilDone(ctx, h.log, payload.TaskID, PollConfig{
		MaxAttempts:  60,
		Interval:     3 * time.Second,
		BaseProgress: 30,
		Label:        "image",
	}, func(ctx context.Context) (*PollResult, error) {
		res, err := h.deps.ImageRouter.Query(ctx, providerTaskID)
		if err != nil {
			return nil, err
		}
		pr := &PollResult{Status: res.Status, Error: res.Error}
		if len(res.URLs) > 0 {
			pr.ResultURL = res.URLs[0]
		}
		pr.Extra = map[string]interface{}{"urls": res.URLs}
		return pr, nil
	}, func(progress int, status string) {
		h.broadcastProgress(payload, progress, status)
	})

	if err != nil {
		h.failShotImage(payload, err.Error())
		if ctx.Err() != nil {
			return ctx.Err()
		}
		return nil
	}

	if result.Status == "failed" {
		h.failShotImage(payload, result.Error)
		return nil
	}

	remoteURL := result.ResultURL
	localURL := remoteURL

	if remoteURL != "" && h.deps.Storage != nil {
		if downloaded, err := DownloadToLocal(ctx, h.log, h.deps.Storage, remoteURL, payload.TaskID, "resource/generated", ".png"); err != nil {
			h.log.Warn("下载生成图到本地失败，使用远程 URL",
				zap.String("task_id", payload.TaskID),
				zap.Error(err))
		} else {
			localURL = downloaded
		}
	}

	// 更新镜图状态
	if err := h.updateShotImageComplete(payload, localURL); err != nil {
		h.log.Error("更新镜图状态失败", zap.String("shot_image_id", payload.ShotImageID), zap.Error(err))
	}

	h.broadcastProgress(payload, 100, "completed")

	// 任务完成写入站内通知（README 2.6）
	if h.deps.TaskNotifier != nil {
		h.deps.TaskNotifier.NotifyTaskComplete(ctx, payload.UserID, "image", payload.TaskID,
			"镜图生成完成",
			"镜图任务已完成，可前往项目查看",
			"/projects/"+payload.ProjectID+"/shot-images")
	}

	// AI 用量记录（README 8.3）
	if h.deps.UsageRecorder != nil && payload.ProjectID != "" {
		imgCount := payload.Count
		if imgCount <= 0 {
			imgCount = 1
		}
		h.deps.UsageRecorder.RecordImage(ctx, payload.ProjectID, payload.UserID,
			providerName, payload.Model, imgCount)
	}

	h.log.Info("镜图任务完成",
		zap.String("task_id", payload.TaskID),
		zap.String("shot_image_id", payload.ShotImageID),
		zap.String("local_url", localURL),
	)
	return nil
}

func (h *ImageTaskHandler) broadcastProgress(payload ImageTaskPayload, progress int, status string) {
	if h.deps.RealtimeHub == nil {
		return
	}
	var projectID *string
	if payload.ProjectID != "" {
		projectID = &payload.ProjectID
	}
	h.deps.RealtimeHub.BroadcastTaskProgress(payload.UserID, projectID, payload.TaskID, map[string]interface{}{
		"progress": progress,
		"status":   status,
		"shot_image_id": payload.ShotImageID,
	})
}

func (h *ImageTaskHandler) failShotImage(payload ImageTaskPayload, errMsg string) {
	h.log.Error("镜图任务失败",
		zap.String("task_id", payload.TaskID),
		zap.String("shot_image_id", payload.ShotImageID),
		zap.String("error", errMsg),
	)
	if h.deps.ShotImageStore != nil {
		img, err := h.deps.ShotImageStore.FindByID(payload.ShotImageID)
		if err != nil {
			h.log.Warn("查找镜图失败", zap.String("shot_image_id", payload.ShotImageID), zap.Error(err))
		} else {
			img.ImageURL = ""
			img.TaskID = ""
			img.Status = "failed"
			_ = h.deps.ShotImageStore.Update(img)
			h.releaseShotLock(img.ShotID, payload.UserID)
		}
	}
	h.broadcastProgress(payload, 0, "failed")
}

func (h *ImageTaskHandler) updateShotImageComplete(payload ImageTaskPayload, localURL string) error {
	if h.deps.ShotImageStore == nil {
		return nil
	}
	img, err := h.deps.ShotImageStore.FindByID(payload.ShotImageID)
	if err != nil {
		return fmt.Errorf("查找镜图: %w", err)
	}
	img.ImageURL = localURL
	img.TaskID = payload.TaskID
	img.Status = "completed"
	if err := h.deps.ShotImageStore.Update(img); err != nil {
		return err
	}
	h.releaseShotLock(img.ShotID, payload.UserID)
	return nil
}

func (h *ImageTaskHandler) releaseShotLock(shotID, userID string) {
	if h.deps.ShotLocker != nil && shotID != "" && userID != "" {
		if err := h.deps.ShotLocker.UnlockShot(shotID, userID); err != nil {
			h.log.Warn("释放镜头锁失败", zap.String("shot_id", shotID), zap.Error(err))
		}
	}
}

// RegisterImageHandler 在 mux 中注册镜图 Handler
func RegisterImageHandler(mux *asynq.ServeMux, h *ImageTaskHandler) {
	mux.HandleFunc(tasktypes.TypeImageGeneration, h.Handle)
}
