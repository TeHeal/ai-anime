// Package worker 成片导出任务 Handler（README 成片阶段）
package worker

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/module/composite"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
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
	CompositeService *composite.Service
	// Storage 可选，用于写入成片文件；nil 时仅更新状态为占位
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

	if h.deps.CompositeService == nil {
		h.log.Warn("CompositeService 未配置，跳过")
		return nil
	}

	// 更新为导出中
	_ = h.deps.CompositeService.UpdateStatus(ctx, payload.CompositeTaskID, composite.StatusExporting, "", "")

	// 占位：实际需合并镜头视频（FFmpeg）、音频、字幕
	// 当前模拟延迟后标记完成
	select {
	case <-time.After(2 * time.Second):
	case <-ctx.Done():
		_ = h.deps.CompositeService.UpdateStatus(ctx, payload.CompositeTaskID, composite.StatusFailed, "", "任务取消")
		return ctx.Err()
	}

	// 占位 output_url，实际应从 Storage 上传后获取
	outputURL := ""
	_ = h.deps.CompositeService.UpdateStatus(ctx, payload.CompositeTaskID, composite.StatusDone, outputURL, "")

	h.log.Info("成片导出任务完成（占位）",
		zap.String("composite_task_id", payload.CompositeTaskID),
	)
	return nil
}

// RegisterExportHandler 注册成片导出 Handler
func RegisterExportHandler(mux *asynq.ServeMux, h *ExportTaskHandler) {
	mux.HandleFunc(tasktypes.TypeExport, h.Handle)
}
