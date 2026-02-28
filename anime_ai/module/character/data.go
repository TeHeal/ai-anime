package character

import (
	"sort"
	"strconv"
	"sync"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// Data 数据访问层接口，sch 就绪后可替换为 sqlc 实现
// 角色 ID 使用 string（UUID 格式），与 pgtype.UUID 兼容
type Data interface {
	// 角色 CRUD
	CreateCharacter(c *Character) error
	FindCharacterByID(id string) (*Character, error)
	ListCharactersByProject(projectID uint) ([]Character, error)
	ListCharactersByUser(userID uint, includeShared bool) ([]Character, error)
	UpdateCharacter(c *Character) error
	DeleteCharacter(id string) error
	UpdateCharacterImage(id string, imageURL, taskID, status string) error

	// 角色快照 CRUD（character_snapshots 表若不存在则用 MemData）
	CreateSnapshot(s *CharacterSnapshot) error
	FindSnapshotByID(id uint) (*CharacterSnapshot, error)
	ListSnapshotsByCharacter(characterID string) ([]CharacterSnapshot, error)
	ListSnapshotsByProject(projectID uint) ([]CharacterSnapshot, error)
	UpdateSnapshot(s *CharacterSnapshot) error
	DeleteSnapshot(id uint) error
}

// MemData 内存实现，sch 未就绪时使用
type MemData struct {
	mu       sync.RWMutex
	chars    map[string]*Character
	nextCID  uint

	snapshots map[uint]*CharacterSnapshot
	nextSID   uint
}

// NewMemData 创建内存 Data 实例
func NewMemData() *MemData {
	return &MemData{
		chars:     make(map[string]*Character),
		nextCID:   1,
		snapshots: make(map[uint]*CharacterSnapshot),
		nextSID:   1,
	}
}

func (d *MemData) CreateCharacter(c *Character) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	now := time.Now()
	c.ID = strconv.FormatUint(uint64(d.nextCID), 10)
	d.nextCID++
	c.CreatedAt = now
	c.UpdatedAt = now
	if c.Status == "" {
		c.Status = CharacterStatusDraft
	}
	if c.Source == "" {
		c.Source = CharacterSourceManual
	}
	if c.ImageStatus == "" {
		c.ImageStatus = "none"
	}
	if c.ImageURL != "" {
		c.ImageStatus = "completed"
	}
	d.chars[c.ID] = cloneCharacter(c)
	return nil
}

func (d *MemData) FindCharacterByID(id string) (*Character, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	c, ok := d.chars[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	return cloneCharacter(c), nil
}

func (d *MemData) ListCharactersByProject(projectID uint) ([]Character, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	// 兼容 UUID 格式与简单数字格式
	pid := strconv.FormatUint(uint64(projectID), 10)
	var list []Character
	for _, c := range d.chars {
		if c.ProjectID != nil && (*c.ProjectID == pid || *c.ProjectID == pkg.UUIDString(pkg.UintToUUID(projectID))) {
			list = append(list, *cloneCharacter(c))
		}
	}
	sort.Slice(list, func(i, j int) bool {
		return list[i].CreatedAt.Before(list[j].CreatedAt)
	})
	return list, nil
}

func (d *MemData) ListCharactersByUser(userID uint, includeShared bool) ([]Character, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	uid := strconv.FormatUint(uint64(userID), 10)
	uidUUID := pkg.UUIDString(pkg.UintToUUID(userID))
	var list []Character
	for _, c := range d.chars {
		if c.UserID == uid || c.UserID == uidUUID || (includeShared && c.Shared) {
			list = append(list, *cloneCharacter(c))
		}
	}
	sort.Slice(list, func(i, j int) bool {
		return list[i].UpdatedAt.After(list[j].UpdatedAt)
	})
	return list, nil
}

func (d *MemData) UpdateCharacter(c *Character) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	old, ok := d.chars[c.ID]
	if !ok {
		return pkg.ErrNotFound
	}
	c.UpdatedAt = time.Now()
	c.CreatedAt = old.CreatedAt
	d.chars[c.ID] = cloneCharacter(c)
	return nil
}

func (d *MemData) DeleteCharacter(id string) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	if _, ok := d.chars[id]; !ok {
		return pkg.ErrNotFound
	}
	delete(d.chars, id)
	// 删除该角色下所有快照
	for sid, s := range d.snapshots {
		if s.CharacterID == id {
			delete(d.snapshots, sid)
		}
	}
	return nil
}

func (d *MemData) UpdateCharacterImage(id string, imageURL, taskID, status string) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	c, ok := d.chars[id]
	if !ok {
		return pkg.ErrNotFound
	}
	c.ImageURL = imageURL
	c.TaskID = taskID
	c.ImageStatus = status
	c.UpdatedAt = time.Now()
	return nil
}

func (d *MemData) CreateSnapshot(s *CharacterSnapshot) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	now := time.Now()
	s.ID = d.nextSID
	d.nextSID++
	s.CreatedAt = now
	s.UpdatedAt = now
	if s.Source == "" {
		s.Source = "human"
	}
	d.snapshots[s.ID] = cloneSnapshot(s)
	return nil
}

func (d *MemData) FindSnapshotByID(id uint) (*CharacterSnapshot, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	s, ok := d.snapshots[id]
	if !ok {
		return nil, pkg.ErrNotFound
	}
	return cloneSnapshot(s), nil
}

func (d *MemData) ListSnapshotsByCharacter(characterID string) ([]CharacterSnapshot, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	var list []CharacterSnapshot
	for _, s := range d.snapshots {
		if s.CharacterID == characterID {
			list = append(list, *cloneSnapshot(s))
		}
	}
	sort.Slice(list, func(i, j int) bool {
		return list[i].SortIndex < list[j].SortIndex
	})
	return list, nil
}

func (d *MemData) ListSnapshotsByProject(projectID uint) ([]CharacterSnapshot, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	var list []CharacterSnapshot
	for _, s := range d.snapshots {
		if s.ProjectID == projectID {
			list = append(list, *cloneSnapshot(s))
		}
	}
	sort.Slice(list, func(i, j int) bool {
		if list[i].CharacterID != list[j].CharacterID {
			return list[i].CharacterID < list[j].CharacterID
		}
		return list[i].SortIndex < list[j].SortIndex
	})
	return list, nil
}

func (d *MemData) UpdateSnapshot(s *CharacterSnapshot) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	old, ok := d.snapshots[s.ID]
	if !ok {
		return pkg.ErrNotFound
	}
	s.UpdatedAt = time.Now()
	s.CreatedAt = old.CreatedAt
	d.snapshots[s.ID] = cloneSnapshot(s)
	return nil
}

func (d *MemData) DeleteSnapshot(id uint) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	if _, ok := d.snapshots[id]; !ok {
		return pkg.ErrNotFound
	}
	delete(d.snapshots, id)
	return nil
}

func cloneCharacter(c *Character) *Character {
	x := *c
	return &x
}

func cloneSnapshot(s *CharacterSnapshot) *CharacterSnapshot {
	x := *s
	return &x
}
