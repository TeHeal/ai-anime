package schedule

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"go.uber.org/zap"
)

// Service 调度任务业务逻辑
type Service struct {
	store  Store
	logger *zap.Logger
}

// NewService 创建调度服务
func NewService(store Store, logger *zap.Logger) *Service {
	return &Service{store: store, logger: logger}
}

// Create 创建定时任务
func (s *Service) Create(projectID, userID string, req CreateRequest) (*Schedule, error) {
	sch := &Schedule{
		ProjectID:  projectID,
		Name:       req.Name,
		CronExpr:   req.CronExpr,
		TaskType:   req.TaskType,
		TaskParams: req.TaskParams,
		Enabled:    req.Enabled,
		CreatedBy:  userID,
	}
	created, err := s.store.Create(sch)
	if err != nil {
		s.logger.Error("创建调度任务失败", zap.String("project_id", projectID), zap.Error(err))
		return nil, pkg.NewBizError("创建调度任务失败")
	}
	s.logger.Info("调度任务已创建", zap.String("id", created.ID), zap.String("cron", req.CronExpr))
	return created, nil
}

// List 列出项目调度任务
func (s *Service) List(projectID string) ([]*Schedule, error) {
	return s.store.ListByProject(projectID)
}

// Get 获取调度任务
func (s *Service) Get(id string) (*Schedule, error) {
	sch, err := s.store.Get(id)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return sch, nil
}

// Update 更新调度任务
func (s *Service) Update(id string, req UpdateRequest) (*Schedule, error) {
	sch, err := s.store.Get(id)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	if req.Name != "" {
		sch.Name = req.Name
	}
	if req.CronExpr != "" {
		sch.CronExpr = req.CronExpr
	}
	if req.TaskType != "" {
		sch.TaskType = req.TaskType
	}
	if req.TaskParams != "" {
		sch.TaskParams = req.TaskParams
	}
	if req.Enabled != nil {
		sch.Enabled = *req.Enabled
	}
	if err := s.store.Update(sch); err != nil {
		s.logger.Error("更新调度任务失败", zap.String("id", id), zap.Error(err))
		return nil, pkg.NewBizError("更新调度任务失败")
	}
	return sch, nil
}

// Delete 删除调度任务
func (s *Service) Delete(id string) error {
	if err := s.store.Delete(id); err != nil {
		return pkg.ErrNotFound
	}
	return nil
}
