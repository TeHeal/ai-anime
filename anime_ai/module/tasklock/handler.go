package tasklock

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 任务锁 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建任务锁 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Acquire 获取任务锁（执行即加锁）
func (h *Handler) Acquire(c *gin.Context) {
	projectID := c.Param("id")
	userID := pkg.GetUserIDStr(c)
	var req AcquireRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	lock, err := h.svc.Acquire(projectID, userID, req)
	if err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.Created(c, lock)
}

// Release 释放任务锁
func (h *Handler) Release(c *gin.Context) {
	lockID := c.Param("lockId")
	if err := h.svc.Release(lockID); err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "锁已释放"})
}

// Check 检查任务是否被锁定
func (h *Handler) Check(c *gin.Context) {
	resourceType := c.Query("resource_type")
	resourceID := c.Query("resource_id")
	action := c.Query("action")
	lock, err := h.svc.Check(resourceType, resourceID, action)
	if err != nil {
		pkg.OK(c, gin.H{"locked": false})
		return
	}
	pkg.OK(c, gin.H{"locked": true, "lock": lock})
}
