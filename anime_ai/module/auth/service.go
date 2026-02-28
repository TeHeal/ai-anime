package auth

import (
	"errors"
	"strconv"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// AuthService 认证业务逻辑
type AuthService struct {
	userStore UserStore
	jwtSecret string
}

// NewAuthService 创建认证服务
func NewAuthService(userStore UserStore, jwtSecret string) *AuthService {
	return &AuthService{userStore: userStore, jwtSecret: jwtSecret}
}

// LoginRequest 登录请求
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse 登录响应
type LoginResponse struct {
	Token string `json:"token"`
	User  *User  `json:"user"`
}

// Login 登录，校验密码并返回 JWT
func (s *AuthService) Login(req LoginRequest) (*LoginResponse, error) {
	user, err := s.userStore.FindByUsername(req.Username)
	if err != nil {
		return nil, errors.New("用户名或密码错误")
	}

	if !pkg.CheckPassword(req.Password, user.PasswordHash) {
		return nil, errors.New("用户名或密码错误")
	}

	userID := user.IDStr
	if userID == "" {
		userID = strconv.FormatUint(uint64(user.ID), 10)
	}
	token, err := pkg.GenerateToken(s.jwtSecret, userID, user.Username, user.Role, 7*24*time.Hour)
	if err != nil {
		return nil, errors.New("生成 Token 失败")
	}

	return &LoginResponse{Token: token, User: user}, nil
}

// GetCurrentUser 获取当前登录用户
func (s *AuthService) GetCurrentUser(userID string) (*User, error) {
	return s.userStore.FindByID(userID)
}

// ChangePasswordRequest 修改密码请求
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

// ChangePassword 修改密码
func (s *AuthService) ChangePassword(userID string, req ChangePasswordRequest) error {
	user, err := s.userStore.FindByID(userID)
	if err != nil {
		return errors.New("用户不存在")
	}
	if !pkg.CheckPassword(req.OldPassword, user.PasswordHash) {
		return errors.New("当前密码错误")
	}
	hash, err := pkg.HashPassword(req.NewPassword)
	if err != nil {
		return errors.New("密码加密失败")
	}
	user.PasswordHash = hash
	return s.userStore.Update(user)
}
