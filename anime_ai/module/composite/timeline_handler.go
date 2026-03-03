package composite

import (
	"encoding/json"
	"errors"

	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// TimelineHandler 时间轴 HTTP 接口层
type TimelineHandler struct {
	generator  *TimelineGenerator
	svc        *Service
	storyboard crossmodule.ProjectStoryboardAccess
}

// NewTimelineHandler 创建时间轴 Handler
func NewTimelineHandler(
	generator *TimelineGenerator,
	svc *Service,
	storyboard crossmodule.ProjectStoryboardAccess,
) *TimelineHandler {
	return &TimelineHandler{
		generator:  generator,
		svc:        svc,
		storyboard: storyboard,
	}
}

// GetTimeline 获取项目时间轴（优先返回已保存版本，否则自动生成）
// GET /projects/:id/timeline
func (h *TimelineHandler) GetTimeline(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	if err := h.svc.verifier.Verify(projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}

	// 尝试从 storyboard_json 读取已保存的时间轴
	if h.storyboard != nil {
		saved, err := h.storyboard.GetStoryboardJSON(projectID, userID)
		if err == nil && saved != "" {
			tl, err := TimelineFromJSON(saved)
			if err == nil && tl != nil && !tl.AutoGen {
				pkg.OK(c, tl)
				return
			}
		}
	}

	// 自动生成
	tl, err := h.generator.AutoGenerate(c.Request.Context(), projectID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, tl)
}

// SaveTimeline 保存自定义时间轴编辑
// PUT /projects/:id/timeline
func (h *TimelineHandler) SaveTimeline(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	if err := h.svc.verifier.Verify(projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}

	var tl Timeline
	if err := c.ShouldBindJSON(&tl); err != nil {
		pkg.BadRequest(c, "无效的时间轴数据")
		return
	}
	tl.ProjectID = projectID
	tl.AutoGen = false

	data, err := json.Marshal(&tl)
	if err != nil {
		pkg.InternalError(c, "序列化时间轴失败")
		return
	}

	if h.storyboard != nil {
		if err := h.storyboard.UpdateStoryboardJSON(projectID, userID, string(data)); err != nil {
			pkg.HandleError(c, err)
			return
		}
	}

	pkg.OK(c, tl)
}

// AutoGenerateTimeline 重新从当前镜头自动生成时间轴
// POST /projects/:id/timeline/auto
func (h *TimelineHandler) AutoGenerateTimeline(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	if err := h.svc.verifier.Verify(projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}

	tl, err := h.generator.AutoGenerate(c.Request.Context(), projectID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, tl)
}
