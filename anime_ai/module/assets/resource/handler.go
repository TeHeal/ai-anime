package resource

import (
	"errors"

	"anime_ai/pub/pkg"
	"anime_ai/pub/realtime"
	"github.com/gin-gonic/gin"
)

// Handler 素材库 HTTP 接口层
type Handler struct {
	svc         *Service
	realtimeHub *realtime.Hub
}

// NewHandler 创建 Handler
func NewHandler(svc *Service, realtimeHub *realtime.Hub) *Handler {
	return &Handler{svc: svc, realtimeHub: realtimeHub}
}

func (h *Handler) getResourceID(c *gin.Context) (string, bool) {
	id := c.Param("resourceId")
	if id == "" {
		pkg.BadRequest(c, "无效的素材 ID")
		return "", false
	}
	return id, true
}

// Create 创建素材
func (h *Handler) Create(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.Create(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	if h.realtimeHub != nil {
		h.realtimeHub.BroadcastResourceCreated(userID, res.ID, "resource")
	}
	pkg.Created(c, res)
}

// List 分页列表
func (h *Handler) List(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req ListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	resp, err := h.svc.List(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, resp)
}

// Get 获取素材详情
func (h *Handler) Get(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	resourceID, ok := h.getResourceID(c)
	if !ok {
		return
	}
	res, err := h.svc.Get(c.Request.Context(), resourceID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "素材不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, res)
}

// Update 更新素材
func (h *Handler) Update(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	resourceID, ok := h.getResourceID(c)
	if !ok {
		return
	}
	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.Update(c.Request.Context(), resourceID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "素材不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, res)
}

// Delete 软删除素材
func (h *Handler) Delete(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	resourceID, ok := h.getResourceID(c)
	if !ok {
		return
	}
	if err := h.svc.Delete(c.Request.Context(), resourceID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "素材不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, nil)
}

// Counts 各子库数量统计
func (h *Handler) Counts(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	modality := c.Query("modality")
	resp, err := h.svc.Counts(c.Request.Context(), userID, modality)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, resp)
}

// GenerateVoice 音色克隆：根据音频样本克隆音色并写入素材库
func (h *Handler) GenerateVoice(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req GenerateVoiceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.GenerateVoice(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}
	if h.realtimeHub != nil {
		h.realtimeHub.BroadcastResourceCreated(userID, res.ID, "resource_voice")
	}
	pkg.Created(c, map[string]any{"resource": res, "task_id": ""})
}

// GenerateVoiceDesign 音色设计：根据文本描述生成 TTS 预览音频并写入素材库
func (h *Handler) GenerateVoiceDesign(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req GenerateVoiceDesignRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.GenerateVoiceDesign(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}
	if h.realtimeHub != nil {
		h.realtimeHub.BroadcastResourceCreated(userID, res.ID, "resource_voice_design")
	}
	pkg.Created(c, map[string]any{"resource": res, "taskId": ""})
}

// GeneratePreviewText 根据音色描述生成适合试听的示例文本
func (h *Handler) GeneratePreviewText(c *gin.Context) {
	var req GeneratePreviewTextRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	text, err := h.svc.GeneratePreviewText(c.Request.Context(), req)
	if err != nil {
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, map[string]string{"text": text})
}

// GeneratePrompt 调用 LLM 生成提示词并写入素材库
func (h *Handler) GeneratePrompt(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req GeneratePromptRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.GeneratePrompt(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}
	if h.realtimeHub != nil {
		h.realtimeHub.BroadcastResourceCreated(userID, res.ID, "resource_prompt")
	}
	pkg.Created(c, res)
}

// GenerateImage 图生并写入素材库
func (h *Handler) GenerateImage(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req GenerateImageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	res, err := h.svc.GenerateImage(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "资源不存在")
			return
		}
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}
	if h.realtimeHub != nil {
		h.realtimeHub.BroadcastResourceCreated(userID, res.ID, "resource_image")
	}
	pkg.Created(c, res)
}
