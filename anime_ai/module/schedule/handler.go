package schedule

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 调度任务 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建调度 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建定时任务
func (h *Handler) Create(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	sch, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, sch)
}

// List 列出项目调度任务
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	list, err := h.svc.List(projectID)
	if err != nil {
		pkg.InternalError(c, "获取调度列表失败")
		return
	}
	pkg.OK(c, list)
}

// Get 获取调度任务
func (h *Handler) Get(c *gin.Context) {
	id := c.Param("schedId")
	sch, err := h.svc.Get(id)
	if err != nil {
		pkg.NotFound(c, "调度任务不存在")
		return
	}
	pkg.OK(c, sch)
}

// Update 更新调度任务
func (h *Handler) Update(c *gin.Context) {
	id := c.Param("schedId")
	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	sch, err := h.svc.Update(id, req)
	if err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.OK(c, sch)
}

// Delete 删除调度任务
func (h *Handler) Delete(c *gin.Context) {
	id := c.Param("schedId")
	if err := h.svc.Delete(id); err != nil {
		pkg.NotFound(c, "调度任务不存在")
		return
	}
	pkg.OK(c, gin.H{"message": "已删除"})
}
