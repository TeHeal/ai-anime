// Package scheduler 定时任务调度器（README 2.1 任务编排与定时）
package scheduler

import (
	"context"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/module/schedule"
	"github.com/robfig/cron/v3"
	"go.uber.org/zap"
)

// TaskTrigger 任务触发接口，调度器执行到时任务时调用
type TaskTrigger interface {
	Trigger(ctx context.Context, sch *schedule.Schedule) error
}

// Scheduler 定时任务调度器，轮询 due 任务并触发
type Scheduler struct {
	data   schedule.Data
	trigger TaskTrigger
	logger *zap.Logger
	stopCh chan struct{}
}

// NewScheduler 创建调度器
func NewScheduler(data schedule.Data, trigger TaskTrigger, logger *zap.Logger) *Scheduler {
	return &Scheduler{data: data, trigger: trigger, logger: logger, stopCh: make(chan struct{})}
}

// Start 启动调度器，每 30 秒轮询一次 due 任务
func (s *Scheduler) Start() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	for {
		select {
		case <-s.stopCh:
			return
		case <-ticker.C:
			s.tick()
		}
	}
}

// Stop 停止调度器
func (s *Scheduler) Stop() {
	close(s.stopCh)
}

func (s *Scheduler) tick() {
	ctx := context.Background()
	list, err := s.data.ListDue(ctx)
	if err != nil {
		s.logger.Error("ListDueSchedules 失败", zap.Error(err))
		return
	}
	for _, sch := range list {
		if err := s.runOne(ctx, sch); err != nil {
			s.logger.Error("执行定时任务失败", zap.String("schedule_id", sch.ID), zap.Error(err))
		}
	}
}

func (s *Scheduler) runOne(ctx context.Context, sch *schedule.Schedule) error {
	now := time.Now()
	if s.trigger != nil {
		if err := s.trigger.Trigger(ctx, sch); err != nil {
			return err
		}
	}
	sched, err := cron.ParseStandard(sch.CronExpr)
	if err != nil {
		return err
	}
	nextRun := sched.Next(now)
	return s.data.UpdateRunTimes(ctx, sch.ID, now, nextRun)
}
