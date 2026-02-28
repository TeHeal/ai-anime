package style

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 风格资产 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建风格 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建风格
func (h *Handler) Create(c *gin.Context) {
	projectID := c.Param("id")
	var req CreateStyleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	s, err := h.svc.Create(projectID, req)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, s)
}

// List 列出项目风格
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	list, err := h.svc.List(projectID)
	if err != nil {
		pkg.InternalError(c, "获取风格列表失败")
		return
	}
	pkg.OK(c, list)
}

// Get 获取风格详情
func (h *Handler) Get(c *gin.Context) {
	id := c.Param("styleId")
	s, err := h.svc.Get(id)
	if err != nil {
		pkg.NotFound(c, "风格不存在")
		return
	}
	pkg.OK(c, s)
}

// Update 更新风格
func (h *Handler) Update(c *gin.Context) {
	id := c.Param("styleId")
	var req UpdateStyleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	s, err := h.svc.Update(id, req)
	if err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.OK(c, s)
}

// Delete 删除风格
func (h *Handler) Delete(c *gin.Context) {
	id := c.Param("styleId")
	if err := h.svc.Delete(id); err != nil {
		pkg.NotFound(c, "风格不存在")
		return
	}
	pkg.OK(c, gin.H{"message": "已删除"})
}
