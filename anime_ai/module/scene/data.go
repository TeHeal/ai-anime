package scene

import (
	"sync"
	"sync/atomic"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/google/uuid"
)

// SceneStore 场数据访问接口，使用 string ID 以兼容 PostgreSQL UUID
type SceneStore interface {
	Create(s *Scene) error
	FindByID(id string) (*Scene, error)
	ListByEpisode(episodeID string) ([]Scene, error)
	Update(s *Scene) error
	Delete(id string) error
	CountByEpisode(episodeID string) (int64, error)
	ReorderByEpisode(episodeID string, orderedIDs []string) error
}

// SceneBlockStore 块数据访问接口，使用 string ID 以兼容 PostgreSQL UUID
type SceneBlockStore interface {
	Create(b *SceneBlock) error
	BulkCreate(blocks []SceneBlock) error
	FindByID(id string) (*SceneBlock, error)
	ListByScene(sceneID string) ([]SceneBlock, error)
	Update(b *SceneBlock) error
	Delete(id string) error
	DeleteByScene(sceneID string) error
	CountByScene(sceneID string) (int64, error)
	ReorderByScene(sceneID string, orderedIDs []string) error
}

// MemSceneStore 内存占位实现，使用 string ID (UUID)
type MemSceneStore struct {
	mu        sync.RWMutex
	nextID    atomic.Uint64
	byID      map[string]*Scene
	byEpisode map[string][]*Scene
}

// NewMemSceneStore 创建内存场存储
func NewMemSceneStore() *MemSceneStore {
	return &MemSceneStore{
		byID:      make(map[string]*Scene),
		byEpisode: make(map[string][]*Scene),
	}
}

func (s *MemSceneStore) Create(sc *Scene) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	id := uuid.New().String()
	now := time.Now()
	sc.ID = id
	sc.CreatedAt = now
	sc.UpdatedAt = now
	s.byID[id] = sc
	s.byEpisode[sc.EpisodeID] = append(s.byEpisode[sc.EpisodeID], sc)
	return nil
}

func (s *MemSceneStore) FindByID(id string) (*Scene, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	sc, ok := s.byID[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	cp := *sc
	return &cp, nil
}

func (s *MemSceneStore) ListByEpisode(episodeID string) ([]Scene, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	list := s.byEpisode[episodeID]
	out := make([]Scene, len(list))
	for i, sc := range list {
		out[i] = *sc
	}
	return out, nil
}

func (s *MemSceneStore) Update(sc *Scene) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.byID[sc.ID]; !ok {
		return pkg.ErrNotFound
	}
	sc.UpdatedAt = time.Now()
	s.byID[sc.ID] = sc
	return nil
}

func (s *MemSceneStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	sc, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	list := s.byEpisode[sc.EpisodeID]
	for i, e := range list {
		if e.ID == id {
			s.byEpisode[sc.EpisodeID] = append(list[:i], list[i+1:]...)
			break
		}
	}
	return nil
}

func (s *MemSceneStore) CountByEpisode(episodeID string) (int64, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return int64(len(s.byEpisode[episodeID])), nil
}

func (s *MemSceneStore) ReorderByEpisode(episodeID string, orderedIDs []string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	list := s.byEpisode[episodeID]
	idToSc := make(map[string]*Scene)
	for _, sc := range list {
		idToSc[sc.ID] = sc
	}
	newList := make([]*Scene, 0, len(orderedIDs))
	for _, id := range orderedIDs {
		if sc, ok := idToSc[id]; ok {
			sc.SortIndex = len(newList)
			newList = append(newList, sc)
		}
	}
	s.byEpisode[episodeID] = newList
	return nil
}

// MemSceneBlockStore 内存块存储，使用 string ID (UUID)
type MemSceneBlockStore struct {
	mu      sync.RWMutex
	nextID  atomic.Uint64
	byID    map[string]*SceneBlock
	byScene map[string][]*SceneBlock
}

// NewMemSceneBlockStore 创建内存块存储
func NewMemSceneBlockStore() *MemSceneBlockStore {
	return &MemSceneBlockStore{
		byID:    make(map[string]*SceneBlock),
		byScene: make(map[string][]*SceneBlock),
	}
}

func (s *MemSceneBlockStore) Create(b *SceneBlock) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	id := uuid.New().String()
	now := time.Now()
	b.ID = id
	b.CreatedAt = now
	b.UpdatedAt = now
	s.byID[id] = b
	s.byScene[b.SceneID] = append(s.byScene[b.SceneID], b)
	return nil
}

func (s *MemSceneBlockStore) BulkCreate(blocks []SceneBlock) error {
	if len(blocks) == 0 {
		return nil
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	for i := range blocks {
		id := uuid.New().String()
		b := &blocks[i]
		b.ID = id
		b.CreatedAt = now
		b.UpdatedAt = now
		s.byID[id] = b
		s.byScene[b.SceneID] = append(s.byScene[b.SceneID], b)
	}
	return nil
}

func (s *MemSceneBlockStore) FindByID(id string) (*SceneBlock, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	b, ok := s.byID[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	cp := *b
	return &cp, nil
}

func (s *MemSceneBlockStore) ListByScene(sceneID string) ([]SceneBlock, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	list := s.byScene[sceneID]
	out := make([]SceneBlock, len(list))
	for i, b := range list {
		out[i] = *b
	}
	return out, nil
}

func (s *MemSceneBlockStore) Update(b *SceneBlock) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.byID[b.ID]; !ok {
		return pkg.ErrNotFound
	}
	b.UpdatedAt = time.Now()
	s.byID[b.ID] = b
	return nil
}

func (s *MemSceneBlockStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	b, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	list := s.byScene[b.SceneID]
	for i, e := range list {
		if e.ID == id {
			s.byScene[b.SceneID] = append(list[:i], list[i+1:]...)
			break
		}
	}
	return nil
}

func (s *MemSceneBlockStore) DeleteByScene(sceneID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	list := s.byScene[sceneID]
	for _, b := range list {
		delete(s.byID, b.ID)
	}
	delete(s.byScene, sceneID)
	return nil
}

func (s *MemSceneBlockStore) CountByScene(sceneID string) (int64, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return int64(len(s.byScene[sceneID])), nil
}

func (s *MemSceneBlockStore) ReorderByScene(sceneID string, orderedIDs []string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	list := s.byScene[sceneID]
	idToB := make(map[string]*SceneBlock)
	for _, b := range list {
		idToB[b.ID] = b
	}
	newList := make([]*SceneBlock, 0, len(orderedIDs))
	for _, id := range orderedIDs {
		if b, ok := idToB[id]; ok {
			b.SortIndex = len(newList)
			newList = append(newList, b)
		}
	}
	s.byScene[sceneID] = newList
	return nil
}
