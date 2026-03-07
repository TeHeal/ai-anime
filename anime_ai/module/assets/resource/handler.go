package resource

import (
	"context"
	"encoding/json"
	"errors"

	"anime_ai/pub/pkg"
	"anime_ai/pub/realtime"
	"anime_ai/pub/tasktypes"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// ResourceTaskCreator 创建无 project 归属的 Task 记录，返回 taskID
type ResourceTaskCreator interface {
	CreateTaskForUser(ctx context.Context, userID, typ, title string, config json.RawMessage) (taskID string, err error)
}

// Handler 素材库 HTTP 接口层
type Handler struct {
	svc         *Service
	broadcaster realtime.Broadcaster
	log         *zap.Logger
	asynqClient *asynq.Client // asynq 入队（nil 时降级为 goroutine）
	taskCreator ResourceTaskCreator
}

// NewHandler 创建 Handler
func NewHandler(svc *Service, broadcaster realtime.Broadcaster, log *zap.Logger) *Handler {
	if log == nil {
		log = zap.NewNop()
	}
	return &Handler{svc: svc, broadcaster: broadcaster, log: log.Named("resource_handler")}
}

// SetAsynq 注入 asynq client 和任务创建器，启用 asynq 入队模式
func (h *Handler) SetAsynq(client *asynq.Client, tc ResourceTaskCreator) {
	h.asynqClient = client
	h.taskCreator = tc
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
	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, res.ID, "resource")
	}
	pkg.Created(c, res)
}

// GetSystemVoicePreview 获取系统音色试听 URL（TTS 合成后缓存）
// Query: provider=minimax, voiceId=female-shaonv
func (h *Handler) GetSystemVoicePreview(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	provider := c.Query("provider")
	voiceID := c.Query("voiceId")
	if voiceID == "" {
		pkg.BadRequest(c, "voiceId 不能为空")
		return
	}
	url, err := h.svc.GetSystemVoicePreview(c.Request.Context(), provider, voiceID)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"audioUrl": url})
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

// GenerateVoice 音色克隆（异步）：先创建占位 → 后台克隆 → WS 推送
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

	placeholder, err := h.svc.CreateVoiceClonePlaceholder(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}

	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, placeholder.ID, "resource_voice")
	}

	taskID := h.enqueueResourceTask(c, userID, placeholder.ID, "voice_clone",
		tasktypes.TypeResourceVoiceClone, "音色克隆: "+req.Name, req,
		func() { h.completeVoiceCloneAsync(userID, placeholder.ID, req) })

	pkg.Created(c, map[string]any{"resource": placeholder, "taskId": taskID})
}

func (h *Handler) completeVoiceCloneAsync(userID, resourceID string, req GenerateVoiceRequest) {
	ctx := context.Background()
	h.broadcastResourceTask(userID, resourceID, "tts", "音色克隆", 10, "running")

	res, err := h.svc.CompleteVoiceClone(ctx, userID, resourceID, req)
	if err != nil {
		h.log.Error("音色克隆异步完成失败", zap.String("resource_id", resourceID), zap.Error(err))
		_ = h.svc.MarkResourceGenFailed(ctx, resourceID, userID, err.Error())
		h.broadcastResourceTask(userID, resourceID, "tts", "音色克隆", 0, "failed")
		return
	}
	h.broadcastResourceTask(userID, resourceID, "tts", "音色克隆", 100, "completed")
	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, res.ID, "resource_voice")
	}
}

// GenerateVoiceDesign 音色设计（异步）：
// 1. 创建占位 Resource（metadata 含 _genStatus=generating）→ 立即返回
// 2. goroutine 中完成 TTS → 更新 Resource → WebSocket 推送完成事件
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

	// 创建占位资源
	placeholder, err := h.svc.CreateVoiceDesignPlaceholder(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}

	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, placeholder.ID, "resource_voice_design")
	}

	taskID := h.enqueueResourceTask(c, userID, placeholder.ID, "voice_design",
		tasktypes.TypeResourceVoiceDesign, "音色设计: "+req.Name, req,
		func() { h.completeVoiceDesignAsync(userID, placeholder.ID, req) })

	pkg.Created(c, map[string]any{"resource": placeholder, "taskId": taskID})
}

// completeVoiceDesignAsync 在后台 goroutine 中完成音色设计 TTS 生成
func (h *Handler) completeVoiceDesignAsync(userID, resourceID string, req GenerateVoiceDesignRequest) {
	ctx := context.Background()

	// 广播进度：开始
	h.broadcastResourceTask(userID, resourceID, "tts", "音色设计", 10, "running")

	res, err := h.svc.CompleteVoiceDesign(ctx, userID, resourceID, req)
	if err != nil {
		h.log.Error("音色设计异步生成失败",
			zap.String("resource_id", resourceID),
			zap.Error(err),
		)
		// 标记资源生成失败
		_ = h.svc.MarkResourceGenFailed(ctx, resourceID, userID, err.Error())
		h.broadcastResourceTask(userID, resourceID, "tts", "音色设计", 0, "failed")
		return
	}

	// 广播完成
	h.broadcastResourceTask(userID, resourceID, "tts", "音色设计", 100, "completed")
	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, res.ID, "resource_voice_design")
	}
}

