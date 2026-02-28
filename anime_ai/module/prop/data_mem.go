package prop

import (
	"fmt"
	"sync"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// MemPropStore 内存实现，无 DB 时使用
type MemPropStore struct {
	mu   sync.RWMutex
	byID map[string]*Prop
	seq  int
}

// NewMemPropStore 创建内存存储
func NewMemPropStore() *MemPropStore {
	return &MemPropStore{
		byID: make(map[string]*Prop),
		seq:  1,
	}
}

func (s *MemPropStore) Create(p *Prop) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	p.ID = fmt.Sprintf("%d", s.seq)
	s.seq++
	if p.Status == "" {
		p.Status = "draft"
	}
	if p.Source == "" {
		p.Source = "manual"
	}
	s.byID[p.ID] = p
	return nil
}

func (s *MemPropStore) GetByID(id, projectID string) (*Prop, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	p, ok := s.byID[id]
	if !ok || p.ProjectID != projectID {
		return nil, pkg.ErrNotFound
	}
	cp := *p
	return &cp, nil
}

func (s *MemPropStore) ListByProject(projectID string) ([]Prop, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var out []Prop
	for _, p := range s.byID {
		if p.ProjectID == projectID {
			out = append(out, *p)
		}
	}
	return out, nil
}

func (s *MemPropStore) Update(p *Prop) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	existing, ok := s.byID[p.ID]
	if !ok || existing.ProjectID != p.ProjectID {
		return pkg.ErrNotFound
	}
	s.byID[p.ID] = p
	return nil
}

func (s *MemPropStore) Delete(id, projectID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	p, ok := s.byID[id]
	if !ok || p.ProjectID != projectID {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	return nil
}
