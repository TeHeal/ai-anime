package team

import (
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 团队 HTTP 接口层
type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建团队
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	if orgID == "" {
		pkg.BadRequest(c, "无效的组织 ID")
		return
	}
	var req struct {
		Name        string `json:"name" binding:"required"`
		Description string `json:"description"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误: 团队名称为必填")
		return
	}
	t, err := h.svc.CreateTeam(c.Request.Context(), orgID, userID, req.Name, req.Description)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, t)
}

// List 列出组织下团队
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	if orgID == "" {
		pkg.BadRequest(c, "无效的组织 ID")
		return
	}
	teams, err := h.svc.ListTeams(c.Request.Context(), orgID, userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"items": teams})
}

// Get 获取团队详情
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	teamID := c.Param("teamId")
	if orgID == "" || teamID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	t, err := h.svc.GetTeam(c.Request.Context(), orgID, teamID, userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, t)
}

// Update 更新团队信息
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	teamID := c.Param("teamId")
	if orgID == "" || teamID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	var req struct {
		Name        *string `json:"name"`
		Description *string `json:"description"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	t, err := h.svc.UpdateTeam(c.Request.Context(), orgID, teamID, userID, req.Name, req.Description)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, t)
}

// Delete 删除团队
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	teamID := c.Param("teamId")
	if orgID == "" || teamID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	if err := h.svc.DeleteTeam(c.Request.Context(), orgID, teamID, userID); err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}

// AddMember 添加团队成员
func (h *Handler) AddMember(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	teamID := c.Param("teamId")
	if orgID == "" || teamID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	var req struct {
		UserID   string   `json:"userId" binding:"required"`
		Role     string   `json:"role"`
		JobRoles []string `json:"jobRoles"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误: userId 为必填")
		return
	}
	m, err := h.svc.AddMember(c.Request.Context(), orgID, teamID, userID, req.UserID, req.Role, req.JobRoles)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, m)
}

// ListMembers 列出团队成员
func (h *Handler) ListMembers(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	teamID := c.Param("teamId")
	if orgID == "" || teamID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	members, err := h.svc.ListMembers(c.Request.Context(), orgID, teamID, userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"items": members})
}

// UpdateMember 更新团队成员
func (h *Handler) UpdateMember(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	teamID := c.Param("teamId")
	targetUserID := c.Param("userId")
	if orgID == "" || teamID == "" || targetUserID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	var req struct {
		Role     *string  `json:"role"`
		JobRoles []string `json:"jobRoles"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	m, err := h.svc.UpdateMember(c.Request.Context(), orgID, teamID, userID, targetUserID, req.Role, req.JobRoles)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, m)
}

// RemoveMember 移除团队成员
func (h *Handler) RemoveMember(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	orgID := c.Param("orgId")
	teamID := c.Param("teamId")
	targetUserID := c.Param("userId")
	if orgID == "" || teamID == "" || targetUserID == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	if err := h.svc.RemoveMember(c.Request.Context(), orgID, teamID, userID, targetUserID); err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}
