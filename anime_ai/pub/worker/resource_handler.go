// Package worker 实现素材库资源生成任务的 Handler（音色设计/克隆、图生、提示词）。
package worker

import (
	"context"
	"encoding/json"
	"fmt"

	"anime_ai/module/assets/resource"
	"anime_ai/pub/realtime"
	"anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// ResourceGenPayload 素材库资源生成任务载荷
type ResourceGenPayload struct {
	TaskID     string `json:"task_id"`
	ResourceID string `json:"resource_id"`
	UserID     string `json:"user_id"`
	GenType    string `json:"gen_type"` // voice_design / voice_clone / image / text
	Title      string `json:"title"`
	// 各类型的请求参数，JSON 编码
	RequestJSON json.RawMessage `json:"request_json"`
}

// ResourceTaskRecorder 更新 Task DB 记录的接口
type ResourceTaskRecorder interface {
	RecordStart(ctx context.Context, id string) error
	RecordProgress(ctx context.Context, id string, progress int32) error
	RecordComplete(ctx context.Context, id string, result json.RawMessage) error
	RecordFailed(ctx context.Context, id string, errMsg string) error
}

// ResourceGenDeps 素材库生成 Handler 依赖
type ResourceGenDeps struct {
	ResourceSvc  *resource.Service
	Broadcaster  realtime.Broadcaster
	TaskNotifier TaskNotifier
	TaskRecorder ResourceTaskRecorder
}

// ResourceGenHandler 素材库资源异步生成 Handler
type ResourceGenHandler struct {
	log  *zap.Logger
	deps ResourceGenDeps
}

// NewResourceGenHandler 创建 Handler
func NewResourceGenHandler(log *zap.Logger, deps ResourceGenDeps) *ResourceGenHandler {
	return &ResourceGenHandler{
		log:  log.Named("resource_gen_worker"),
		deps: deps,
	}
}

// HandleVoiceDesign 处理音色设计任务
func (h *ResourceGenHandler) HandleVoiceDesign(ctx context.Context, t *asynq.Task) error {
	return h.handle(ctx, t, "voice_design")
}

// HandleVoiceClone 处理音色克隆任务
func (h *ResourceGenHandler) HandleVoiceClone(ctx context.Context, t *asynq.Task) error {
	return h.handle(ctx, t, "voice_clone")
}

// HandleImage 处理图片生成任务
func (h *ResourceGenHandler) HandleImage(ctx context.Context, t *asynq.Task) error {
	return h.handle(ctx, t, "image")
}

// HandleText 处理提示词生成任务
func (h *ResourceGenHandler) HandleText(ctx context.Context, t *asynq.Task) error {
	return h.handle(ctx, t, "text")
}

func (h *ResourceGenHandler) handle(ctx context.Context, t *asynq.Task, expectedType string) error {
	var payload ResourceGenPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("解析 payload: %w", err)
	}

	h.log.Info("处理素材生成任务",
		zap.String("task_id", payload.TaskID),
		zap.String("gen_type", payload.GenType),
		zap.String("resource_id", payload.ResourceID),
	)

	// 记录任务开始
	if h.deps.TaskRecorder != nil {
		_ = h.deps.TaskRecorder.RecordStart(ctx, payload.TaskID)
	}
	h.broadcastProgress(payload, 10, "running")

	var err error
	switch payload.GenType {
	case "voice_design":
		err = h.doVoiceDesign(ctx, payload)
	case "voice_clone":
		err = h.doVoiceClone(ctx, payload)
	case "image":
		err = h.doImage(ctx, payload)
	case "text":
		err = h.doText(ctx, payload)
	default:
		err = fmt.Errorf("未知的生成类型: %s", payload.GenType)
	}

	if err != nil {
		h.log.Error("素材生成任务失败",
			zap.String("task_id", payload.TaskID),
			zap.String("gen_type", payload.GenType),
			zap.Error(err),
		)
		_ = h.deps.ResourceSvc.MarkResourceGenFailed(ctx, payload.ResourceID, payload.UserID, err.Error())
		if h.deps.TaskRecorder != nil {
			_ = h.deps.TaskRecorder.RecordFailed(ctx, payload.TaskID, err.Error())
		}
		h.broadcastProgress(payload, 0, "failed")
		return nil
	}

	// 记录任务完成
	if h.deps.TaskRecorder != nil {
		resultJSON, _ := json.Marshal(map[string]string{"resourceId": payload.ResourceID})
		_ = h.deps.TaskRecorder.RecordComplete(ctx, payload.TaskID, resultJSON)
	}
	h.broadcastProgress(payload, 100, "completed")

	if h.deps.TaskNotifier != nil {
		h.deps.TaskNotifier.NotifyTaskComplete(ctx, payload.UserID, payload.GenType, payload.TaskID,
			payload.Title+"完成",
			"素材生成已完成",
			"/assets")
	}

	if h.deps.Broadcaster != nil {
		h.deps.Broadcaster.BroadcastResourceCreated(payload.UserID, payload.ResourceID, "resource_"+payload.GenType)
	}

	return nil
}

