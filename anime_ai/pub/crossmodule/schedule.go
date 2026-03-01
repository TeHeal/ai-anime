package crossmodule

import (
	"context"
	"time"
)

// ScheduleInfo 定时任务信息（供 pub/scheduler 使用）
type ScheduleInfo struct {
	ID        string     `json:"id"`
	ProjectID string     `json:"project_id"`
	UserID    string     `json:"user_id"`
	CronExpr  string     `json:"cron_expr"`
	Action    string     `json:"action"`
	Config    []byte     `json:"config,omitempty"`
	NextRunAt *time.Time `json:"next_run_at,omitempty"`
}

// ScheduleData 定时任务数据访问接口，供 pub/scheduler 调用
// 由 schedule 模块实现并注入
type ScheduleData interface {
	ListDue(ctx context.Context) ([]*ScheduleInfo, error)
	UpdateRunTimes(ctx context.Context, id string, lastRun, nextRun time.Time) error
}
