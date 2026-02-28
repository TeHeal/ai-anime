package notification

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 通知 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// List 获取通知列表
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	limit, _ := strconv.ParseInt(c.DefaultQuery("limit", "50"), 10, 32)
	offset, _ := strconv.ParseInt(c.DefaultQuery("offset", "0"), 10, 32)
	if limit <= 0 || limit > 50 {
		limit = 50
	}
	list, err := h.svc.List(c.Request.Context(), userID, int32(limit), int32(offset))
	if err != nil {
		pkg.InternalError(c, "获取通知列表失败")
		return
	}
	pkg.OK(c, gin.H{"items": list})
}

// CountUnread 获取未读数量（红点）
func (h *Handler) CountUnread(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	count, err := h.svc.CountUnread(c.Request.Context(), userID)
	if err != nil {
		pkg.InternalError(c, "获取未读数失败")
		return
	}
	pkg.OK(c, gin.H{"count": count})
}

// MarkAsRead 标记单条已读
func (h *Handler) MarkAsRead(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("id")
	if userID == "" || id == "" {
		pkg.BadRequest(c, "参数错误")
		return
	}
	if err := h.svc.MarkAsRead(c.Request.Context(), id, userID); err != nil {
		pkg.InternalError(c, "标记已读失败")
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}

// MarkAllAsRead 全部已读
func (h *Handler) MarkAllAsRead(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	if err := h.svc.MarkAllAsRead(c.Request.Context(), userID); err != nil {
		pkg.InternalError(c, "全部已读失败")
		return
	}
	pkg.OK(c, gin.H{"message": "ok"})
}
