package shot_image

import (
	"sort"
	"strconv"
	"sync"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// ShotImageStore 镜图数据访问接口，sch 就绪后可切换为 sqlc 实现
// ID 使用 string（UUID），与 sch/db pgtype.UUID 互转
type ShotImageStore interface {
	Create(s *ShotImage) error
	BulkCreate(images []ShotImage) error
	FindByID(id string) (*ShotImage, error)
	ListByShot(shotID string) ([]ShotImage, error)
	ListByProject(projectID string) ([]ShotImage, error)
	Update(s *ShotImage) error
	Delete(id string) error
	DeleteByShot(shotID string) error
}

// MemShotImageStore 内存占位实现，ID 使用 string
type MemShotImageStore struct {
	mu        sync.RWMutex
	nextID    uint
	byID      map[string]*ShotImage
	byShot    map[string][]*ShotImage
	byProject map[string][]*ShotImage
}

// NewMemShotImageStore 创建内存镜图存储
func NewMemShotImageStore() *MemShotImageStore {
	return &MemShotImageStore{
		byID:      make(map[string]*ShotImage),
		byShot:    make(map[string][]*ShotImage),
		byProject: make(map[string][]*ShotImage),
		nextID:    1,
	}
}

func (s *MemShotImageStore) Create(img *ShotImage) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	id := strconv.FormatUint(uint64(s.nextID), 10)
	s.nextID++
	now := time.Now()
	img.ID = id
	img.CreatedAt = now
	img.UpdatedAt = now
	cp := *img
	s.byID[id] = &cp
	s.byShot[img.ShotID] = append(s.byShot[img.ShotID], &cp)
	s.byProject[img.ProjectID] = append(s.byProject[img.ProjectID], &cp)
	return nil
}

func (s *MemShotImageStore) BulkCreate(images []ShotImage) error {
	if len(images) == 0 {
		return nil
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	for i := range images {
		id := strconv.FormatUint(uint64(s.nextID), 10)
		s.nextID++
		img := &images[i]
		img.ID = id
		img.CreatedAt = now
		img.UpdatedAt = now
		s.byID[id] = img
		s.byShot[img.ShotID] = append(s.byShot[img.ShotID], img)
		s.byProject[img.ProjectID] = append(s.byProject[img.ProjectID], img)
	}
	return nil
}

func (s *MemShotImageStore) FindByID(id string) (*ShotImage, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	img, ok := s.byID[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	cp := *img
	return &cp, nil
}

func (s *MemShotImageStore) ListByShot(shotID string) ([]ShotImage, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	list := s.byShot[shotID]
	out := make([]ShotImage, len(list))
	for i, img := range list {
		out[i] = *img
	}
	sort.Slice(out, func(i, j int) bool { return out[i].SortIndex < out[j].SortIndex })
	return out, nil
}

func (s *MemShotImageStore) ListByProject(projectID string) ([]ShotImage, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	list := s.byProject[projectID]
	out := make([]ShotImage, len(list))
	for i, img := range list {
		out[i] = *img
	}
	return out, nil
}

func (s *MemShotImageStore) Update(img *ShotImage) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.byID[img.ID]; !ok {
		return pkg.ErrNotFound
	}
	img.UpdatedAt = time.Now()
	s.byID[img.ID] = img
	for _, p := range s.byShot[img.ShotID] {
		if p.ID == img.ID {
			*p = *img
			break
		}
	}
	for _, p := range s.byProject[img.ProjectID] {
		if p.ID == img.ID {
			*p = *img
			break
		}
	}
	return nil
}

func (s *MemShotImageStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	img, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	removeFromSlice := func(list []*ShotImage, targetID string) []*ShotImage {
		for i, e := range list {
			if e.ID == targetID {
				return append(list[:i], list[i+1:]...)
			}
		}
		return list
	}
	s.byShot[img.ShotID] = removeFromSlice(s.byShot[img.ShotID], id)
	s.byProject[img.ProjectID] = removeFromSlice(s.byProject[img.ProjectID], id)
	return nil
}

func (s *MemShotImageStore) DeleteByShot(shotID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	list := s.byShot[shotID]
	for _, img := range list {
		delete(s.byID, img.ID)
		s.byProject[img.ProjectID] = removeFromSlice(s.byProject[img.ProjectID], img.ID)
	}
	delete(s.byShot, shotID)
	return nil
}

func removeFromSlice(list []*ShotImage, targetID string) []*ShotImage {
	for i, e := range list {
		if e.ID == targetID {
			return append(list[:i], list[i+1:]...)
		}
	}
	return list
}
