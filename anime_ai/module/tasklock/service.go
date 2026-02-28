package tasklock

import (
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"go.uber.org/zap"
)

// Service 任务锁业务逻辑
type Service struct {
	store  Store
	logger *zap.Logger
}

// NewService 创建任务锁服务
func NewService(store Store, logger *zap.Logger) *Service {
	return &Service{store: store, logger: logger}
}

// AcquireRequest 获取锁请求
type AcquireRequest struct {
	ResourceType string `json:"resource_type" binding:"required"`
	ResourceID   string `json:"resource_id" binding:"required"`
	Action       string `json:"action" binding:"required"`
	TTLSeconds   int    `json:"ttl_seconds"`
}

// Acquire 获取任务锁（执行即加锁，他人不可重复执行）
func (s *Service) Acquire(projectID, userID string, req AcquireRequest) (*TaskLock, error) {
	// 检查是否已被锁定
	if existing, err := s.store.GetActive(req.ResourceType, req.ResourceID, req.Action); err == nil {
		if existing.LockedBy != userID {
			s.logger.Warn("任务被占用",
				zap.String("resource", req.ResourceType+"/"+req.ResourceID),
				zap.String("locked_by", existing.LockedBy),
				zap.String("requester", userID),
			)
			return nil, pkg.NewBizError("任务正在被其他用户执行")
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
	created, err := s.store.Create(lock)
	if err != nil {
		s.logger.Error("创建任务锁失败", zap.Error(err))
		return nil, pkg.NewBizError("创建任务锁失败")
	}
	s.logger.Info("任务锁已获取", zap.String("lock_id", created.ID), zap.String("user", userID))
	return created, nil
}

// Release 释放任务锁（完成或取消）
func (s *Service) Release(lockID string) error {
	if err := s.store.Release(lockID); err != nil {
		s.logger.Warn("释放任务锁失败", zap.String("lock_id", lockID), zap.Error(err))
		return pkg.ErrLockNotFound
	}
	s.logger.Info("任务锁已释放", zap.String("lock_id", lockID))
	return nil
}

// Check 检查任务是否被锁定
func (s *Service) Check(resourceType, resourceID, action string) (*TaskLock, error) {
	return s.store.GetActive(resourceType, resourceID, action)
}

// ExpireStale 清理过期锁（由定时任务调用）
func (s *Service) ExpireStale() error {
	return s.store.ExpireStale()
}
