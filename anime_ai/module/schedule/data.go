package schedule

import (
	"fmt"
	"sync"
)

// Store 调度数据访问接口
type Store interface {
	Create(s *Schedule) (*Schedule, error)
	Get(id string) (*Schedule, error)
	ListByProject(projectID string) ([]*Schedule, error)
	Update(s *Schedule) error
	Delete(id string) error
	ListDue() ([]*Schedule, error)
	UpdateLastRun(id, nextRunAt string) error
}

// MemStore 内存实现
type MemStore struct {
	mu     sync.RWMutex
	items  map[string]*Schedule
	nextID int
}

// NewMemStore 创建内存调度存储
func NewMemStore() *MemStore {
	return &MemStore{items: make(map[string]*Schedule), nextID: 1}
}

func (s *MemStore) Create(sch *Schedule) (*Schedule, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	sch.ID = fmt.Sprintf("%d", s.nextID)
	s.nextID++
	cp := *sch
	s.items[sch.ID] = &cp
	return &cp, nil
}

func (s *MemStore) Get(id string) (*Schedule, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if sch, ok := s.items[id]; ok {
		cp := *sch
		return &cp, nil
	}
	return nil, fmt.Errorf("not found")
}

func (s *MemStore) ListByProject(projectID string) ([]*Schedule, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var result []*Schedule
	for _, sch := range s.items {
		if sch.ProjectID == projectID {
			cp := *sch
			result = append(result, &cp)
		}
	}
	return result, nil
}

func (s *MemStore) Update(sch *Schedule) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.items[sch.ID]; !ok {
		return fmt.Errorf("not found")
	}
	cp := *sch
	s.items[sch.ID] = &cp
	return nil
}

func (s *MemStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.items, id)
	return nil
}

func (s *MemStore) ListDue() ([]*Schedule, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var result []*Schedule
	for _, sch := range s.items {
		if sch.Enabled {
			cp := *sch
			result = append(result, &cp)
		}
	}
	return result, nil
}

func (s *MemStore) UpdateLastRun(id, nextRunAt string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if sch, ok := s.items[id]; ok {
		sch.NextRunAt = nextRunAt
		return nil
	}
	return fmt.Errorf("not found")
}
