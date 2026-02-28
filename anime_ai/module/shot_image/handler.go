package shot_image

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 镜图 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建镜图 Handler
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

// BatchGenerate 批量生成镜图（占位）
func (h *Handler) BatchGenerate(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req BatchGenerateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	results, err := h.svc.BatchGenerate(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, results)
}

// GetStatus 获取镜图生成状态（占位）
func (h *Handler) GetStatus(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	status, err := h.svc.GetStatus(projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, status)
}

// GetCandidates 获取镜头镜图候选
func (h *Handler) GetCandidates(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	candidates, err := h.svc.ListByShot(shotID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, candidates)
}

// SelectCandidate 选择镜图候选
func (h *Handler) SelectCandidate(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	var req struct {
		ShotID  string `json:"shot_id" binding:"required"`
		AssetID string `json:"asset_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.SelectCandidate(req.ShotID, req.AssetID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头或镜图不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}

// UpdateImageReview 更新镜头镜图审核状态
func (h *Handler) UpdateImageReview(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	var req struct {
		Status  string `json:"status" binding:"required"`
		Comment string `json:"comment"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.UpdateImageReview(shotID, userID, req.Status, req.Comment); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}

// BatchReview 批量审核镜图
func (h *Handler) BatchReview(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	var req struct {
		ShotIDs []string `json:"shot_ids" binding:"required"`
		Status  string   `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.BatchReview(req.ShotIDs, req.Status, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}

// Create 创建镜图（手动添加）
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	var req struct {
		ImageURL string `json:"image_url" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	img, err := h.svc.Create(shotID, projectID, userID, req.ImageURL)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, img)
}

// List 列出镜图（按镜头）
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	list, err := h.svc.ListByShot(shotID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜头不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, list)
}

// Get 获取镜图
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("imageId")
	if id == "" {
		pkg.BadRequest(c, "无效的镜图 ID")
		return
	}
	img, err := h.svc.Get(id, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜图不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, img)
}

// Delete 删除镜图
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("imageId")
	if id == "" {
		pkg.BadRequest(c, "无效的镜图 ID")
		return
	}
	if err := h.svc.Delete(id, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "镜图不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}
