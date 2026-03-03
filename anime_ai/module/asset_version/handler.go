package asset_version

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 资产版本 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// List 列出项目资产版本
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	if limit <= 0 {
		limit = 50
	}
	if offset < 0 {
		offset = 0
	}
	list, err := h.svc.List(c.Request.Context(), projectID, limit, offset)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, list)
}

// Freeze 冻结资产
func (h *Handler) Freeze(c *gin.Context) {
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	av, err := h.svc.Freeze(c.Request.Context(), projectID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, av)
}

// Unfreeze 解冻资产
func (h *Handler) Unfreeze(c *gin.Context) {
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	if err := h.svc.Unfreeze(c.Request.Context(), projectID); err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}
