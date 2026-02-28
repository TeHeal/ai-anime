package schedule

import "errors"

// Service 调度业务逻辑
type Service struct {
	store Store
}

// NewService 创建调度服务
func NewService(store Store) *Service {
	return &Service{store: store}
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
	return s.store.Create(sch)
}

// List 列出项目调度任务
func (s *Service) List(projectID string) ([]*Schedule, error) {
	return s.store.ListByProject(projectID)
}

// Get 获取调度任务
func (s *Service) Get(id string) (*Schedule, error) {
	return s.store.Get(id)
}

// Update 更新调度任务
func (s *Service) Update(id string, req UpdateRequest) (*Schedule, error) {
	sch, err := s.store.Get(id)
	if err != nil {
		return nil, errors.New("调度任务不存在")
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
	return sch, s.store.Update(sch)
}

// Delete 删除调度任务
func (s *Service) Delete(id string) error {
	return s.store.Delete(id)
}
