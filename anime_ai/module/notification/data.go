package notification

import (
	"fmt"
	"sync"
)

// Store 通知数据访问接口
type Store interface {
	Create(n *Notification) (*Notification, error)
	ListByUser(userID string, limit, offset int) ([]*Notification, error)
	ListUnread(userID string) ([]*Notification, error)
	CountUnread(userID string) (int64, error)
	MarkRead(id, userID string) error
	MarkAllRead(userID string) error
}

// MemStore 内存实现
type MemStore struct {
	mu     sync.RWMutex
	items  []*Notification
	nextID int
}

// NewMemStore 创建内存通知存储
func NewMemStore() *MemStore {
	return &MemStore{nextID: 1}
}

// Create 创建通知记录
func (s *MemStore) Create(n *Notification) (*Notification, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	n.ID = fmt.Sprintf("%d", s.nextID)
	s.nextID++
	cp := *n
	s.items = append(s.items, &cp)
	return &cp, nil
}

// ListByUser 按用户 ID 分页查询通知列表（按时间倒序）
func (s *MemStore) ListByUser(userID string, limit, offset int) ([]*Notification, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var filtered []*Notification
	for i := len(s.items) - 1; i >= 0; i-- {
		if s.items[i].UserID == userID {
			cp := *s.items[i]
			filtered = append(filtered, &cp)
		}
	}
	if offset >= len(filtered) {
		return nil, nil
	}
	end := offset + limit
	if end > len(filtered) {
		end = len(filtered)
	}
	return filtered[offset:end], nil
}

// ListUnread 查询指定用户的所有未读通知
func (s *MemStore) ListUnread(userID string) ([]*Notification, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var result []*Notification
	for _, n := range s.items {
		if n.UserID == userID && !n.IsRead {
			cp := *n
			result = append(result, &cp)
		}
	}
	return result, nil
}

// CountUnread 统计指定用户的未读通知数量
func (s *MemStore) CountUnread(userID string) (int64, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var count int64
	for _, n := range s.items {
		if n.UserID == userID && !n.IsRead {
			count++
		}
	}
	return count, nil
}

// MarkRead 将指定通知标记为已读
func (s *MemStore) MarkRead(id, userID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, n := range s.items {
		if n.ID == id && n.UserID == userID {
			n.IsRead = true
			return nil
		}
	}
	return fmt.Errorf("not found")
}

// MarkAllRead 将指定用户的所有通知标记为已读
func (s *MemStore) MarkAllRead(userID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, n := range s.items {
		if n.UserID == userID {
			n.IsRead = true
		}
	}
	return nil
}
