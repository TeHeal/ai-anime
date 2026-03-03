package style

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 风格 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// List 列出项目风格
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || userID == "" {
		pkg.BadRequest(c, "无效的项目 ID 或用户")
		return
	}
	styles, err := h.svc.List(projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, styles)
}

// Create 创建风格
func (h *Handler) Create(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || userID == "" {
		pkg.BadRequest(c, "无效的项目 ID 或用户")
		return
	}
	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	st, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, st)
}

// Get 获取风格详情
func (h *Handler) Get(c *gin.Context) {
	projectID := c.Param("id")
	styleID := c.Param("styleId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || styleID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}
	st, err := h.svc.Get(styleID, projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "风格不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, st)
}

// Update 更新风格
func (h *Handler) Update(c *gin.Context) {
	projectID := c.Param("id")
	styleID := c.Param("styleId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || styleID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}
	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	st, err := h.svc.Update(styleID, projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "风格不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, st)
}

// Delete 删除风格
func (h *Handler) Delete(c *gin.Context) {
	projectID := c.Param("id")
	styleID := c.Param("styleId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || styleID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}
	if err := h.svc.Delete(styleID, projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "风格不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, nil)
}

// ApplyAll 将风格应用到所有资产
func (h *Handler) ApplyAll(c *gin.Context) {
	projectID := c.Param("id")
	styleID := c.Param("styleId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || styleID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}
	count, err := h.svc.ApplyAll(styleID, projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "风格不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"applied": count, "message": "已应用到所有资产"})
}
