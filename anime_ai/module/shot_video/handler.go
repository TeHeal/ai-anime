package shot_video

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 镜头视频 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建镜头视频 Handler
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

// List 按镜头列出视频
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	shotID, ok := h.getShotID(c)
	if !ok {
		return
	}
	list, err := h.svc.ListByShot(shotID, projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, list)
}

// Create 创建镜头视频（支持完整视频生成参数）
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
	var req VideoCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		// 兼容旧接口：无 body 时使用默认值
		req = VideoCreateRequest{}
	}
	v, err := h.svc.CreateWithParams(shotID, projectID, userID, &req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, v)
}

// UpdateReview 更新审核状态
func (h *Handler) UpdateReview(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	videoID := c.Param("videoId")
	if videoID == "" {
		pkg.BadRequest(c, "无效的视频 ID")
		return
	}
	var req struct {
		Status  string `json:"status"`
		Comment string `json:"comment"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	v, err := h.svc.UpdateReview(videoID, projectID, userID, req.Status, req.Comment)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "视频不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, v)
}
