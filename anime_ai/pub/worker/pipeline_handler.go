// Package worker 流水线编排 Handler（README 2.1 工作流编排）
// 支持顺序执行 script → images → videos → export 阶段，
// 失败时记录断点并停止后续阶段。
package worker

import (
	"context"
	"encoding/json"
	"fmt"

	"anime_ai/pub/crossmodule"
	"anime_ai/pub/realtime"
	"anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// PipelineStage 流水线阶段名
const (
	StageScript = "script"
	StageImages = "images"
	StageVideos = "videos"
	StageExport = "export"
)

// PipelinePayload 流水线任务载荷
type PipelinePayload struct {
	ProjectID string   `json:"project_id"`
	UserID    string   `json:"user_id"`
	Stages    []string `json:"stages"`
}

// PipelineTaskDeps 流水线 Handler 依赖
type PipelineTaskDeps struct {
	ScriptLockChecker crossmodule.ScriptLockChecker
	AsynqClient       *asynq.Client
	RealtimeHub       *realtime.Hub
}

// PipelineTaskHandler 流水线编排任务 Handler
type PipelineTaskHandler struct {
	log  *zap.Logger
	deps PipelineTaskDeps
}

// NewPipelineTaskHandler 创建流水线 Handler
func NewPipelineTaskHandler(log *zap.Logger, deps PipelineTaskDeps) *PipelineTaskHandler {
	return &PipelineTaskHandler{
		log:  log.Named("pipeline_worker"),
		deps: deps,
	}
}

// Handle 处理流水线任务：顺序执行各阶段，失败时停止并记录断点
func (h *PipelineTaskHandler) Handle(ctx context.Context, t *asynq.Task) error {
	var payload PipelinePayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("解析 payload: %w", err)
	}

	stages := payload.Stages
	if len(stages) == 0 {
		stages = []string{StageScript, StageImages, StageVideos, StageExport}
	}

	h.log.Info("开始流水线编排",
		zap.String("project_id", payload.ProjectID),
		zap.Strings("stages", stages),
	)

	for i, stage := range stages {
		select {
		case <-ctx.Done():
			h.broadcastPipelineStatus(payload, stage, "cancelled", fmt.Sprintf("流水线在阶段 %s 被取消", stage))
			return ctx.Err()
		default:
		}

		h.broadcastPipelineStatus(payload, stage, "running", fmt.Sprintf("正在执行阶段 %d/%d: %s", i+1, len(stages), stage))

		if err := h.executeStage(ctx, payload, stage); err != nil {
			h.log.Error("流水线阶段失败，停止后续阶段",
				zap.String("project_id", payload.ProjectID),
				zap.String("failed_stage", stage),
				zap.Error(err),
			)
			h.broadcastPipelineStatus(payload, stage, "failed", fmt.Sprintf("阶段 %s 失败: %s", stage, err.Error()))
			return nil
		}

		h.broadcastPipelineStatus(payload, stage, "completed", fmt.Sprintf("阶段 %s 完成", stage))
	}

	h.log.Info("流水线编排完成", zap.String("project_id", payload.ProjectID))
	h.broadcastPipelineStatus(payload, "all", "completed", "流水线全部阶段完成")
	return nil
}

// executeStage 执行单个阶段：检查前置条件并入队对应任务
func (h *PipelineTaskHandler) executeStage(ctx context.Context, payload PipelinePayload, stage string) error {
	switch stage {
	case StageScript:
		return h.stageScript(ctx, payload)
	case StageImages:
		return h.stageImages(ctx, payload)
	case StageVideos:
		return h.stageVideos(ctx, payload)
	case StageExport:
		return h.stageExport(ctx, payload)
	default:
		return fmt.Errorf("未知的流水线阶段: %s", stage)
	}
}

// stageScript 脚本解析阶段：入队脚本解析任务
func (h *PipelineTaskHandler) stageScript(ctx context.Context, payload PipelinePayload) error {
	if h.deps.AsynqClient == nil {
		h.log.Warn("AsynqClient 未配置，跳过脚本解析阶段")
		return nil
	}
	taskPayload, _ := json.Marshal(map[string]interface{}{
		"project_id": payload.ProjectID,
		"user_id":    payload.UserID,
		"pipeline":   true,
	})
	task := asynq.NewTask(tasktypes.TypeScriptParse, taskPayload)
	_, err := h.deps.AsynqClient.EnqueueContext(ctx, task)
	if err != nil {
		return fmt.Errorf("脚本解析入队失败: %w", err)
	}
	return nil
}

