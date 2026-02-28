package auth

import (
	"strconv"
	"sync"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// UserStore 用户数据访问接口，使用 string ID 以兼容 PostgreSQL UUID
type UserStore interface {
	FindByUsername(username string) (*User, error)
	FindByID(id string) (*User, error)
	Update(user *User) error
	Create(user *User) (*User, error)
	List() ([]*User, error)
	Delete(id string) error
}

// BootstrapUserStore 基于配置的引导用户存储，用于无 DB 时的开发/演示
// 仅支持单个 admin 用户，密码从配置读取并哈希存储
type BootstrapUserStore struct {
	mu    sync.RWMutex
	user  *User
	users map[string]*User // 多用户支持
}

// NewBootstrapUserStore 创建引导存储，adminPassword 为明文，内部会哈希
func NewBootstrapUserStore(adminUsername, adminPassword string) (*BootstrapUserStore, error) {
	hash, err := pkg.HashPassword(adminPassword)
	if err != nil {
		return nil, err
	}
	return &BootstrapUserStore{
		user: &User{
			ID:     1,
			IDStr:  "1",
			Username: adminUsername,
			PasswordHash: hash,
			DisplayName:  adminUsername,
			Role:         "admin",
		},
	}, nil
}

func (s *BootstrapUserStore) FindByUsername(username string) (*User, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if s.users != nil {
		if u, ok := s.users[username]; ok {
			cp := *u
			return &cp, nil
		}
		return nil, pkg.ErrNotFound
	}
	if s.user == nil || s.user.Username != username {
		return nil, pkg.ErrNotFound
	}
	u := *s.user
	return &u, nil
}

func (s *BootstrapUserStore) FindByID(id string) (*User, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if s.users != nil {
		for _, u := range s.users {
			if u.IDStr == id {
				cp := *u
				return &cp, nil
			}
		}
		return nil, pkg.ErrNotFound
	}
	if s.user == nil {
		return nil, pkg.ErrNotFound
	}
	if s.user.IDStr != id && !(id == "1" && s.user.ID == 1) {
		return nil, pkg.ErrNotFound
	}
	u := *s.user
	return &u, nil
}

func (s *BootstrapUserStore) Update(user *User) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	idMatch := s.user != nil && (s.user.ID == user.ID || s.user.IDStr == user.IDStr)
	if s.user == nil || !idMatch {
		return pkg.ErrNotFound
	}
	s.user.PasswordHash = user.PasswordHash
	s.user.DisplayName = user.DisplayName
	s.user.Role = user.Role
	return nil
}

// BootstrapUserStore 内存多用户支持
var bootstrapNextID uint = 2

func (s *BootstrapUserStore) Create(user *User) (*User, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.users == nil {
		s.users = make(map[string]*User)
		s.users[s.user.Username] = s.user
	}
	if _, exists := s.users[user.Username]; exists {
		return nil, pkg.ErrAlreadyExists
	}
	user.ID = bootstrapNextID
	user.IDStr = strconv.FormatUint(uint64(bootstrapNextID), 10)
	bootstrapNextID++
	u := *user
	s.users[user.Username] = &u
	return &u, nil
}

func (s *BootstrapUserStore) List() ([]*User, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if s.users == nil {
		return []*User{s.user}, nil
	}
	list := make([]*User, 0, len(s.users))
	for _, u := range s.users {
		cp := *u
		list = append(list, &cp)
	}
	return list, nil
}

func (s *BootstrapUserStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.users == nil {
		return pkg.ErrNotFound
	}
	for k, u := range s.users {
		if u.IDStr == id {
			delete(s.users, k)
			return nil
		}
	}
	return pkg.ErrNotFound
}
