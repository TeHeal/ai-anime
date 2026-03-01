package scheduler

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// actionTaskType 将 schedule action 映射到 Asynq 任务类型
var actionTaskType = map[string]string{
	"pipeline":    tasktypes.TypeStoryboardGenerate,
	"batch_image": tasktypes.TypeImageGeneration,
	"batch_video": tasktypes.TypeVideoGeneration,
	"export":      tasktypes.TypeExport,
}

// AsynqTrigger 基于 Asynq 的真实触发器，将到期定时任务入队到 Redis
type AsynqTrigger struct {
	client *asynq.Client
	logger *zap.Logger
}

// NewAsynqTrigger 创建 AsynqTrigger
func NewAsynqTrigger(client *asynq.Client, logger *zap.Logger) *AsynqTrigger {
	return &AsynqTrigger{client: client, logger: logger}
}

// Trigger 根据 ScheduleInfo.Action 构造并入队对应的 Asynq 任务
func (t *AsynqTrigger) Trigger(ctx context.Context, sch *crossmodule.ScheduleInfo) error {
	taskType, ok := actionTaskType[sch.Action]
	if !ok {
		t.logger.Warn("未知的定时任务 action，跳过入队",
			zap.String("schedule_id", sch.ID),
			zap.String("action", sch.Action))
		return fmt.Errorf("未知的 action: %s", sch.Action)
	}

	payload, err := buildPayload(sch)
	if err != nil {
		return fmt.Errorf("构造 payload 失败: %w", err)
	}

	task := asynq.NewTask(taskType, payload)
	info, err := t.client.EnqueueContext(ctx, task)
	if err != nil {
		t.logger.Error("定时任务入队失败",
			zap.String("schedule_id", sch.ID),
			zap.String("task_type", taskType),
			zap.Error(err))
		return fmt.Errorf("入队失败: %w", err)
	}

	t.logger.Info("定时任务已入队",
		zap.String("schedule_id", sch.ID),
		zap.String("task_type", taskType),
		zap.String("asynq_task_id", info.ID),
		zap.String("queue", info.Queue),
		zap.String("project_id", sch.ProjectID))
	return nil
}

// buildPayload 将 ScheduleInfo 的 Config 与基础字段合并为任务 payload
func buildPayload(sch *crossmodule.ScheduleInfo) ([]byte, error) {
	base := map[string]interface{}{
		"schedule_id": sch.ID,
		"project_id":  sch.ProjectID,
		"user_id":     sch.UserID,
	}

	// 将 config_json 中的字段合并到 payload，config 优先级低于基础字段
	if len(sch.Config) > 0 {
		var cfg map[string]interface{}
		if err := json.Unmarshal(sch.Config, &cfg); err == nil {
			for k, v := range cfg {
				if _, exists := base[k]; !exists {
					base[k] = v
				}
			}
		}
	}

	return json.Marshal(base)
}

var _ TaskTrigger = (*AsynqTrigger)(nil)
