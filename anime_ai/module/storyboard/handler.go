package storyboard

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 分镜 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建分镜 Handler
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

// List 分镜列表
func (h *Handler) List(c *gin.Context) {
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	userID := pkg.GetUserIDStr(c)

	shots, err := h.svc.List(projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"shots": shots})
}

// Preview 同步预览单场景
func (h *Handler) Preview(c *gin.Context) {
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	userID := pkg.GetUserIDStr(c)

	var req PreviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	shots, err := h.svc.Preview(c.Request.Context(), projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"shots": shots})
}

// Generate 异步拆镜
func (h *Handler) Generate(c *gin.Context) {
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	userID := pkg.GetUserIDStr(c)

	var req GenerateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	task, err := h.svc.Generate(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, task)
}

// GenerateSync 同步拆镜整集
func (h *Handler) GenerateSync(c *gin.Context) {
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	userID := pkg.GetUserIDStr(c)

	var req GenerateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	shots, err := h.svc.GenerateSync(c.Request.Context(), projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"shots": shots})
}

// Confirm 确认导入
func (h *Handler) Confirm(c *gin.Context) {
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	userID := pkg.GetUserIDStr(c)

	var req ConfirmRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	shots, err := h.svc.Confirm(projectID, userID, req)
	if err != nil {
		var bizErr *pkg.BizError
		if errors.As(err, &bizErr) {
			pkg.BadRequest(c, bizErr.Msg)
			return
		}
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, shots)
}
