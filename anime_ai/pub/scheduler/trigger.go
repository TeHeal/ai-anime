package scheduler

import (
	"context"

	"anime_ai/pub/crossmodule"
	"go.uber.org/zap"
)

// NoopTrigger 占位触发器，仅记录日志，不执行实际任务
type NoopTrigger struct {
	logger *zap.Logger
}

// NewNoopTrigger 创建占位触发器
func NewNoopTrigger(logger *zap.Logger) *NoopTrigger {
	return &NoopTrigger{logger: logger}
}

// Trigger 实现 TaskTrigger
func (t *NoopTrigger) Trigger(ctx context.Context, sch *crossmodule.ScheduleInfo) error {
	t.logger.Info("定时任务触发（占位）",
		zap.String("schedule_id", sch.ID),
		zap.String("project_id", sch.ProjectID),
		zap.String("action", sch.Action),
		zap.String("cron_expr", sch.CronExpr))
	return nil
}

var _ TaskTrigger = (*NoopTrigger)(nil)
