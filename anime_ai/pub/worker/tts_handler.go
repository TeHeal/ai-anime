// Package worker 实现 TTS 语音合成任务的真实 Handler。
package worker

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider_usage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/realtime"
	"github.com/TeHeal/ai-anime/anime_ai/pub/storage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// TTSTaskPayload TTS 任务载荷
type TTSTaskPayload struct {
	TaskID    string `json:"task_id"`
	Text      string `json:"text"`
	VoiceID   string `json:"voice_id"`
	ProjectID string `json:"project_id"`
	UserID    string `json:"user_id"`
	ShotID    string `json:"shot_id"`
	Provider  string `json:"provider"`
	Model     string `json:"model"`
	Emotion   string `json:"emotion,omitempty"`
}

// TTSRouter TTS 路由接口，用于依赖注入
type TTSRouter interface {
	Submit(ctx context.Context, req capability.TTSRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*capability.TTSResult, error)
}

// TTSTaskDeps TTS 任务 Handler 依赖
type TTSTaskDeps struct {
	TTSRouter     TTSRouter
	Storage       storage.Storage
	RealtimeHub   *realtime.Hub
	TaskNotifier  TaskNotifier
	UsageRecorder provider_usage.Recorder
}

// TTSTaskHandler TTS 任务 Handler
type TTSTaskHandler struct {
	log  *zap.Logger
	deps TTSTaskDeps
}

// NewTTSTaskHandler 创建 TTS 任务 Handler
func NewTTSTaskHandler(log *zap.Logger, deps TTSTaskDeps) *TTSTaskHandler {
	return &TTSTaskHandler{
		log:  log.Named("tts_worker"),
		deps: deps,
	}
}

// Handle 处理 TTS 任务
func (h *TTSTaskHandler) Handle(ctx context.Context, t *asynq.Task) error {
	var payload TTSTaskPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("解析 payload: %w", err)
	}

	h.log.Info("处理 TTS 任务",
		zap.String("task_id", payload.TaskID),
		zap.String("voice_id", payload.VoiceID),
		zap.String("provider", payload.Provider),
	)

	h.broadcastProgress(payload, 10, "running")

	// 提交到 TTSRouter
	providerName, providerTaskID, err := h.deps.TTSRouter.Submit(ctx, capability.TTSRequest{
		Text:    payload.Text,
		VoiceID: payload.VoiceID,
		Model:   payload.Model,
		Emotion: payload.Emotion,
	}, payload.Provider)
	if err != nil {
		h.failTTS(payload, "TTS 供应商不可用: "+err.Error())
		return nil
	}

	h.broadcastProgress(payload, 30, "running")

	// 轮询直到完成
	result, err := PollUntilDone(ctx, h.log, payload.TaskID, PollConfig{
		MaxAttempts:  60,
		Interval:     3 * time.Second,
		BaseProgress: 30,
		Label:        "tts",
	}, func(ctx context.Context) (*PollResult, error) {
		res, err := h.deps.TTSRouter.Query(ctx, providerTaskID)
		if err != nil {
			return nil, err
		}
		pr := &PollResult{Status: res.Status, Error: res.Error}
		if res.AudioURL != "" {
			pr.ResultURL = res.AudioURL
		}
		return pr, nil
	}, func(progress int, status string) {
		h.broadcastProgress(payload, progress, status)
	})

	if err != nil {
		h.failTTS(payload, err.Error())
		if ctx.Err() != nil {
			return ctx.Err()
		}
		return nil
	}

	if result.Status == "failed" {
		h.failTTS(payload, result.Error)
		return nil
	}

	remoteURL := result.ResultURL
	localURL := remoteURL

	// 下载到本地存储
	if remoteURL != "" && h.deps.Storage != nil {
		if downloaded, err := DownloadToLocal(ctx, h.log, h.deps.Storage, remoteURL, payload.TaskID, "resource/audio", ".mp3"); err != nil {
			h.log.Warn("下载 TTS 音频到本地失败，使用远程 URL",
				zap.String("task_id", payload.TaskID),
				zap.Error(err))
		} else {
			localURL = downloaded
		}
	}

	h.broadcastProgress(payload, 100, "completed")

	// 任务完成写入站内通知（README 2.6）
	if h.deps.TaskNotifier != nil {
		h.deps.TaskNotifier.NotifyTaskComplete(ctx, payload.UserID, "tts", payload.TaskID,
			"语音合成完成",
			"TTS 任务已完成，可前往项目查看",
			"/projects/"+payload.ProjectID+"/shots")
	}

	// AI 用量记录（README 8.3）
	if h.deps.UsageRecorder != nil && payload.ProjectID != "" {
		h.deps.UsageRecorder.RecordChat(ctx, payload.ProjectID, payload.UserID,
			providerName, payload.Model, len(payload.Text))
	}

	h.log.Info("TTS 任务完成",
		zap.String("task_id", payload.TaskID),
		zap.String("local_url", localURL),
	)
	return nil
}

func (h *TTSTaskHandler) broadcastProgress(payload TTSTaskPayload, progress int, status string) {
	if h.deps.RealtimeHub == nil {
		return
	}
	var projectID *string
	if payload.ProjectID != "" {
		projectID = &payload.ProjectID
	}
	data := map[string]interface{}{
		"taskId":   payload.TaskID,
		"type":     "tts",
		"progress": progress,
		"status":   status,
		"title":    "语音合成",
		"shot_id":  payload.ShotID,
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

func (h *TTSTaskHandler) failTTS(payload TTSTaskPayload, errMsg string) {
	h.log.Error("TTS 任务失败",
		zap.String("task_id", payload.TaskID),
		zap.String("error", errMsg),
	)
	h.broadcastProgress(payload, 0, "failed")
}

// RegisterTTSHandler 在 mux 中注册 TTS Handler
func RegisterTTSHandler(mux *asynq.ServeMux, h *TTSTaskHandler) {
	mux.HandleFunc(tasktypes.TypeTTS, h.Handle)
}
