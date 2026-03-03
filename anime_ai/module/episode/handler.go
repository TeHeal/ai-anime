package episode

import (
	"errors"
	"log"
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/module/scene"
	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

var _ = strconv.Itoa // 保留 strconv 用于 getEpisodeID

// Handler 集 HTTP 接口层
type Handler struct {
	svc       *Service
	sceneSvc  *scene.Service
}

// NewHandler 创建集 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// SetSceneService 注入场服务，用于 List 时返回嵌套的 scenes（兼容备份版本编辑页树形结构）
func (h *Handler) SetSceneService(s *scene.Service) {
	h.sceneSvc = s
}

func (h *Handler) getProjectID(c *gin.Context) (string, bool) {
	s := auth.GetProjectIDStr(c)
	if s == "" {
		s = c.Param("id")
	}
	if s == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return "", false
	}
	return s, true
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
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	ep, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, ep.ToResponse())
}

// List 列出集（含 scenes 时供编辑页树形结构使用，批量加载避免 N+1）
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
		pkg.HandleError(c, err)
		return
	}
	resp := make([]EpisodeResponse, len(episodes))
	for i := range episodes {
		resp[i] = episodes[i].ToResponse()
	}
	if h.sceneSvc != nil {
		scenesByEp, err := h.sceneSvc.ListByProjectWithBlocks(projectID, userID)
		if err != nil {
			log.Printf("[episode.List] 加载 scenes 失败: %v", err)
		} else {
			for i := range episodes {
				epID := episodes[i].IDStr
				if epID == "" {
					epID = strconv.FormatUint(uint64(episodes[i].ID), 10)
				}
				resp[i].Scenes = scenesByEp[epID]
			}
		}
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
		pkg.HandleError(c, err)
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
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	ep, err := h.svc.Update(epID, projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "集不存在")
			return
		}
		pkg.HandleError(c, err)
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
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, nil)
}

// GetPackageConfig 获取按集打包的默认配置选项（README 生成物下载，可配置）
func (h *Handler) GetPackageConfig(c *gin.Context) {
	cfg := DefaultPackageConfig()
	pkg.OK(c, gin.H{
		"options": cfg,
		"hints": gin.H{
			"include_shot_images": "镜图",
			"include_voices":      "音色/配音",
			"include_shots":       "镜头视频",
			"include_final":       "成片",
		},
	})
}

// RequestPackage 请求按集打包下载（占位，后续接 Worker 生成 ZIP）
func (h *Handler) RequestPackage(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	var req struct {
		Config PackageConfig `json:"config"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		req.Config = DefaultPackageConfig()
	}
	if _, err := h.svc.Get(epID, projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "集不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	// 占位：后续入队导出任务，返回 task_id
	pkg.OK(c, gin.H{
		"message": "打包任务已提交（占位）",
		"config":  req.Config,
		"task_id": "",
	})
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
		pkg.BadRequest(c, "请求参数错误")
		return
	}
	if err := h.svc.Reorder(projectID, userID, req); err != nil {
		c.Error(err)
		pkg.InternalError(c, "排序失败")
		return
	}
	pkg.OK(c, nil)
}
