package composite

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"go.uber.org/zap"
)

// Service 成片业务逻辑层
type Service struct {
	store  Store
	logger *zap.Logger
}

// NewService 创建成片服务
func NewService(store Store, logger *zap.Logger) *Service {
	return &Service{store: store, logger: logger}
}

// Create 创建成片任务
func (s *Service) Create(projectID, userID string, req CreateRequest) (*CompositeTask, error) {
	format := req.OutputFormat
	if format == "" {
		format = "mp4"
	}
	resolution := req.Resolution
	if resolution == "" {
		resolution = "1080p"
	}
	task := &CompositeTask{
		ProjectID:    projectID,
		EpisodeID:    req.EpisodeID,
		Status:       StatusEditing,
		OutputFormat: format,
		Resolution:   resolution,
		CreatedBy:    userID,
	}
	created, err := s.store.Create(task)
	if err != nil {
		s.logger.Error("创建成片任务失败", zap.String("project_id", projectID), zap.Error(err))
		return nil, pkg.NewBizError("创建成片任务失败")
	}
	s.logger.Info("成片任务已创建", zap.String("id", created.ID))
	return created, nil
}

// Get 获取成片任务
func (s *Service) Get(id string) (*CompositeTask, error) {
	task, err := s.store.Get(id)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return task, nil
}

// List 列出项目的成片任务
func (s *Service) List(projectID string) ([]*CompositeTask, error) {
	return s.store.ListByProject(projectID)
}

// UpdateTimeline 更新时间线（编辑阶段）
func (s *Service) UpdateTimeline(id string, req UpdateTimelineRequest) error {
	task, err := s.store.Get(id)
	if err != nil {
		return pkg.ErrNotFound
	}
	if task.Status != StatusEditing {
		return pkg.NewBizError("仅编辑状态可修改时间线")
	}
	return s.store.UpdateTimeline(id, req.Timeline, req.AudioTracks, req.SubtitleTracks)
}

// StartExport 开始导出（状态: editing → exporting）
func (s *Service) StartExport(id string) error {
	task, err := s.store.Get(id)
	if err != nil {
		return pkg.ErrNotFound
	}
	if task.Status != StatusEditing {
		return pkg.NewBizError("仅编辑状态可启动导出，当前状态: " + task.Status)
	}
	if err := s.store.UpdateStatus(id, StatusExporting, 0, ""); err != nil {
		return pkg.NewBizError("更新状态失败")
	}
	s.logger.Info("成片导出已启动", zap.String("task_id", id))

	// 实际合成在 Worker 中异步执行（通过 ffmpeg）
	// 此处仅状态变更，Worker 将通过 Asynq 任务执行合成
	return nil
}

// CompleteExport 完成导出（由 Worker 调用）
func (s *Service) CompleteExport(id, outputURL string, duration int) error {
	if err := s.store.UpdateOutput(id, outputURL, duration); err != nil {
		s.logger.Error("更新成片输出失败", zap.String("task_id", id), zap.Error(err))
		return pkg.NewBizError("更新输出失败")
	}
	s.logger.Info("成片导出完成", zap.String("task_id", id), zap.String("output", outputURL))
	return nil
}

// FailExport 导出失败（由 Worker 调用）
func (s *Service) FailExport(id, errMsg string) error {
	return s.store.UpdateStatus(id, StatusFailed, 0, errMsg)
}
