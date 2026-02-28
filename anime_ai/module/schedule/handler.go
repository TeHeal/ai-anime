package schedule

import (
	"encoding/json"
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 定时任务 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// CreateRequest 创建请求
type CreateRequest struct {
	Name     string          `json:"name"`
	CronExpr string          `json:"cron_expr" binding:"required"`
	Action   string          `json:"action"`
	Config   json.RawMessage `json:"config"`
	Enabled  *bool           `json:"enabled"`
}

// Create 创建定时任务
func (h *Handler) Create(c *gin.Context) {
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	enabled := true
	if req.Enabled != nil {
		enabled = *req.Enabled
	}
	action := req.Action
	if action == "" {
		action = "pipeline"
	}
	config := req.Config
	if config == nil {
		config = []byte("{}")
	}
	sch, err := h.svc.Create(c.Request.Context(), projectID, userID, req.Name, req.CronExpr, action, config, enabled)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		if be := (*pkg.BizError)(nil); errors.As(err, &be) {
			pkg.BadRequest(c, be.Msg)
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, sch)
}

// List 按项目列出定时任务
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	list, err := h.svc.ListByProject(c.Request.Context(), projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, list)
}

// Get 获取定时任务
func (h *Handler) Get(c *gin.Context) {
	id := c.Param("scheduleId")
	if id == "" {
		pkg.BadRequest(c, "无效的定时任务 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	sch, err := h.svc.Get(c.Request.Context(), id, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "定时任务不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, sch)
}

// UpdateRequest 更新请求
type UpdateRequest struct {
	Name     *string         `json:"name"`
	CronExpr *string         `json:"cron_expr"`
	Action   *string         `json:"action"`
	Config   json.RawMessage `json:"config"`
	Enabled  *bool           `json:"enabled"`
}

// Update 更新定时任务
func (h *Handler) Update(c *gin.Context) {
	id := c.Param("scheduleId")
	if id == "" {
		pkg.BadRequest(c, "无效的定时任务 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	var config []byte
	if req.Config != nil {
		config = req.Config
	}
	sch, err := h.svc.Update(c.Request.Context(), id, userID, req.Name, req.CronExpr, req.Action, config, req.Enabled)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "定时任务不存在")
			return
		}
		if be := (*pkg.BizError)(nil); errors.As(err, &be) {
			pkg.BadRequest(c, be.Msg)
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, sch)
}

// Delete 删除定时任务
func (h *Handler) Delete(c *gin.Context) {
	id := c.Param("scheduleId")
	if id == "" {
		pkg.BadRequest(c, "无效的定时任务 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	if err := h.svc.Delete(c.Request.Context(), id, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "定时任务不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}
