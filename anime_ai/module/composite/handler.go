package composite

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
)

// Handler 成片 HTTP 接口层
type Handler struct {
	svc         *Service
	asynqClient *asynq.Client
}

// NewHandler 创建成片 Handler，asynqClient 可选，非 nil 时入队导出任务
func NewHandler(svc *Service, asynqClient *asynq.Client) *Handler {
	return &Handler{svc: svc, asynqClient: asynqClient}
}

func (h *Handler) getProjectID(c *gin.Context) (string, bool) {
	id := c.Param("id")
	if id == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return "", false
	}
	return id, true
}

func (h *Handler) getEpisodeID(c *gin.Context) (string, bool) {
	id := c.Param("epId")
	if id == "" {
		pkg.BadRequest(c, "无效的集 ID")
		return "", false
	}
	return id, true
}

// CreateExport 创建成片导出任务
// POST /projects/:id/episodes/:epId/export
func (h *Handler) CreateExport(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	episodeID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	var req CreateExportRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		req.EpisodeID = episodeID
	}
	if req.EpisodeID == "" {
		req.EpisodeID = episodeID
	}
	task, err := h.svc.CreateExport(c.Request.Context(), projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目或集不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	asynqTaskID := ""
	if h.asynqClient != nil {
		payload, _ := json.Marshal(map[string]string{
			"composite_task_id": task.ID,
			"project_id":        projectID,
			"episode_id":        task.EpisodeID,
			"user_id":           userID,
		})
		asynqTask, err := h.asynqClient.EnqueueContext(
			context.Background(),
			asynq.NewTask(tasktypes.TypeExport, payload),
		)
		if err == nil {
			asynqTaskID = asynqTask.ID
			_ = h.svc.UpdateTaskID(c.Request.Context(), task.ID, asynqTaskID)
		}
	}
	pkg.Created(c, gin.H{
		"id":         task.ID,
		"task_id":    asynqTaskID,
		"status":     task.Status,
		"episode_id": task.EpisodeID,
	})
}

// Get 获取成片任务状态
// GET /projects/:id/composite/:taskId
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	taskID := c.Param("taskId")
	if taskID == "" {
		pkg.BadRequest(c, "无效的任务 ID")
		return
	}
	task, err := h.svc.Get(c.Request.Context(), taskID, projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "任务不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{
		"id":         task.ID,
		"project_id": task.ProjectID,
		"episode_id": task.EpisodeID,
		"task_id":    task.TaskID,
		"status":     task.Status,
		"output_url": task.OutputURL,
		"error_msg":  task.ErrorMsg,
	})
}

// ListByProject 按项目列出成片任务
// GET /projects/:id/composite
func (h *Handler) ListByProject(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	list, err := h.svc.ListByProject(c.Request.Context(), projectID, userID)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	items := make([]gin.H, len(list))
	for i, t := range list {
		items[i] = gin.H{
			"id":         t.ID,
			"project_id": t.ProjectID,
			"episode_id": t.EpisodeID,
			"task_id":    t.TaskID,
			"status":     t.Status,
			"output_url": t.OutputURL,
			"error_msg":  t.ErrorMsg,
		}
	}
	pkg.OK(c, gin.H{"items": items})
}

// ListByEpisode 按集列出成片任务
// GET /projects/:id/episodes/:epId/composite
func (h *Handler) ListByEpisode(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	episodeID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	list, err := h.svc.ListByEpisode(c.Request.Context(), episodeID, projectID, userID)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	items := make([]gin.H, len(list))
	for i, t := range list {
		items[i] = gin.H{
			"id":         t.ID,
			"project_id": t.ProjectID,
			"episode_id": t.EpisodeID,
			"task_id":    t.TaskID,
			"status":     t.Status,
			"output_url": t.OutputURL,
			"error_msg":  t.ErrorMsg,
		}
	}
	pkg.OK(c, gin.H{"items": items})
}
