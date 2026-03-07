// Package project_event 提供事件补拉 API，供前端 WebSocket 重连后追赶缺失事件。
package project_event

import (
	"encoding/json"
	"net/http"
	"strconv"

	"anime_ai/pub/event_recorder"
	"anime_ai/pub/pkg"
	"anime_ai/sch/db"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgtype"
)

// Handler 事件补拉 HTTP 接口
type Handler struct {
	store event_recorder.Store
}

// NewHandler 创建事件补拉 Handler
func NewHandler(store event_recorder.Store) *Handler {
	return &Handler{store: store}
}

// ListProjectEvents 按项目补拉事件
// GET /projects/:id/events?afterId=N&limit=200
func (h *Handler) ListProjectEvents(c *gin.Context) {
	projectIDStr := c.Param("id")
	afterID, _ := strconv.ParseInt(c.DefaultQuery("afterId", "0"), 10, 64)
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "200"))
	if limit <= 0 || limit > 500 {
		limit = 200
	}

	var pid pgtype.UUID
	if err := pid.Scan(projectIDStr); err != nil {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	events, err := h.store.ListProjectEventsAfter(c.Request.Context(), db.ListProjectEventsAfterParams{
		ProjectID: pid,
		AfterID:   afterID,
		Lim:       int32(limit),
	})
	if err != nil {
		pkg.InternalError(c, "查询事件失败: "+err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"events": mapEvents(events),
		"count":  len(events),
	})
}

// ListTaskEvents 按任务补拉事件
// GET /tasks/:taskId/events?afterId=N&limit=200
func (h *Handler) ListTaskEvents(c *gin.Context) {
	taskID := c.Param("taskId")
	afterID, _ := strconv.ParseInt(c.DefaultQuery("afterId", "0"), 10, 64)
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "200"))
	if limit <= 0 || limit > 500 {
		limit = 200
	}

	events, err := h.store.ListTaskEventsAfter(c.Request.Context(), db.ListTaskEventsAfterParams{
		TaskID:  pgtype.Text{String: taskID, Valid: true},
		AfterID: afterID,
		Lim:     int32(limit),
	})
	if err != nil {
		pkg.InternalError(c, "查询任务事件失败: "+err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"events": mapEvents(events),
		"count":  len(events),
	})
}

// ListRecentProjectEvents 获取项目最近 N 条事件（首次连接快照，倒序返回）
// GET /projects/:id/events/recent?limit=50
func (h *Handler) ListRecentProjectEvents(c *gin.Context) {
	projectIDStr := c.Param("id")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	if limit <= 0 || limit > 500 {
		limit = 50
	}

	var pid pgtype.UUID
	if err := pid.Scan(projectIDStr); err != nil {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	events, err := h.store.ListRecentProjectEvents(c.Request.Context(), db.ListRecentProjectEventsParams{
		ProjectID: pid,
		Lim:       int32(limit),
	})
	if err != nil {
		pkg.InternalError(c, "查询最近事件失败: "+err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"events": mapEvents(events),
		"count":  len(events),
	})
}

// GetLatestEventID 获取项目最新事件 ID
// GET /projects/:id/events/latest-id
func (h *Handler) GetLatestEventID(c *gin.Context) {
	projectIDStr := c.Param("id")
	var pid pgtype.UUID
	if err := pid.Scan(projectIDStr); err != nil {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	lastID, err := h.store.GetLatestProjectEventID(c.Request.Context(), pid)
	if err != nil {
		pkg.InternalError(c, "查询最新事件 ID 失败: "+err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{"lastEventId": lastID})
}

// mapEvents 将 DB 模型转为前端友好的 JSON 结构
func mapEvents(events []db.ProjectEvent) []gin.H {
	result := make([]gin.H, 0, len(events))
	for _, e := range events {
		item := gin.H{
			"id":        e.ID,
			"eventType": e.EventType,
			"userId":    pkg.UUIDString(e.UserID),
			"createdAt": e.CreatedAt.Time.Format("2006-01-02T15:04:05Z07:00"),
		}
		if e.ProjectID.Valid {
			item["projectId"] = pkg.UUIDString(e.ProjectID)
		}
		if e.TaskID.Valid {
			item["taskId"] = e.TaskID.String
		}
		if e.TargetType.Valid {
			item["targetType"] = e.TargetType.String
		}
		if e.TargetID.Valid {
			item["targetId"] = e.TargetID.String
		}
		if len(e.Payload) > 0 {
			var raw json.RawMessage = e.Payload
			item["payload"] = raw
		}
		result = append(result, item)
	}
	return result
}
