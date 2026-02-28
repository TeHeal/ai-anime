package location

import (
	"fmt"
	"sync"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// MemLocationStore 内存实现，无 DB 时使用
type MemLocationStore struct {
	mu   sync.RWMutex
	byID map[string]*Location
	seq  int
}

// NewMemLocationStore 创建内存存储
func NewMemLocationStore() *MemLocationStore {
	return &MemLocationStore{
		byID: make(map[string]*Location),
		seq:  1,
	}
}

func (s *MemLocationStore) Create(loc *Location) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	loc.ID = fmt.Sprintf("%d", s.seq)
	s.seq++
	if loc.ImageStatus == "" {
		loc.ImageStatus = "none"
	}
	if loc.Status == "" {
		loc.Status = "draft"
	}
	if loc.Source == "" {
		loc.Source = "manual"
	}
	s.byID[loc.ID] = loc
	return nil
}

func (s *MemLocationStore) GetByID(id, projectID string) (*Location, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	loc, ok := s.byID[id]
	if !ok || loc.ProjectID != projectID {
		return nil, pkg.ErrNotFound
	}
	cp := *loc
	return &cp, nil
}

func (s *MemLocationStore) ListByProject(projectID string) ([]Location, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var out []Location
	for _, loc := range s.byID {
		if loc.ProjectID == projectID {
			out = append(out, *loc)
		}
	}
	return out, nil
}

func (s *MemLocationStore) Update(loc *Location) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	existing, ok := s.byID[loc.ID]
	if !ok || existing.ProjectID != loc.ProjectID {
		return pkg.ErrNotFound
	}
	s.byID[loc.ID] = loc
	return nil
}

func (s *MemLocationStore) UpdateImage(id, projectID, imageURL, taskID, imageStatus string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	loc, ok := s.byID[id]
	if !ok || loc.ProjectID != projectID {
		return pkg.ErrNotFound
	}
	loc.ImageURL = imageURL
	loc.TaskID = taskID
	loc.ImageStatus = imageStatus
	return nil
}

func (s *MemLocationStore) Delete(id, projectID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	loc, ok := s.byID[id]
	if !ok || loc.ProjectID != projectID {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	return nil
}