// stageImages 镜图生成阶段：检查脚本锁定后入队镜图生成任务
func (h *PipelineTaskHandler) stageImages(ctx context.Context, payload PipelinePayload) error {
	if h.deps.ScriptLockChecker != nil {
		locked, err := h.deps.ScriptLockChecker.IsScriptLocked(payload.ProjectID)
		if err != nil {
			return fmt.Errorf("检查脚本锁定状态失败: %w", err)
		}
		if !locked {
			return fmt.Errorf("脚本未锁定，无法生成镜图")
		}
	}
	if h.deps.AsynqClient == nil {
		h.log.Warn("AsynqClient 未配置，跳过镜图生成阶段")
		return nil
	}
	taskPayload, _ := json.Marshal(map[string]interface{}{
		"project_id": payload.ProjectID,
		"user_id":    payload.UserID,
		"pipeline":   true,
	})
	task := asynq.NewTask(tasktypes.TypeImageGeneration, taskPayload)
	_, err := h.deps.AsynqClient.EnqueueContext(ctx, task)
	if err != nil {
		return fmt.Errorf("镜图生成入队失败: %w", err)
	}
	return nil
}

// stageVideos 镜头视频生成阶段：检查脚本锁定后入队视频生成任务
func (h *PipelineTaskHandler) stageVideos(ctx context.Context, payload PipelinePayload) error {
	if h.deps.ScriptLockChecker != nil {
		locked, err := h.deps.ScriptLockChecker.IsScriptLocked(payload.ProjectID)
		if err != nil {
			return fmt.Errorf("检查脚本锁定状态失败: %w", err)
		}
		if !locked {
			return fmt.Errorf("脚本未锁定，无法生成镜头视频")
		}
	}
	if h.deps.AsynqClient == nil {
		h.log.Warn("AsynqClient 未配置，跳过镜头视频生成阶段")
		return nil
	}
	taskPayload, _ := json.Marshal(map[string]interface{}{
		"project_id": payload.ProjectID,
		"user_id":    payload.UserID,
		"pipeline":   true,
	})
	task := asynq.NewTask(tasktypes.TypeVideoGeneration, taskPayload)
	_, err := h.deps.AsynqClient.EnqueueContext(ctx, task)
	if err != nil {
		return fmt.Errorf("镜头视频生成入队失败: %w", err)
	}
	return nil
}

// stageExport 成片导出阶段：入队成片导出任务
func (h *PipelineTaskHandler) stageExport(ctx context.Context, payload PipelinePayload) error {
	if h.deps.AsynqClient == nil {
		h.log.Warn("AsynqClient 未配置，跳过成片导出阶段")
		return nil
	}
	taskPayload, _ := json.Marshal(map[string]interface{}{
		"project_id": payload.ProjectID,
		"user_id":    payload.UserID,
		"pipeline":   true,
	})
	task := asynq.NewTask(tasktypes.TypeExport, taskPayload)
	_, err := h.deps.AsynqClient.EnqueueContext(ctx, task)
	if err != nil {
		return fmt.Errorf("成片导出入队失败: %w", err)
	}
	return nil
}

func (h *PipelineTaskHandler) broadcastPipelineStatus(payload PipelinePayload, stage, status, message string) {
	if h.deps.RealtimeHub == nil {
		return
	}
	var projectID *string
	if payload.ProjectID != "" {
		projectID = &payload.ProjectID
	}
	h.deps.RealtimeHub.BroadcastTaskProgress(payload.UserID, projectID, "pipeline:"+payload.ProjectID, map[string]interface{}{
		"taskId":   "pipeline:" + payload.ProjectID,
		"type":     "pipeline",
		"stage":    stage,
		"status":   status,
		"message":  message,
		"title":    "流水线编排",
		"progress": 0,
	})
}

// RegisterPipelineHandler 注册流水线 Handler（映射到 TypeStoryboardGenerate）
func RegisterPipelineHandler(mux *asynq.ServeMux, h *PipelineTaskHandler) {
	mux.HandleFunc(tasktypes.TypeStoryboardGenerate, h.Handle)
}
