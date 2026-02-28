package project

import (
	"errors"
	"sort"
	"strconv"
	"sync"
	"time"
)

// Data 数据访问层接口，使用 string ID 以兼容 PostgreSQL UUID
type Data interface {
	CreateProject(p *Project) error
	FindByID(id, userID string) (*Project, error)
	FindByIDOnly(id string) (*Project, error)
	ListByUser(userID string) ([]Project, error)
	UpdateProject(p *Project) error
	DeleteProject(id, userID string) error

	CreateMember(m *ProjectMember) error
	FindMemberByProjectAndUser(projectID, userID string) (*ProjectMember, error)
	ListMembersByProject(projectID string) ([]ProjectMember, error)
	UpdateMemberRole(projectID, userID string, role string) error
	DeleteMember(projectID, userID string) error
}

var (
	ErrProjectNotFound = errors.New("项目不存在")
	ErrMemberNotFound  = errors.New("成员不存在")
)

// MemData 内存实现，使用 "1","2" 等数字串作为 ID
type MemData struct {
	mu       sync.RWMutex
	projects map[string]*Project
	nextPID  uint

	members   map[string]*ProjectMember
	nextMID   uint
	projUsers map[string]map[string]bool // projectID -> userID set
}

// NewMemData 创建内存 Data 实例
func NewMemData() *MemData {
	return &MemData{
		projects:  make(map[string]*Project),
		nextPID:   1,
		members:   make(map[string]*ProjectMember),
		nextMID:   1,
		projUsers: make(map[string]map[string]bool),
	}
}

func (d *MemData) CreateProject(p *Project) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	now := time.Now()
	idStr := strconv.FormatUint(uint64(d.nextPID), 10)
	d.nextPID++
	p.ID = d.nextPID - 1
	p.IDStr = idStr
	if p.UserIDStr == "" {
		p.UserIDStr = strconv.FormatUint(uint64(p.UserID), 10)
	}
	p.CreatedAt = now
	p.UpdatedAt = now
	if p.Name == "" {
		p.Name = "Untitled"
	}

	d.projects[idStr] = cloneProject(p)
	return nil
}

func (d *MemData) FindByID(id, userID string) (*Project, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	p, ok := d.projects[id]
	if !ok {
		return nil, ErrProjectNotFound
	}
	if p.UserIDStr != userID && !d.isMember(id, userID) {
		return nil, ErrProjectNotFound
	}
	return cloneProject(p), nil
}

func (d *MemData) FindByIDOnly(id string) (*Project, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	p, ok := d.projects[id]
	if !ok {
		return nil, ErrProjectNotFound
	}
	return cloneProject(p), nil
}

func (d *MemData) ListByUser(userID string) ([]Project, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	var list []Project
	for _, p := range d.projects {
		if p.UserIDStr == userID || d.isMember(p.IDStr, userID) {
			list = append(list, *cloneProject(p))
		}
	}
	sort.Slice(list, func(i, j int) bool {
		return list[i].UpdatedAt.After(list[j].UpdatedAt)
	})
	return list, nil
}

func (d *MemData) UpdateProject(p *Project) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	key := p.IDStr
	if key == "" {
		key = strconv.FormatUint(uint64(p.ID), 10)
	}
	old, ok := d.projects[key]
	if !ok {
		return ErrProjectNotFound
	}
	p.UpdatedAt = time.Now()
	p.CreatedAt = old.CreatedAt
	d.projects[key] = cloneProject(p)
	return nil
}

func (d *MemData) DeleteProject(id, userID string) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	p, ok := d.projects[id]
	if !ok {
		return ErrProjectNotFound
	}
	if p.UserIDStr != userID {
		return ErrProjectNotFound
	}
	delete(d.projects, id)
	delete(d.projUsers, id)
	for mid, m := range d.members {
		if m.ProjectIDStr == id || strconv.FormatUint(uint64(m.ProjectID), 10) == id {
			delete(d.members, mid)
		}
	}
	return nil
}

func (d *MemData) CreateMember(m *ProjectMember) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	projKey := m.ProjectIDStr
	if projKey == "" {
		projKey = strconv.FormatUint(uint64(m.ProjectID), 10)
	}
	if _, ok := d.projects[projKey]; !ok {
		return ErrProjectNotFound
	}
	userKey := m.UserIDStr
	if userKey == "" {
		userKey = strconv.FormatUint(uint64(m.UserID), 10)
	}
	if d.findMemberUnlocked(projKey, userKey) != nil {
		return errors.New("成员已存在")
	}

	now := time.Now()
	midStr := strconv.FormatUint(uint64(d.nextMID), 10)
	d.nextMID++
	m.ID = d.nextMID - 1
	m.IDStr = midStr
	m.ProjectIDStr = projKey
	m.UserIDStr = userKey
	m.CreatedAt = now
	m.UpdatedAt = now
	d.members[midStr] = cloneMember(m)
	d.ensureProjUser(projKey, userKey)
	return nil
}

func (d *MemData) FindMemberByProjectAndUser(projectID, userID string) (*ProjectMember, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	m := d.findMemberUnlocked(projectID, userID)
	if m == nil {
		return nil, ErrMemberNotFound
	}
	return cloneMember(m), nil
}

func (d *MemData) ListMembersByProject(projectID string) ([]ProjectMember, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()

	var list []ProjectMember
	for _, m := range d.members {
		if m.ProjectIDStr == projectID || strconv.FormatUint(uint64(m.ProjectID), 10) == projectID {
			list = append(list, *cloneMember(m))
		}
	}
	sort.Slice(list, func(i, j int) bool { return list[i].Role < list[j].Role })
	return list, nil
}

func (d *MemData) UpdateMemberRole(projectID, userID string, role string) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	m := d.findMemberUnlocked(projectID, userID)
	if m == nil {
		return ErrMemberNotFound
	}
	m.Role = role
	m.UpdatedAt = time.Now()
	return nil
}

func (d *MemData) DeleteMember(projectID, userID string) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	m := d.findMemberUnlocked(projectID, userID)
	if m == nil {
		return ErrMemberNotFound
	}
	delete(d.members, m.IDStr)
	if m.IDStr == "" {
		delete(d.members, strconv.FormatUint(uint64(m.ID), 10))
	}
	if d.projUsers[projectID] != nil {
		delete(d.projUsers[projectID], userID)
	}
	return nil
}

func (d *MemData) findMemberUnlocked(projectID, userID string) *ProjectMember {
	for _, m := range d.members {
		mProj := m.ProjectIDStr
		if mProj == "" {
			mProj = strconv.FormatUint(uint64(m.ProjectID), 10)
		}
		mUser := m.UserIDStr
		if mUser == "" {
			mUser = strconv.FormatUint(uint64(m.UserID), 10)
		}
		if mProj == projectID && mUser == userID {
			return m
		}
	}
	return nil
}

func (d *MemData) isMember(projectID, userID string) bool {
	return d.findMemberUnlocked(projectID, userID) != nil
}

func (d *MemData) ensureProjUser(projectID, userID string) {
	if d.projUsers[projectID] == nil {
		d.projUsers[projectID] = make(map[string]bool)
	}
	d.projUsers[projectID][userID] = true
}

func cloneProject(p *Project) *Project {
	c := *p
	return &c
}

func cloneMember(m *ProjectMember) *ProjectMember {
	c := *m
	return &c
}
