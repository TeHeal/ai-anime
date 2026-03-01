package schedule

import (
	"context"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
)

// ScheduleDataAdapter 将 schedule.Data 适配为 crossmodule.ScheduleData，供 pub/scheduler 使用
type ScheduleDataAdapter struct {
	inner Data
}

// NewScheduleDataAdapter 创建适配器
func NewScheduleDataAdapter(inner Data) *ScheduleDataAdapter {
	return &ScheduleDataAdapter{inner: inner}
}

// ListDue 实现 crossmodule.ScheduleData
func (a *ScheduleDataAdapter) ListDue(ctx context.Context) ([]*crossmodule.ScheduleInfo, error) {
	list, err := a.inner.ListDue(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]*crossmodule.ScheduleInfo, len(list))
	for i, s := range list {
		out[i] = &crossmodule.ScheduleInfo{
			ID:        s.ID,
			ProjectID: s.ProjectID,
			UserID:    s.UserID,
			CronExpr:  s.CronExpr,
			Action:    s.Action,
			Config:    s.Config,
			NextRunAt: s.NextRunAt,
		}
	}
	return out, nil
}

// UpdateRunTimes 实现 crossmodule.ScheduleData
func (a *ScheduleDataAdapter) UpdateRunTimes(ctx context.Context, id string, lastRun, nextRun time.Time) error {
	return a.inner.UpdateRunTimes(ctx, id, lastRun, nextRun)
}

var _ crossmodule.ScheduleData = (*ScheduleDataAdapter)(nil)