// enqueueResourceTask 创建 Task 记录 + asynq 入队；无 asynq 时降级为 goroutine
// 返回真实 taskID（asynq 模式下为 DB Task ID，降级模式下为 resourceID）
func (h *Handler) enqueueResourceTask(c *gin.Context, userID, resourceID, genType, taskType, title string, req interface{}, fallback func()) string {
	if h.asynqClient == nil || h.taskCreator == nil {
		go fallback()
		return resourceID
	}

	reqJSON, _ := json.Marshal(req)

	// 创建 DB Task 记录
	taskID, err := h.taskCreator.CreateTaskForUser(c.Request.Context(), userID, genType, title, reqJSON)
	if err != nil {
		h.log.Warn("创建 Task 记录失败，降级为 goroutine", zap.Error(err))
		go fallback()
		return resourceID
	}

	// 构建 asynq 任务载荷（与 worker/resource_handler.go ResourceGenPayload 对应）
	payload, _ := json.Marshal(map[string]interface{}{
		"task_id":      taskID,
		"resource_id":  resourceID,
		"user_id":      userID,
		"gen_type":     genType,
		"title":        title,
		"request_json": reqJSON,
	})
	task := asynq.NewTask(taskType, payload)
	if _, err := h.asynqClient.Enqueue(task); err != nil {
		h.log.Warn("asynq 入队失败，降级为 goroutine", zap.Error(err))
		go fallback()
		return resourceID
	}
	return taskID
}

// broadcastResourceTask 推送素材生成任务进度（复用 task_progress/task_complete/task_error 事件）
func (h *Handler) broadcastResourceTask(userID, resourceID, taskType, title string, progress int, status string) {
	if h.broadcaster == nil {
		return
	}
	data := map[string]interface{}{
		"taskId":     resourceID,
		"type":       taskType,
		"progress":   progress,
		"status":     status,
		"title":      title,
		"resourceId": resourceID,
	}
	switch {
	case progress >= 100 && status == "completed":
		h.broadcaster.BroadcastTaskComplete(userID, nil, resourceID, data)
	case status == "failed":
		h.broadcaster.BroadcastTaskError(userID, nil, resourceID, data)
	default:
		h.broadcaster.BroadcastTaskProgress(userID, nil, resourceID, data)
	}
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

// GeneratePrompt 提示词生成（异步）：先创建占位 → 后台 LLM 生成 → WS 推送
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

	placeholder, err := h.svc.CreatePromptPlaceholder(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}

	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, placeholder.ID, "resource_prompt")
	}

	taskID := h.enqueueResourceTask(c, userID, placeholder.ID, "text",
		tasktypes.TypeResourceText, "提示词生成: "+req.Name, req,
		func() { h.completePromptAsync(userID, placeholder.ID, req) })

	pkg.Created(c, map[string]any{"resource": placeholder, "taskId": taskID})
}

func (h *Handler) completePromptAsync(userID, resourceID string, req GeneratePromptRequest) {
	ctx := context.Background()
	h.broadcastResourceTask(userID, resourceID, "text", "提示词生成", 10, "running")

	res, err := h.svc.CompletePrompt(ctx, userID, resourceID, req)
	if err != nil {
		h.log.Error("提示词异步生成失败", zap.String("resource_id", resourceID), zap.Error(err))
		_ = h.svc.MarkResourceGenFailed(ctx, resourceID, userID, err.Error())
		h.broadcastResourceTask(userID, resourceID, "text", "提示词生成", 0, "failed")
		return
	}
	h.broadcastResourceTask(userID, resourceID, "text", "提示词生成", 100, "completed")
	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, res.ID, "resource_prompt")
	}
}

// GenerateImage 图生（异步）：先创建占位 → 后台图生 → WS 推送
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

	placeholder, err := h.svc.CreateImagePlaceholder(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrBadRequest) {
			pkg.BadRequest(c, err.Error())
			return
		}
		pkg.HandleError(c, err)
		return
	}

	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, placeholder.ID, "resource_image")
	}

	taskID := h.enqueueResourceTask(c, userID, placeholder.ID, "image",
		tasktypes.TypeResourceImage, "图片生成: "+req.Name, req,
		func() { h.completeImageAsync(userID, placeholder.ID, req) })

	pkg.Created(c, map[string]any{"resource": placeholder, "taskId": taskID})
}

func (h *Handler) completeImageAsync(userID, resourceID string, req GenerateImageRequest) {
	ctx := context.Background()
	h.broadcastResourceTask(userID, resourceID, "image", "图片生成", 10, "running")

	res, err := h.svc.CompleteImage(ctx, userID, resourceID, req)
	if err != nil {
		h.log.Error("图生异步完成失败", zap.String("resource_id", resourceID), zap.Error(err))
		_ = h.svc.MarkResourceGenFailed(ctx, resourceID, userID, err.Error())
		h.broadcastResourceTask(userID, resourceID, "image", "图片生成", 0, "failed")
		return
	}
	h.broadcastResourceTask(userID, resourceID, "image", "图片生成", 100, "completed")
	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, res.ID, "resource_image")
	}
}
