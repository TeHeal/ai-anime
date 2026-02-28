package auth

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 认证 HTTP 接口层
type Handler struct {
	authSvc *AuthService
}

// NewHandler 创建认证 Handler
func NewHandler(authSvc *AuthService) *Handler {
	return &Handler{authSvc: authSvc}
}

// Login 登录接口
func (h *Handler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请提供用户名和密码")
		return
	}

	resp, err := h.authSvc.Login(req)
	if err != nil {
		pkg.Unauthorized(c, err.Error())
		return
	}

	pkg.OK(c, resp)
}

// ChangePassword 修改密码接口
func (h *Handler) ChangePassword(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	var req ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.authSvc.ChangePassword(userID, req); err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "密码修改成功"})
}

// CreateUser 创建新用户接口（需管理员权限）
func (h *Handler) CreateUser(c *gin.Context) {
	var req CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	user, err := h.authSvc.CreateUser(req)
	if err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.Created(c, user)
}

// ListUsers 列出所有用户接口（需管理员权限）
func (h *Handler) ListUsers(c *gin.Context) {
	users, err := h.authSvc.ListUsers()
	if err != nil {
		pkg.InternalError(c, "获取用户列表失败")
		return
	}
	pkg.OK(c, users)
}

// DeleteUser 删除用户接口（需管理员权限）
func (h *Handler) DeleteUser(c *gin.Context) {
	id := c.Param("userId")
	if id == "" {
		pkg.BadRequest(c, "缺少用户 ID")
		return
	}
	if err := h.authSvc.DeleteUser(id); err != nil {
		pkg.NotFound(c, "用户不存在")
		return
	}
	pkg.OK(c, gin.H{"message": "用户已删除"})
}

// Me 获取当前用户信息
func (h *Handler) Me(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}

	user, err := h.authSvc.GetCurrentUser(userID)
	if err != nil {
		pkg.NotFound(c, "用户不存在")
		return
	}

	pkg.OK(c, user)
}
