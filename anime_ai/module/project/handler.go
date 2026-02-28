package project

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 项目管理 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建项目
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)

	var req CreateProjectRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	p, err := h.svc.Create(userID, req)
	if err != nil {
		pkg.InternalError(c, "创建项目失败")
		return
	}

	pkg.Created(c, p.ToResponse())
}

// Get 获取项目详情
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("id")
	if id == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	p, err := h.svc.GetByID(id, userID)
	if err != nil {
		pkg.NotFound(c, "项目不存在")
		return
	}

	pkg.OK(c, p.ToResponse())
}

// List 获取项目列表
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)

	projects, err := h.svc.List(userID)
	if err != nil {
		pkg.InternalError(c, "获取项目列表失败")
		return
	}

	results := make([]ProjectResponse, len(projects))
	for i := range projects {
		results[i] = projects[i].ToResponse()
	}

	pkg.OK(c, results)
}

// Update 更新项目
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("id")
	if id == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	var req UpdateProjectRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	p, err := h.svc.Update(id, userID, req)
	if err != nil {
		pkg.NotFound(c, "项目不存在")
		return
	}

	pkg.OK(c, p.ToResponse())
}

// Delete 删除项目
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("id")
	if id == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	if err := h.svc.Delete(id, userID); err != nil {
		pkg.NotFound(c, "项目不存在")
		return
	}

	pkg.OK(c, nil)
}

// GetProps 获取项目 props
func (h *Handler) GetProps(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("id")
	if id == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	props, err := h.svc.GetProps(id, userID)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"props": props})
}

// UpdateProps 更新项目 props
func (h *Handler) UpdateProps(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("id")
	if id == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	var req struct {
		Props []map[string]interface{} `json:"props"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.UpdateProps(id, userID, req.Props); err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}

// ListMembers 获取项目成员列表
func (h *Handler) ListMembers(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	members, err := h.svc.ListMembers(projectID, userID)
	if err != nil {
		pkg.NotFound(c, "项目不存在")
		return
	}

	pkg.OK(c, members)
}

// AddMember 添加项目成员
func (h *Handler) AddMember(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	var req AddMemberRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	m, err := h.svc.AddMember(projectID, userID, req)
	if err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}

	pkg.Created(c, m)
}

// UpdateMemberRole 更新成员角色
func (h *Handler) UpdateMemberRole(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := c.Param("id")
	memberUserID := c.Param("userId")
	if projectID == "" || memberUserID == "" {
		pkg.BadRequest(c, "无效的 ID")
		return
	}

	var req UpdateMemberRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	if err := h.svc.UpdateMemberRole(projectID, userID, memberUserID, req.Role); err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}

	pkg.OK(c, gin.H{"message": "ok"})
}

// RemoveMember 移除项目成员
func (h *Handler) RemoveMember(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := c.Param("id")
	memberUserID := c.Param("userId")
	if projectID == "" || memberUserID == "" {
		pkg.BadRequest(c, "无效的 ID")
		return
	}

	if err := h.svc.RemoveMember(projectID, userID, memberUserID); err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}

	pkg.OK(c, nil)
}
