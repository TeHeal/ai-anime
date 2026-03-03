package resource

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 素材库 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) getResourceID(c *gin.Context) (string, bool) {
	id := c.Param("resourceId")
	if id == "" {
		pkg.BadRequest(c, "无效的素材 ID")
		return "", false
	}
	return id, true
}

// Create 创建素材
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.Create(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, res)
}

// List 分页列表
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req ListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	resp, err := h.svc.List(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, resp)
}

// Get 获取素材详情
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	resourceID, ok := h.getResourceID(c)
	if !ok {
		return
	}
	res, err := h.svc.Get(c.Request.Context(), resourceID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "素材不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, res)
}

// Update 更新素材
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	resourceID, ok := h.getResourceID(c)
	if !ok {
		return
	}
	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.Update(c.Request.Context(), resourceID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "素材不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, res)
}

// Delete 软删除素材
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	resourceID, ok := h.getResourceID(c)
	if !ok {
		return
	}
	if err := h.svc.Delete(c.Request.Context(), resourceID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "素材不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, nil)
}

// Counts 各子库数量统计
func (h *Handler) Counts(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	modality := c.Query("modality")
	resp, err := h.svc.Counts(c.Request.Context(), userID, modality)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, resp)
}

// GenerateImage 图生并写入素材库
func (h *Handler) GenerateImage(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req GenerateImageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.GenerateImage(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, res)
}
