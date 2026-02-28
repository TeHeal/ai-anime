package episode

import (
	"errors"
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

var _ = strconv.Itoa // 保留 strconv 用于 getEpisodeID

// Handler 集 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建集 Handler
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

// Create 创建集
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req CreateEpisodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	ep, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, ep.ToResponse())
}

// List 列出集
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	episodes, err := h.svc.ListByProject(projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	resp := make([]EpisodeResponse, len(episodes))
	for i := range episodes {
		resp[i] = episodes[i].ToResponse()
	}
	pkg.OK(c, resp)
}

// Get 获取集
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	ep, err := h.svc.Get(epID, projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "集不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, ep.ToResponse())
}

// Update 更新集
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	var req UpdateEpisodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	ep, err := h.svc.Update(epID, projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "集不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, ep.ToResponse())
}

// Delete 删除集
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	if err := h.svc.Delete(epID, projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "集不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// Reorder 排序集
func (h *Handler) Reorder(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req ReorderEpisodesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.Reorder(projectID, userID, req); err != nil {
		pkg.InternalError(c, "排序失败")
		return
	}
	pkg.OK(c, nil)
}
