package notification

import (
	"context"
	"encoding/json"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

// MemData 内存实现，用于单元测试
type MemData struct {
	mu     sync.RWMutex
	nextID atomic.Uint64
	byID   map[string]*Notification
	byUser map[string][]*Notification
}

// NewMemData 创建内存 Data 实例
func NewMemData() *MemData {
	return &MemData{
		byID:   make(map[string]*Notification),
		byUser: make(map[string][]*Notification),
	}
}

// Create 创建通知
func (d *MemData) Create(ctx context.Context, userID string, typ, title, body, linkURL string, meta interface{}) (*Notification, error) {
	d.mu.Lock()
	defer d.mu.Unlock()
	id := d.nextID.Add(1)
	idStr := strconv.FormatUint(id, 10)
	metaJSON := "{}"
	if meta != nil {
		if b, err := json.Marshal(meta); err == nil {
			metaJSON = string(b)
		}
	}
	n := &Notification{
		ID:        idStr,
		CreatedAt: time.Now().Format("2006-01-02T15:04:05Z07:00"),
		Type:      typ,
		Title:     title,
		Body:      body,
		LinkURL:   linkURL,
		ReadAt:    "",
	}
	_ = metaJSON
	d.byID[idStr] = n
	d.byUser[userID] = append(d.byUser[userID], n)
	return n, nil
}

// List 分页列表
func (d *MemData) List(ctx context.Context, userID string, limit, offset int32) ([]Notification, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()
	list := d.byUser[userID]
	if limit <= 0 {
		limit = 50
	}
	start := int(offset)
	if start >= len(list) {
		return []Notification{}, nil
	}
	end := start + int(limit)
	if end > len(list) {
		end = len(list)
	}
	out := make([]Notification, end-start)
	for i := start; i < end; i++ {
		out[i-start] = *list[i]
	}
	return out, nil
}

// CountUnread 未读数量（MemData 简化：无 ReadAt 即未读）
func (d *MemData) CountUnread(ctx context.Context, userID string) (int64, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()
	list := d.byUser[userID]
	var count int64
	for _, n := range list {
		if n.ReadAt == "" {
			count++
		}
	}
	return count, nil
}

// MarkAsRead 标记单条已读
func (d *MemData) MarkAsRead(ctx context.Context, id, userID string) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	n, ok := d.byID[id]
	if !ok {
		return nil
	}
	n.ReadAt = time.Now().Format("2006-01-02T15:04:05Z07:00")
	return nil
}

// MarkAllAsRead 全部已读
func (d *MemData) MarkAllAsRead(ctx context.Context, userID string) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	now := time.Now().Format("2006-01-02T15:04:05Z07:00")
	for _, n := range d.byUser[userID] {
		n.ReadAt = now
	}
	return nil
}
