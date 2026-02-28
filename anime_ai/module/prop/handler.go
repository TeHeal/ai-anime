package prop

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 道具资产 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建道具
func (h *Handler) Create(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || userID == "" {
		pkg.BadRequest(c, "无效的项目 ID 或用户")
		return
	}

	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	p, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, p)
}

// List 列出项目道具
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || userID == "" {
		pkg.BadRequest(c, "无效的项目 ID 或用户")
		return
	}

	props, err := h.svc.List(projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, props)
}

// Get 获取道具详情
func (h *Handler) Get(c *gin.Context) {
	projectID := c.Param("id")
	propID := c.Param("propId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || propID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	p, err := h.svc.Get(propID, projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "道具不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, p)
}

// Update 更新道具
func (h *Handler) Update(c *gin.Context) {
	projectID := c.Param("id")
	propID := c.Param("propId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || propID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	p, err := h.svc.Update(propID, projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "道具不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, p)
}

// Confirm 确认道具
func (h *Handler) Confirm(c *gin.Context) {
	projectID := c.Param("id")
	propID := c.Param("propId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || propID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	p, err := h.svc.Confirm(propID, projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "道具不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, p)
}

// Delete 删除道具
func (h *Handler) Delete(c *gin.Context) {
	projectID := c.Param("id")
	propID := c.Param("propId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || propID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	if err := h.svc.Delete(propID, projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "道具不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}
