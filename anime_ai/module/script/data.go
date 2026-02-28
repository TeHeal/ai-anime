package script

import (
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// SegmentStore 分段数据访问接口，sch 有 segments 表后可切换为 sqlc 实现
// 分段 ID 使用 string（UUID 格式）
type SegmentStore interface {
	Create(seg *Segment) error
	BulkCreate(segments []Segment) error
	FindByID(id string) (*Segment, error)
	ListByProject(projectID uint) ([]Segment, error)
	Update(seg *Segment) error
	Delete(id string) error
	DeleteByProject(projectID uint) error
	ReorderByProject(projectID uint, orderedIDs []string) error
}

// MemSegmentStore 内存占位实现，sch 无 segments 表时使用
type MemSegmentStore struct {
	mu      sync.RWMutex
	nextID  atomic.Uint64
	byID    map[string]*Segment
	byProj  map[uint][]*Segment
}

// NewMemSegmentStore 创建内存分段存储
func NewMemSegmentStore() *MemSegmentStore {
	return &MemSegmentStore{
		byID:   make(map[string]*Segment),
		byProj: make(map[uint][]*Segment),
	}
}

func (s *MemSegmentStore) Create(seg *Segment) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	id := strconv.FormatUint(s.nextID.Add(1), 10)
	seg.ID = id
	seg.CreatedAt = now
	seg.UpdatedAt = now
	c := *seg
	s.byID[id] = &c
	s.byProj[seg.ProjectID] = append(s.byProj[seg.ProjectID], &c)
	return nil
}

func (s *MemSegmentStore) BulkCreate(segments []Segment) error {
	if len(segments) == 0 {
		return nil
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	for i := range segments {
		id := strconv.FormatUint(s.nextID.Add(1), 10)
		seg := &Segment{
			ID:        id,
			ProjectID: segments[i].ProjectID,
			SortIndex: segments[i].SortIndex,
			Content:   segments[i].Content,
			CreatedAt: now,
			UpdatedAt: now,
		}
		s.byID[id] = seg
		s.byProj[seg.ProjectID] = append(s.byProj[seg.ProjectID], seg)
	}
	return nil
}

func (s *MemSegmentStore) FindByID(id string) (*Segment, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	seg, ok := s.byID[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	c := *seg
	return &c, nil
}

func (s *MemSegmentStore) ListByProject(projectID uint) ([]Segment, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	list := s.byProj[projectID]
	out := make([]Segment, len(list))
	for i, seg := range list {
		out[i] = *seg
	}
	return out, nil
}

func (s *MemSegmentStore) Update(seg *Segment) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	old, ok := s.byID[seg.ID]
	if !ok {
		return pkg.ErrNotFound
	}
	seg.CreatedAt = old.CreatedAt
	s.byID[seg.ID] = seg
	for i, p := range s.byProj[old.ProjectID] {
		if p.ID == seg.ID {
			s.byProj[old.ProjectID][i] = seg
			break
		}
	}
	return nil
}

func (s *MemSegmentStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	seg, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	list := s.byProj[seg.ProjectID]
	for i, e := range list {
		if e.ID == id {
			s.byProj[seg.ProjectID] = append(list[:i], list[i+1:]...)
			break
		}
	}
	return nil
}

func (s *MemSegmentStore) DeleteByProject(projectID uint) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, seg := range s.byProj[projectID] {
		delete(s.byID, seg.ID)
	}
	s.byProj[projectID] = nil
	return nil
}

func (s *MemSegmentStore) ReorderByProject(projectID uint, orderedIDs []string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	list := s.byProj[projectID]
	idToSeg := make(map[string]*Segment)
	for _, seg := range list {
		idToSeg[seg.ID] = seg
	}
	newList := make([]*Segment, 0, len(orderedIDs))
	for i, id := range orderedIDs {
		if seg, ok := idToSeg[id]; ok {
			seg.SortIndex = i
			newList = append(newList, seg)
		}
	}
	s.byProj[projectID] = newList
	return nil
}
