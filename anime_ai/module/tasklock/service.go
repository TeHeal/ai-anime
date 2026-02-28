package tasklock

import (
	"errors"
	"time"
)

// Service 任务锁业务逻辑
type Service struct {
	store Store
}

// NewService 创建任务锁服务
func NewService(store Store) *Service {
	return &Service{store: store}
}

// AcquireRequest 获取锁请求
type AcquireRequest struct {
	ResourceType string `json:"resource_type" binding:"required"`
	ResourceID   string `json:"resource_id" binding:"required"`
	Action       string `json:"action" binding:"required"`
	TTLSeconds   int    `json:"ttl_seconds"`
}

// Acquire 获取任务锁
func (s *Service) Acquire(projectID, userID string, req AcquireRequest) (*TaskLock, error) {
	// 检查是否已被锁定
	if existing, err := s.store.GetActive(req.ResourceType, req.ResourceID, req.Action); err == nil {
		if existing.LockedBy != userID {
			return nil, errors.New("任务正在被其他用户执行: " + existing.LockedBy)
		}
		return existing, nil
	}

	ttl := req.TTLSeconds
	if ttl <= 0 {
		ttl = 600 // 默认 10 分钟
	}
	expiresAt := time.Now().Add(time.Duration(ttl) * time.Second).Format(time.RFC3339)

	lock := &TaskLock{
		ProjectID:    projectID,
		ResourceType: req.ResourceType,
		ResourceID:   req.ResourceID,
		Action:       req.Action,
		Status:       StatusRunning,
		LockedBy:     userID,
		ExpiresAt:    expiresAt,
	}
	return s.store.Create(lock)
}

// Release 释放任务锁
func (s *Service) Release(lockID string) error {
	return s.store.Release(lockID)
}

// Check 检查任务锁
func (s *Service) Check(resourceType, resourceID, action string) (*TaskLock, error) {
	return s.store.GetActive(resourceType, resourceID, action)
}

// ExpireStale 清理过期锁
func (s *Service) ExpireStale() error {
	return s.store.ExpireStale()
}