func (h *ResourceGenHandler) doVoiceDesign(ctx context.Context, p ResourceGenPayload) error {
	var req resource.GenerateVoiceDesignRequest
	if err := json.Unmarshal(p.RequestJSON, &req); err != nil {
		return fmt.Errorf("解析请求参数: %w", err)
	}
	_, err := h.deps.ResourceSvc.CompleteVoiceDesign(ctx, p.UserID, p.ResourceID, req)
	return err
}

func (h *ResourceGenHandler) doVoiceClone(ctx context.Context, p ResourceGenPayload) error {
	var req resource.GenerateVoiceRequest
	if err := json.Unmarshal(p.RequestJSON, &req); err != nil {
		return fmt.Errorf("解析请求参数: %w", err)
	}
	_, err := h.deps.ResourceSvc.CompleteVoiceClone(ctx, p.UserID, p.ResourceID, req)
	return err
}

func (h *ResourceGenHandler) doImage(ctx context.Context, p ResourceGenPayload) error {
	var req resource.GenerateImageRequest
	if err := json.Unmarshal(p.RequestJSON, &req); err != nil {
		return fmt.Errorf("解析请求参数: %w", err)
	}
	_, err := h.deps.ResourceSvc.CompleteImage(ctx, p.UserID, p.ResourceID, req)
	return err
}

func (h *ResourceGenHandler) doText(ctx context.Context, p ResourceGenPayload) error {
	var req resource.GeneratePromptRequest
	if err := json.Unmarshal(p.RequestJSON, &req); err != nil {
		return fmt.Errorf("解析请求参数: %w", err)
	}
	_, err := h.deps.ResourceSvc.CompletePrompt(ctx, p.UserID, p.ResourceID, req)
	return err
}

func (h *ResourceGenHandler) broadcastProgress(p ResourceGenPayload, progress int, status string) {
	if h.deps.Broadcaster == nil {
		return
	}
	data := map[string]interface{}{
		"taskId":     p.TaskID,
		"type":       p.GenType,
		"progress":   progress,
		"status":     status,
		"title":      p.Title,
		"resourceId": p.ResourceID,
	}
	switch {
	case progress >= 100 && status == "completed":
		h.deps.Broadcaster.BroadcastTaskComplete(p.UserID, nil, p.TaskID, data)
	case status == "failed":
		h.deps.Broadcaster.BroadcastTaskError(p.UserID, nil, p.TaskID, data)
	default:
		h.deps.Broadcaster.BroadcastTaskProgress(p.UserID, nil, p.TaskID, data)
	}
}

// RegisterResourceGenHandlers 在 mux 中注册素材库生成 Handler
func RegisterResourceGenHandlers(mux *asynq.ServeMux, h *ResourceGenHandler) {
	mux.HandleFunc(tasktypes.TypeResourceVoiceDesign, h.HandleVoiceDesign)
	mux.HandleFunc(tasktypes.TypeResourceVoiceClone, h.HandleVoiceClone)
	mux.HandleFunc(tasktypes.TypeResourceImage, h.HandleImage)
	mux.HandleFunc(tasktypes.TypeResourceText, h.HandleText)
}
