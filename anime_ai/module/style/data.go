package style

import (
	"fmt"
	"sync"
)

// Store 风格数据访问接口
type Store interface {
	Create(s *Style) (*Style, error)
	Get(id string) (*Style, error)
	ListByProject(projectID string) ([]*Style, error)
	Update(s *Style) error
	Delete(id string) error
}

// MemStore 内存实现
type MemStore struct {
	mu     sync.RWMutex
	items  map[string]*Style
	nextID int
}

// NewMemStore 创建内存风格存储
func NewMemStore() *MemStore {
	return &MemStore{items: make(map[string]*Style), nextID: 1}
}

func (s *MemStore) Create(st *Style) (*Style, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	st.ID = fmt.Sprintf("%d", s.nextID)
	s.nextID++
	cp := *st
	s.items[st.ID] = &cp
	return &cp, nil
}

func (s *MemStore) Get(id string) (*Style, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if st, ok := s.items[id]; ok {
		cp := *st
		return &cp, nil
	}
	return nil, fmt.Errorf("not found")
}

func (s *MemStore) ListByProject(projectID string) ([]*Style, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var result []*Style
	for _, st := range s.items {
		if st.ProjectID == projectID {
			cp := *st
			result = append(result, &cp)
		}
	}
	return result, nil
}

func (s *MemStore) Update(st *Style) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.items[st.ID]; !ok {
		return fmt.Errorf("not found")
	}
	cp := *st
	s.items[st.ID] = &cp
	return nil
}

func (s *MemStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.items[id]; !ok {
		return fmt.Errorf("not found")
	}
	delete(s.items, id)
	return nil
}
