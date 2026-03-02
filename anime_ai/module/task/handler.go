package task

import (
	"encoding/json"
	"errors"
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 任务 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// List 任务列表（GET /tasks）
// 查询参数: project_id, type, status, limit, offset
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}

	limit, _ := strconv.ParseInt(c.DefaultQuery("limit", "20"), 10, 32)
	offset, _ := strconv.ParseInt(c.DefaultQuery("offset", "0"), 10, 32)
	if limit <= 0 || limit > 50 {
		limit = 20
	}

	p := ListParams{
		ProjectID: c.Query("project_id"),
		UserID:    userID,
		Type:      c.Query("type"),
		Status:    c.Query("status"),
		Limit:     int32(limit),
		Offset:    int32(offset),
	}

	// 前端可能不传 project_id，直接按当前用户列出
	list, err := h.svc.List(c.Request.Context(), p)
	if err != nil {
		if be := (*pkg.BizError)(nil); errors.As(err, &be) {
			pkg.BadRequest(c, be.Msg)
			return
		}
		pkg.HandleError(c, err)
		return
	}
	if list == nil {
		list = []*TaskDTO{}
	}
	pkg.OK(c, gin.H{"items": list})
}

// Get 任务详情（GET /tasks/:taskId）
func (h *Handler) Get(c *gin.Context) {
	id := c.Param("taskId")
	if id == "" {
		pkg.BadRequest(c, "无效的任务 ID")
		return
	}
	t, err := h.svc.Get(c.Request.Context(), id)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "任务不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, t)
}

// Cancel 取消任务（PUT /tasks/:taskId/cancel）
func (h *Handler) Cancel(c *gin.Context) {
	id := c.Param("taskId")
	if id == "" {
		pkg.BadRequest(c, "无效的任务 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	t, err := h.svc.Cancel(c.Request.Context(), id, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "任务不存在")
			return
		}
		if be := (*pkg.BizError)(nil); errors.As(err, &be) {
			pkg.BadRequest(c, be.Msg)
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, t)
}

// batchRequest 批量操作请求
type batchRequest struct {
	Action  string   `json:"action"`
	TaskIDs []string `json:"task_ids"`
}

// Batch 批量操作（POST /tasks/batch）
// 当前支持 action: "cancel"（批量取消）、"get"（批量获取）
func (h *Handler) Batch(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req batchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	if len(req.TaskIDs) == 0 {
		pkg.BadRequest(c, "task_ids 不能为空")
		return
	}

	switch req.Action {
	case "cancel":
		if err := h.svc.BatchCancel(c.Request.Context(), req.TaskIDs, userID); err != nil {
			if be := (*pkg.BizError)(nil); errors.As(err, &be) {
				pkg.BadRequest(c, be.Msg)
				return
			}
			pkg.HandleError(c, err)
			return
		}
		pkg.OK(c, gin.H{"message": "ok"})

	case "get", "":
		list, err := h.svc.BatchGet(c.Request.Context(), req.TaskIDs)
		if err != nil {
			pkg.HandleError(c, err)
			return
		}
		if list == nil {
			list = []*TaskDTO{}
		}
		pkg.OK(c, gin.H{"items": list})

	default:
		pkg.BadRequest(c, "不支持的 action: "+req.Action)
	}
}

// createRequest 创建任务请求
type createRequest struct {
	ProjectID   string          `json:"projectId" binding:"required"`
	Type        string          `json:"type" binding:"required"`
	Title       string          `json:"title"`
	Description string          `json:"description"`
	Config      json.RawMessage `json:"config"`
}

// Create 创建任务（POST /tasks）
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req createRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	t, err := h.svc.Create(c.Request.Context(), req.ProjectID, userID, req.Type, req.Title, req.Description, req.Config)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		if be := (*pkg.BizError)(nil); errors.As(err, &be) {
			pkg.BadRequest(c, be.Msg)
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, t)
}
