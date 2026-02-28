package scene

import (
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 场 HTTP 接口层（含块接口）
type Handler struct {
	svc *Service
}

// NewHandler 创建场 Handler
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

func (h *Handler) getSceneID(c *gin.Context) (string, bool) {
	id := c.Param("sceneId")
	if id == "" {
		pkg.BadRequest(c, "无效的场 ID")
		return "", false
	}
	return id, true
}

func (h *Handler) getBlockID(c *gin.Context) (string, bool) {
	id := c.Param("blockId")
	if id == "" {
		pkg.BadRequest(c, "无效的块 ID")
		return "", false
	}
	return id, true
}

// Create 创建场
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	_, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	var req CreateSceneRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	scene, err := h.svc.Create(epID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "集不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, scene)
}

// List 列出场
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	_, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	scenes, err := h.svc.List(epID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "集不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, scenes)
}

// Get 获取场
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	_, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	scene, err := h.svc.Get(sceneID, epID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "场不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, scene)
}

// Update 更新场
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	_, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	var req UpdateSceneRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	scene, err := h.svc.Update(sceneID, epID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "场不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, scene)
}

// Delete 删除场
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	_, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	if err := h.svc.Delete(sceneID, epID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "场不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// Reorder 排序场
func (h *Handler) Reorder(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	_, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	var req ReorderScenesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.Reorder(epID, userID, req); err != nil {
		pkg.InternalError(c, "排序失败")
		return
	}
	pkg.OK(c, nil)
}

// SaveBlocks 批量保存块
func (h *Handler) SaveBlocks(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	_, ok := h.getProjectID(c)
	if !ok {
		return
	}
	epID, ok := h.getEpisodeID(c)
	if !ok {
		return
	}
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	var req BulkSaveBlocksRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	blocks, err := h.svc.SaveBlocks(sceneID, epID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "场不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, blocks)
}

// CreateBlock 创建块
func (h *Handler) CreateBlock(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	var req CreateBlockRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	block, err := h.svc.CreateBlock(sceneID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "场不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, block)
}

// UpdateBlock 更新块
func (h *Handler) UpdateBlock(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	blockID, ok := h.getBlockID(c)
	if !ok {
		return
	}
	var req UpdateBlockRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	block, err := h.svc.UpdateBlock(blockID, sceneID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "块不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, block)
}

// DeleteBlock 删除块
func (h *Handler) DeleteBlock(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	blockID, ok := h.getBlockID(c)
	if !ok {
		return
	}
	if err := h.svc.DeleteBlock(blockID, sceneID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "块不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// ReorderBlocks 排序块
func (h *Handler) ReorderBlocks(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	sceneID, ok := h.getSceneID(c)
	if !ok {
		return
	}
	var req ReorderBlocksRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.ReorderBlocks(sceneID, userID, req); err != nil {
		pkg.InternalError(c, "排序失败")
		return
	}
	pkg.OK(c, nil)
}
