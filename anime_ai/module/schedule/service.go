package schedule

import (
	"context"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/robfig/cron/v3"
)

// Service 定时任务业务逻辑层
type Service struct {
	data     Data
	verifier crossmodule.ProjectVerifier
}

// NewService 创建 Service 实例
func NewService(data Data, verifier crossmodule.ProjectVerifier) *Service {
	return &Service{data: data, verifier: verifier}
}

// Create 创建定时任务，自动计算首次 next_run_at
func (s *Service) Create(ctx context.Context, projectID, userID, name, cronExpr, action string, config []byte, enabled bool) (*Schedule, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if cronExpr == "" {
		return nil, pkg.NewBizError("cron_expr 不能为空")
	}
	sched, err := cron.ParseStandard(cronExpr)
	if err != nil {
		return nil, pkg.NewBizError("无效的 cron 表达式: " + err.Error())
	}
	var nextRun *time.Time
	if enabled {
		t := sched.Next(time.Now())
		nextRun = &t
	}
	return s.data.Create(ctx, CreateParams{
		ProjectID: projectID,
		UserID:    userID,
		Name:      name,
		CronExpr:  cronExpr,
		Action:    action,
		Config:    config,
		Enabled:   enabled,
		NextRunAt: nextRun,
	})
}

// ListByProject 按项目列出定时任务
func (s *Service) ListByProject(ctx context.Context, projectID, userID string) ([]*Schedule, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.data.ListByProject(ctx, projectID)
}

// Get 获取定时任务
func (s *Service) Get(ctx context.Context, id, userID string) (*Schedule, error) {
	sch, err := s.data.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if err := s.verifier.Verify(sch.ProjectID, userID); err != nil {
		return nil, err
	}
	return sch, nil
}

// Update 更新定时任务
func (s *Service) Update(ctx context.Context, id, userID string, name, cronExpr, action *string, config []byte, enabled *bool) (*Schedule, error) {
	sch, err := s.data.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if err := s.verifier.Verify(sch.ProjectID, userID); err != nil {
		return nil, err
	}
	if cronExpr != nil && *cronExpr != "" {
		if _, err := cron.ParseStandard(*cronExpr); err != nil {
			return nil, pkg.NewBizError("无效的 cron 表达式: " + err.Error())
		}
	}
	return s.data.Update(ctx, id, UpdateParams{
		Name:     name,
		CronExpr: cronExpr,
		Action:   action,
		Config:   config,
		Enabled:  enabled,
	})
}

// Delete 删除定时任务（软删）
func (s *Service) Delete(ctx context.Context, id, userID string) error {
	sch, err := s.data.GetByID(ctx, id)
	if err != nil {
		return err
	}
	if err := s.verifier.Verify(sch.ProjectID, userID); err != nil {
		return err
	}
	return s.data.Delete(ctx, id)
}
