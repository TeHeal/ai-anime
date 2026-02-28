package package_task

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 按集打包 HTTP 接口层（README 2.7）
type Handler struct {
	svc *Service
}

// NewHandler 创建打包 Handler
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

func (h *Handler) getEpisodeID(c *gin.Context) (string, bool) {
	id := c.Param("epId")
	if id == "" {
		pkg.BadRequest(c, "无效的集 ID")
		return "", false
	}
	return id, true
}

// RequestPackage 请求按集打包（POST /projects/:id/episodes/:epId/package）
func (h *Handler) RequestPackage(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	episodeID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	var req struct {
		Config Config `json:"config"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		req.Config = Config{
			IncludeShotImages: true,
			IncludeVoices:     true,
			IncludeShots:      true,
			IncludeFinal:      true,
		}
	}
	task, err := h.svc.CreateAndEnqueue(c.Request.Context(), projectID, episodeID, userID, req.Config)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目或集不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{
		"id":         task.ID,
		"task_id":    task.TaskID,
		"status":     task.Status,
		"episode_id": task.EpisodeID,
	})
}

// Get 获取打包任务状态（GET /projects/:id/package/:taskId）
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

// ListByEpisode 按集列出打包任务（GET /projects/:id/episodes/:epId/package）
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
