package shot

import (
	"sort"
	"strconv"
	"sync"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// ShotStore 镜头数据访问接口，sch 就绪后可切换为 sqlc 实现
// ID 使用 string（UUID），与 sch/db pgtype.UUID 互转
type ShotStore interface {
	Create(s *Shot) error
	BulkCreate(shots []Shot) error
	FindByID(id string) (*Shot, error)
	ListByProject(projectID string) ([]Shot, error)
	ListByProjectFiltered(projectID string, reviewStatus string) ([]Shot, error)
	Update(s *Shot) error
	Delete(id string) error
	CountByProject(projectID string) (int64, error)
	ReorderByProject(projectID string, orderedIDs []string) error
	BatchFindByIDs(ids []string) ([]Shot, error)
	UpdateImageURL(id string, imageURL string) error
	UpdateReviewStatus(id string, status, comment string) error
	BatchUpdateReviewStatus(ids []string, status string) error
	// 任务锁（README 2.3，超时 1h）
	TryLockShot(shotID, userID string) error
	UnlockShot(shotID, userID string) error
}

// MemShotStore 内存占位实现，ID 使用 string（兼容 UUID）
type MemShotStore struct {
	mu        sync.RWMutex
	nextID    uint
	byID      map[string]*Shot
	byProject map[string][]*Shot
}

// NewMemShotStore 创建内存镜头存储
func NewMemShotStore() *MemShotStore {
	return &MemShotStore{
		byID:      make(map[string]*Shot),
		byProject: make(map[string][]*Shot),
		nextID:    1,
	}
}

func (s *MemShotStore) Create(sh *Shot) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	id := strconv.FormatUint(uint64(s.nextID), 10)
	s.nextID++
	now := time.Now()
	sh.ID = id
	sh.CreatedAt = now
	sh.UpdatedAt = now
	if sh.Status == "" {
		sh.Status = StatusPending
	}
	cp := *sh
	s.byID[id] = &cp
	s.byProject[sh.ProjectID] = append(s.byProject[sh.ProjectID], &cp)
	return nil
}

func (s *MemShotStore) BulkCreate(shots []Shot) error {
	if len(shots) == 0 {
		return nil
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	for i := range shots {
		id := strconv.FormatUint(uint64(s.nextID), 10)
		s.nextID++
		sh := &shots[i]
		sh.ID = id
		sh.CreatedAt = now
		sh.UpdatedAt = now
		if sh.Status == "" {
			sh.Status = StatusPending
		}
		s.byID[id] = sh
		if sh.ProjectID != "" {
			s.byProject[sh.ProjectID] = append(s.byProject[sh.ProjectID], sh)
		}
	}
	return nil
}

func (s *MemShotStore) FindByID(id string) (*Shot, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	sh, ok := s.byID[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	cp := *sh
	return &cp, nil
}

func (s *MemShotStore) ListByProject(projectID string) ([]Shot, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	list := s.byProject[projectID]
	out := make([]Shot, len(list))
	for i, sh := range list {
		out[i] = *sh
	}
	sort.Slice(out, func(i, j int) bool { return out[i].SortIndex < out[j].SortIndex })
	return out, nil
}

func (s *MemShotStore) ListByProjectFiltered(projectID string, reviewStatus string) ([]Shot, error) {
	all, err := s.ListByProject(projectID)
	if err != nil {
		return nil, err
	}
	if reviewStatus == "" {
		return all, nil
	}
	out := make([]Shot, 0, len(all))
	for _, sh := range all {
		if sh.ReviewStatus == reviewStatus {
			out = append(out, sh)
		}
	}
	return out, nil
}

func (s *MemShotStore) Update(sh *Shot) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.byID[sh.ID]; !ok {
		return pkg.ErrNotFound
	}
	sh.UpdatedAt = time.Now()
	s.byID[sh.ID] = sh
	for _, p := range s.byProject[sh.ProjectID] {
		if p.ID == sh.ID {
			*p = *sh
			break
		}
	}
	return nil
}

func (s *MemShotStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	sh, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	delete(s.byID, id)
	list := s.byProject[sh.ProjectID]
	for i, e := range list {
		if e.ID == id {
			s.byProject[sh.ProjectID] = append(list[:i], list[i+1:]...)
			break
		}
	}
	return nil
}

func (s *MemShotStore) CountByProject(projectID string) (int64, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return int64(len(s.byProject[projectID])), nil
}

func (s *MemShotStore) ReorderByProject(projectID string, orderedIDs []string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	list := s.byProject[projectID]
	idToShot := make(map[string]*Shot)
	for _, sh := range list {
		idToShot[sh.ID] = sh
	}
	newList := make([]*Shot, 0, len(orderedIDs))
	for i, id := range orderedIDs {
		if sh, ok := idToShot[id]; ok {
			sh.SortIndex = i
			newList = append(newList, sh)
		}
	}
	s.byProject[projectID] = newList
	return nil
}

func (s *MemShotStore) BatchFindByIDs(ids []string) ([]Shot, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]Shot, 0, len(ids))
	for _, id := range ids {
		if sh, ok := s.byID[id]; ok {
			out = append(out, *sh)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].SortIndex < out[j].SortIndex })
	return out, nil
}

