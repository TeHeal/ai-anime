package composite

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 成片 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建成片 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建成片任务
func (h *Handler) Create(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	task, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, task)
}

// Get 获取成片任务
func (h *Handler) Get(c *gin.Context) {
	id := c.Param("taskId")
	task, err := h.svc.Get(id)
	if err != nil {
		pkg.NotFound(c, "成片任务不存在")
		return
	}
	pkg.OK(c, task)
}

// List 列出项目成片任务
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	list, err := h.svc.List(projectID)
	if err != nil {
		pkg.InternalError(c, "获取成片列表失败")
		return
	}
	pkg.OK(c, list)
}

// UpdateTimeline 更新时间线
func (h *Handler) UpdateTimeline(c *gin.Context) {
	id := c.Param("taskId")
	var req UpdateTimelineRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.UpdateTimeline(id, req); err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"message": "时间线已更新"})
}

// Export 启动成片导出
func (h *Handler) Export(c *gin.Context) {
	id := c.Param("taskId")
	if err := h.svc.StartExport(id); err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"message": "导出已启动", "task_id": id})
}
