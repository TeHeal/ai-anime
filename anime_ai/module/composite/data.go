package composite

import (
	"fmt"
	"sync"
)

// Store 成片数据访问接口
type Store interface {
	Create(task *CompositeTask) (*CompositeTask, error)
	Get(id string) (*CompositeTask, error)
	ListByProject(projectID string) ([]*CompositeTask, error)
	UpdateTimeline(id string, timeline []TimelineItem, audio []AudioTrack, subs []SubtitleItem) error
	UpdateStatus(id, status string, progress int, errMsg string) error
	UpdateOutput(id, outputURL string, duration int) error
}

// MemStore 内存成片存储
type MemStore struct {
	mu     sync.RWMutex
	items  map[string]*CompositeTask
	nextID int
}

// NewMemStore 创建内存成片存储
func NewMemStore() *MemStore {
	return &MemStore{items: make(map[string]*CompositeTask), nextID: 1}
}

// Create 创建成片任务
func (s *MemStore) Create(task *CompositeTask) (*CompositeTask, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	task.ID = fmt.Sprintf("%d", s.nextID)
	s.nextID++
	cp := *task
	s.items[task.ID] = &cp
	return &cp, nil
}

// Get 获取成片任务
func (s *MemStore) Get(id string) (*CompositeTask, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if t, ok := s.items[id]; ok {
		cp := *t
		return &cp, nil
	}
	return nil, fmt.Errorf("not found")
}

// ListByProject 列出项目的成片任务
func (s *MemStore) ListByProject(projectID string) ([]*CompositeTask, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var result []*CompositeTask
	for _, t := range s.items {
		if t.ProjectID == projectID {
			cp := *t
			result = append(result, &cp)
		}
	}
	return result, nil
}

// UpdateTimeline 更新时间线
func (s *MemStore) UpdateTimeline(id string, timeline []TimelineItem, audio []AudioTrack, subs []SubtitleItem) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if t, ok := s.items[id]; ok {
		t.Timeline = timeline
		t.AudioTracks = audio
		t.SubtitleTracks = subs
		return nil
	}
	return fmt.Errorf("not found")
}

// UpdateStatus 更新成片状态和进度
func (s *MemStore) UpdateStatus(id, status string, progress int, errMsg string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if t, ok := s.items[id]; ok {
		t.Status = status
		t.Progress = progress
		t.ErrorMessage = errMsg
		return nil
	}
	return fmt.Errorf("not found")
}

// UpdateOutput 更新成片输出
func (s *MemStore) UpdateOutput(id, outputURL string, duration int) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if t, ok := s.items[id]; ok {
		t.Status = StatusDone
		t.OutputURL = outputURL
		t.Duration = duration
		t.Progress = 100
		return nil
	}
	return fmt.Errorf("not found")
}
