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

// NewHandler 创建通知 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// List 获取当前用户通知列表
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	list, err := h.svc.List(userID, limit, offset)
	if err != nil {
		pkg.InternalError(c, "获取通知列表失败")
		return
	}
	pkg.OK(c, list)
}

// UnreadCount 获取未读数量
func (h *Handler) UnreadCount(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	count, err := h.svc.CountUnread(userID)
	if err != nil {
		pkg.InternalError(c, "获取未读数量失败")
		return
	}
	pkg.OK(c, gin.H{"count": count})
}

// MarkRead 标记单条已读
func (h *Handler) MarkRead(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	id := c.Param("notifId")
	if err := h.svc.MarkRead(id, userID); err != nil {
		pkg.NotFound(c, "通知不存在")
		return
	}
	pkg.OK(c, gin.H{"message": "已读"})
}

// MarkAllRead 标记全部已读
func (h *Handler) MarkAllRead(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if err := h.svc.MarkAllRead(userID); err != nil {
		pkg.InternalError(c, "标记已读失败")
		return
	}
	pkg.OK(c, gin.H{"message": "全部已读"})
}
