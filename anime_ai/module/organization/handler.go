package organization

import (
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 组织 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建组织
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req struct {
		Name      string `json:"name" binding:"required"`
		AvatarURL string `json:"avatarUrl"`
		Plan      string `json:"plan"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误: 组织名称为必填")
		return
	}
	org, err := h.svc.CreateOrg(c.Request.Context(), req.Name, req.AvatarURL, req.Plan, userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, org)
}

// List 列出用户所属组织
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	orgs, err := h.svc.ListOrgs(c.Request.Context(), userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"items": orgs})
}

// Get 获取组织详情
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	orgID := c.Param("orgId")
	if orgID == "" {
		pkg.BadRequest(c, "无效的组织 ID")
		return
	}
	org, err := h.svc.GetOrg(c.Request.Context(), orgID, userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, org)
}

// Update 更新组织信息
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	orgID := c.Param("orgId")
	if orgID == "" {
		pkg.BadRequest(c, "无效的组织 ID")
		return
	}
	var req struct {
		Name      *string `json:"name"`
		AvatarURL *string `json:"avatarUrl"`
		Plan      *string `json:"plan"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	org, err := h.svc.UpdateOrg(c.Request.Context(), orgID, userID, req.Name, req.AvatarURL, req.Plan)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, org)
}

// AddMember 添加组织成员
func (h *Handler) AddMember(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	orgID := c.Param("orgId")
	if orgID == "" {
		pkg.BadRequest(c, "无效的组织 ID")
		return
	}
	var req struct {
		UserID string `json:"userId" binding:"required"`
		Role   string `json:"role"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误: userId 为必填")
		return
	}
	member, err := h.svc.AddMember(c.Request.Context(), orgID, userID, req.UserID, req.Role)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, member)
}

// ListMembers 列出组织成员
func (h *Handler) ListMembers(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	orgID := c.Param("orgId")
	if orgID == "" {
		pkg.BadRequest(c, "无效的组织 ID")
		return
	}
	members, err := h.svc.ListMembers(c.Request.Context(), orgID, userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"items": members})
}

// RemoveMember 移除组织成员
func (h *Handler) RemoveMember(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	orgID := c.Param("orgId")
	targetUserID := c.Param("userId")
	if orgID == "" || targetUserID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	if err := h.svc.RemoveMember(c.Request.Context(), orgID, userID, targetUserID); err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}
