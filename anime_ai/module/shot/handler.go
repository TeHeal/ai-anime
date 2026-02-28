package shot

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 镜头 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建镜头 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) getProjectID(c *gin.Context) (string, bool) {
	id := c.Param("id")
	if id == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return "", false
	}
	return id, true
}

func (h *Handler) getShotID(c *gin.Context) (string, bool) {
	id := c.Param("shotId")
	if id == "" {
		pkg.BadRequest(c, "无效的镜头 ID")
		return "", false
	}
	return id, true
}

// Create 创建镜头
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req CreateShotRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	shot, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, shot)
}

// BulkCreate 批量创建镜头
func (h *Handler) BulkCreate(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req BulkCreateShotRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	shots, err := h.svc.BulkCreate(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, shots)
}

// List 列出镜头
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	reviewStatus := c.Query("review_status")
	shots, err := h.svc.List(projectID, userID, reviewStatus)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, shots)
}

// Get 获取镜头
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	shot, err := h.svc.Get(shotID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, shot)
}

// Update 更新镜头
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	var req UpdateShotRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	shot, err := h.svc.Update(shotID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, shot)
}

// Delete 删除镜头
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	if err := h.svc.Delete(shotID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// Reorder 排序镜头
func (h *Handler) Reorder(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req struct {
		OrderedIDs []string `json:"ordered_ids" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误")
		return
	}
	if err := h.svc.Reorder(projectID, userID, req.OrderedIDs); err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// BatchGenerate 批量生成镜头（占位）
func (h *Handler) BatchGenerate(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req struct {
		ShotIDs []string `json:"shot_ids" binding:"required,min=1"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	results, err := h.svc.BatchGenerate(projectID, userID, req.ShotIDs)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, results)
}

// BatchComposite 批量合成（占位）
func (h *Handler) BatchComposite(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req struct {
		ShotIDs []string `json:"shot_ids" binding:"required,min=1"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	results, err := h.svc.BatchComposite(projectID, userID, req.ShotIDs)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, results)
}
