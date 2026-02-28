package notification

import (
	"context"
)

// TaskNotifierAdapter 适配 worker.TaskNotifier，任务完成时写入通知表
type TaskNotifierAdapter struct {
	svc *Service
}

// NewTaskNotifierAdapter 创建适配器
func NewTaskNotifierAdapter(svc *Service) *TaskNotifierAdapter {
	return &TaskNotifierAdapter{svc: svc}
}

// NotifyTaskComplete 实现 worker.TaskNotifier
func (a *TaskNotifierAdapter) NotifyTaskComplete(ctx context.Context, userID string, taskType string, taskID string, title string, body string, linkURL string) {
	_ = a.svc.Create(ctx, userID, "task_complete", title, body, linkURL, map[string]interface{}{
		"task_type": taskType,
		"task_id":   taskID,
	})
}

// Service 通知业务逻辑层
type Service struct {
	data Data
}

// NewService 创建 Service 实例
func NewService(data Data) *Service {
	return &Service{data: data}
}

// Create 创建通知（供 Worker 等调用，任务完成时写入）
func (s *Service) Create(ctx context.Context, userID string, typ, title, body, linkURL string, meta map[string]interface{}) error {
	_, err := s.data.Create(ctx, userID, typ, title, body, linkURL, meta)
	return err
}

// List 分页获取用户通知列表
func (s *Service) List(ctx context.Context, userID string, limit, offset int32) ([]Notification, error) {
	return s.data.List(ctx, userID, limit, offset)
}

// CountUnread 获取未读数量（红点）
func (s *Service) CountUnread(ctx context.Context, userID string) (int64, error) {
	return s.data.CountUnread(ctx, userID)
}

// MarkAsRead 标记单条已读
func (s *Service) MarkAsRead(ctx context.Context, id, userID string) error {
	return s.data.MarkAsRead(ctx, id, userID)
}

// MarkAllAsRead 全部已读
func (s *Service) MarkAllAsRead(ctx context.Context, userID string) error {
	return s.data.MarkAllAsRead(ctx, userID)
}
