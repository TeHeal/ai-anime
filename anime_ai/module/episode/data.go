package episode

import (
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// EpisodeStore 集数据访问接口，使用 string projectID 以兼容 PostgreSQL UUID
type EpisodeStore interface {
	Create(ep *Episode) error
	FindByID(id string) (*Episode, error)
	ListByProject(projectID string) ([]Episode, error)
	Update(ep *Episode) error
	Delete(id string) error
	CountByProject(projectID string) (int64, error)
	ReorderByProject(projectID string, orderedIDs []string) error
}

// MemEpisodeStore 内存占位实现，使用 string ID
type MemEpisodeStore struct {
	mu      sync.RWMutex
	nextID  atomic.Uint64
	byID    map[string]*Episode
	byProj  map[string][]*Episode
}

// NewMemEpisodeStore 创建内存集存储
func NewMemEpisodeStore() *MemEpisodeStore {
	return &MemEpisodeStore{
		byID:   make(map[string]*Episode),
		byProj: make(map[string][]*Episode),
	}
}

func (s *MemEpisodeStore) Create(ep *Episode) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	id := uint(s.nextID.Add(1))
	idStr := strconv.FormatUint(uint64(id), 10)
	ep.ID = id
	ep.IDStr = idStr
	ep.ProjectIDStr = ep.ProjectIDStr
	if ep.ProjectIDStr == "" {
		ep.ProjectIDStr = strconv.FormatUint(uint64(ep.ProjectID), 10)
	}
	ep.CreatedAt = now
	ep.UpdatedAt = now
	if ep.Status == "" {
		ep.Status = EpisodeStatusNotStarted
	}
	if ep.CurrentPhase == "" {
		ep.CurrentPhase = "story"
	}
	s.byID[idStr] = ep
	s.byProj[ep.ProjectIDStr] = append(s.byProj[ep.ProjectIDStr], ep)
	return nil
}

func (s *MemEpisodeStore) FindByID(id string) (*Episode, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	ep, ok := s.byID[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	e := *ep
	return &e, nil
}

func (s *MemEpisodeStore) ListByProject(projectID string) ([]Episode, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	list := s.byProj[projectID]
	out := make([]Episode, len(list))
	for i, ep := range list {
		out[i] = *ep
	}
	return out, nil
}

func (s *MemEpisodeStore) Update(ep *Episode) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	key := ep.IDStr
	if key == "" {
		key = strconv.FormatUint(uint64(ep.ID), 10)
	}
	if _, ok := s.byID[key]; !ok {
		return pkg.ErrNotFound
	}
	s.byID[key] = ep
	return nil
}

func (s *MemEpisodeStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	ep, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	projKey := ep.ProjectIDStr
	if projKey == "" {
		projKey = strconv.FormatUint(uint64(ep.ProjectID), 10)
	}
	list := s.byProj[projKey]
	for i, e := range list {
		eKey := e.IDStr
		if eKey == "" {
			eKey = strconv.FormatUint(uint64(e.ID), 10)
		}
		if eKey == id {
			s.byProj[projKey] = append(list[:i], list[i+1:]...)
			break
		}
	}
	return nil
}

func (s *MemEpisodeStore) CountByProject(projectID string) (int64, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return int64(len(s.byProj[projectID])), nil
}

func (s *MemEpisodeStore) ReorderByProject(projectID string, orderedIDs []string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	list := s.byProj[projectID]
	idToEp := make(map[string]*Episode)
	for _, ep := range list {
		k := ep.IDStr
		if k == "" {
			k = strconv.FormatUint(uint64(ep.ID), 10)
		}
		idToEp[k] = ep
	}
	newList := make([]*Episode, 0, len(orderedIDs))
	for _, id := range orderedIDs {
		if ep, ok := idToEp[id]; ok {
			ep.SortIndex = len(newList)
			newList = append(newList, ep)
		}
	}
	s.byProj[projectID] = newList
	return nil
}

// EpisodeReaderAdapter 实现 crossmodule.EpisodeReader，供 scene 模块注入
func EpisodeReaderAdapter(store EpisodeStore) crossmodule.EpisodeReader {
	return &episodeReaderAdapter{store: store}
}

type episodeReaderAdapter struct {
	store EpisodeStore
}

func (a *episodeReaderAdapter) GetProjectIDByEpisode(episodeID string) (string, error) {
	ep, err := a.store.FindByID(episodeID)
	if err != nil {
		return "", err
	}
	if ep.ProjectIDStr != "" {
		return ep.ProjectIDStr, nil
	}
	return strconv.FormatUint(uint64(ep.ProjectID), 10), nil
}
