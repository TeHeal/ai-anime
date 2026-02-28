package usage

import (
	"errors"
	"strconv"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 用量查询 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// List 按项目查询用量（README 8.3 AI 成本控制）
// GET /projects/:id/usage?start_at=&end_at=&limit=&offset=
func (h *Handler) List(c *gin.Context) {
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	startAt := parseTime(c.Query("start_at"))
	endAt := parseTime(c.Query("end_at"))
	limit := parseInt32(c.Query("limit"), 50)
	offset := parseInt32(c.Query("offset"), 0)
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	if offset < 0 {
		offset = 0
	}
	items, err := h.svc.List(c.Request.Context(), projectID, userID, startAt, endAt, limit, offset)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, map[string]interface{}{"items": items})
}

func parseTime(s string) *time.Time {
	if s == "" {
		return nil
	}
	t, err := time.Parse(time.RFC3339, s)
	if err != nil {
		return nil
	}
	return &t
}

func parseInt32(s string, def int32) int32 {
	if s == "" {
		return def
	}
	v, err := strconv.ParseInt(s, 10, 32)
	if err != nil {
		return def
	}
	return int32(v)
}
