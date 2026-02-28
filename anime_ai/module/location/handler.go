package location

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 场景资产 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Create 创建场景
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

	loc, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		if err == pkg.ErrNotFound {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, loc)
}

// List 列出项目场景
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || userID == "" {
		pkg.BadRequest(c, "无效的项目 ID 或用户")
		return
	}

	locs, err := h.svc.List(projectID, userID)
	if err != nil {
		if err == pkg.ErrNotFound {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, locs)
}

// Get 获取场景详情
func (h *Handler) Get(c *gin.Context) {
	projectID := c.Param("id")
	locID := c.Param("locId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || locID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	loc, err := h.svc.Get(locID, projectID, userID)
	if err != nil {
		if err == pkg.ErrNotFound {
			pkg.NotFound(c, "场景不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, loc)
}

// Update 更新场景
func (h *Handler) Update(c *gin.Context) {
	projectID := c.Param("id")
	locID := c.Param("locId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || locID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	loc, err := h.svc.Update(locID, projectID, userID, req)
	if err != nil {
		if err == pkg.ErrNotFound {
			pkg.NotFound(c, "场景不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, loc)
}

// Confirm 确认场景
func (h *Handler) Confirm(c *gin.Context) {
	projectID := c.Param("id")
	locID := c.Param("locId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || locID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	loc, err := h.svc.Confirm(locID, projectID, userID)
	if err != nil {
		if err == pkg.ErrNotFound {
			pkg.NotFound(c, "场景不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, loc)
}

// Delete 删除场景
func (h *Handler) Delete(c *gin.Context) {
	projectID := c.Param("id")
	locID := c.Param("locId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || locID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	if err := h.svc.Delete(locID, projectID, userID); err != nil {
		if err == pkg.ErrNotFound {
			pkg.NotFound(c, "场景不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// GenerateImage 触发场景图生成
func (h *Handler) GenerateImage(c *gin.Context) {
	projectID := c.Param("id")
	locID := c.Param("locId")
	userID := pkg.GetUserIDStr(c)
	if projectID == "" || locID == "" || userID == "" {
		pkg.BadRequest(c, "无效的参数")
		return
	}

	var req struct {
		Provider string `json:"provider"`
		Model    string `json:"model"`
	}
	_ = c.ShouldBindJSON(&req)

	loc, err := h.svc.GenerateImage(locID, projectID, userID, req.Provider, req.Model)
	if err != nil {
		if err == pkg.ErrNotFound {
			pkg.NotFound(c, "场景不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, loc)
}
