package dashboard

import (
	"anime_ai/pub/auth"
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 仪表盘 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Get 获取项目仪表盘
// GET /projects/:id/dashboard
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID := auth.GetProjectIDStr(c)
	if projectID == "" {
		projectID = c.Param("id")
	}
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}

	dash, err := h.svc.Get(projectID, userID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, dash)
}