func (s *MemShotStore) UpdateImageURL(id string, imageURL string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	sh, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	sh.ImageURL = imageURL
	sh.UpdatedAt = time.Now()
	return nil
}

func (s *MemShotStore) UpdateReviewStatus(id string, status, comment string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	sh, ok := s.byID[id]
	if !ok {
		return pkg.ErrNotFound
	}
	sh.ReviewStatus = status
	sh.ReviewComment = comment
	now := time.Now()
	sh.ReviewedAt = &now
	sh.UpdatedAt = now
	return nil
}

func (s *MemShotStore) BatchUpdateReviewStatus(ids []string, status string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	for _, id := range ids {
		if sh, ok := s.byID[id]; ok {
			sh.ReviewStatus = status
			sh.ReviewedAt = &now
			sh.UpdatedAt = now
		}
	}
	return nil
}

// TryLockShot 内存模式无锁，仅校验镜头存在
func (s *MemShotStore) TryLockShot(shotID, userID string) error {
	_, err := s.FindByID(shotID)
	return err
}

// UnlockShot 内存模式无锁
func (s *MemShotStore) UnlockShot(shotID, userID string) error {
	return nil
}

// ShotReaderAdapter 实现 crossmodule.ShotReader，供 shot_image 模块注入
func ShotReaderAdapter(store ShotStore) crossmodule.ShotReader {
	return &shotReaderAdapter{store: store}
}

type shotReaderAdapter struct {
	store ShotStore
}

func (a *shotReaderAdapter) GetShot(shotID string) (projectID string, imageURL string, reviewStatus string, err error) {
	sh, err := a.store.FindByID(shotID)
	if err != nil {
		return "", "", "", err
	}
	return sh.ProjectID, sh.ImageURL, sh.ReviewStatus, nil
}

func (a *shotReaderAdapter) UpdateShotImage(shotID string, imageURL string) error {
	return a.store.UpdateImageURL(shotID, imageURL)
}

func (a *shotReaderAdapter) UpdateShotReview(shotID string, status, comment string) error {
	return a.store.UpdateReviewStatus(shotID, status, comment)
}

func (a *shotReaderAdapter) BatchUpdateShotReview(shotIDs []string, status string) error {
	return a.store.BatchUpdateReviewStatus(shotIDs, status)
}

// ShotLockerAdapter 实现 crossmodule.ShotLocker，供 shot_image、shot 模块注入
func ShotLockerAdapter(store ShotStore) crossmodule.ShotLocker {
	return &shotLockerAdapter{store: store}
}

type shotLockerAdapter struct {
	store ShotStore
}

func (a *shotLockerAdapter) TryLockShot(shotID, userID string) error {
	return a.store.TryLockShot(shotID, userID)
}

func (a *shotLockerAdapter) UnlockShot(shotID, userID string) error {
	return a.store.UnlockShot(shotID, userID)
}
