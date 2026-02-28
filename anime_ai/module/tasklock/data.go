package tasklock

import (
	"fmt"
	"sync"
	"time"
)

// Store 任务锁数据访问接口
type Store interface {
	Create(lock *TaskLock) (*TaskLock, error)
	GetActive(resourceType, resourceID, action string) (*TaskLock, error)
	Release(id string) error
	ExpireStale() error
}

// MemStore 内存实现
type MemStore struct {
	mu     sync.RWMutex
	items  map[string]*TaskLock
	nextID int
}

// NewMemStore 创建内存任务锁存储
func NewMemStore() *MemStore {
	return &MemStore{items: make(map[string]*TaskLock), nextID: 1}
}

// Create 创建任务锁
func (s *MemStore) Create(lock *TaskLock) (*TaskLock, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	lock.ID = fmt.Sprintf("%d", s.nextID)
	s.nextID++
	cp := *lock
	s.items[lock.ID] = &cp
	return &cp, nil
}

// GetActive 获取指定资源和操作的活跃任务锁（跳过已过期的锁）
func (s *MemStore) GetActive(resourceType, resourceID, action string) (*TaskLock, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, l := range s.items {
		if l.ResourceType == resourceType && l.ResourceID == resourceID &&
			l.Action == action && l.Status == StatusRunning {
			// 检查是否过期
			if l.ExpiresAt != "" {
				if t, err := time.Parse(time.RFC3339, l.ExpiresAt); err == nil && time.Now().After(t) {
					continue
				}
			}
			cp := *l
			return &cp, nil
		}
	}
	return nil, fmt.Errorf("no active lock")
}

// Release 释放指定任务锁，将状态标记为已完成
func (s *MemStore) Release(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if l, ok := s.items[id]; ok && l.Status == StatusRunning {
		l.Status = StatusCompleted
		return nil
	}
	return fmt.Errorf("lock not found or already released")
}

// ExpireStale 将所有已过期的运行中任务锁标记为已取消
func (s *MemStore) ExpireStale() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	for _, l := range s.items {
		if l.Status == StatusRunning && l.ExpiresAt != "" {
			if t, err := time.Parse(time.RFC3339, l.ExpiresAt); err == nil && now.After(t) {
				l.Status = StatusCancelled
			}
		}
	}
	return nil
}
