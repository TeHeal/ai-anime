package ai

import (
	"context"
	"encoding/json"
	"errors"

	"anime_ai/module/assets/resource"
	"anime_ai/pub/pkg"
	"anime_ai/pub/realtime"
	"anime_ai/pub/tasktypes"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// Handler AI 生成统一入口（图生、LLM、音频）
type Handler struct {
	resourceSvc *resource.Service
	broadcaster realtime.Broadcaster
	log         *zap.Logger
	asynqClient *asynq.Client
	taskCreator resource.ResourceTaskCreator
}

// NewHandler 创建 Handler
func NewHandler(resourceSvc *resource.Service, broadcaster realtime.Broadcaster, log *zap.Logger) *Handler {
	if log == nil {
		log = zap.NewNop()
	}
	return &Handler{resourceSvc: resourceSvc, broadcaster: broadcaster, log: log.Named("ai_handler")}
}

// SetAsynq 注入 asynq 入队能力
func (h *Handler) SetAsynq(client *asynq.Client, tc resource.ResourceTaskCreator) {
	h.asynqClient = client
	h.taskCreator = tc
}

// GenerateImage 统一图生接口 POST /ai/generate/image
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
	if req.Output.Type == "" {
		pkg.BadRequest(c, "output.type 必填")
		return
	}

	switch req.Output.Type {
	case "resource":
		placeholder, err := h.createImagePlaceholder(c, userID, req)
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
		if h.broadcaster != nil {
			h.broadcaster.BroadcastResourceCreated(userID, placeholder.ID, "resource_image")
		}

		taskID := h.enqueueImageTask(c, userID, placeholder.ID, req)
		pkg.Created(c, map[string]any{"resource": placeholder, "taskId": taskID})
	case "character", "location":
		pkg.BadRequest(c, "output.type="+req.Output.Type+" 暂未实现，请使用对应模块接口")
	case "shot":
		pkg.BadRequest(c, "output.type=shot 请使用 POST /projects/:id/shot-images/generate 批量生成")
	default:
		pkg.BadRequest(c, "不支持的 output.type: "+req.Output.Type)
	}
}

// enqueueImageTask 创建 Task 记录 + asynq 入队；无 asynq 时降级 goroutine
func (h *Handler) enqueueImageTask(c *gin.Context, userID, resourceID string, req GenerateImageRequest) string {
	if h.asynqClient == nil || h.taskCreator == nil {
		go h.completeImageAsync(userID, resourceID, req)
		return resourceID
	}
	resReq := h.toResourceImageReq(req)
	reqJSON, _ := json.Marshal(resReq)
	taskID, err := h.taskCreator.CreateTaskForUser(c.Request.Context(), userID, "image", "图片生成: "+resReq.Name, reqJSON)
	if err != nil {
		h.log.Warn("创建 Task 记录失败，降级 goroutine", zap.Error(err))
		go h.completeImageAsync(userID, resourceID, req)
		return resourceID
	}
	payload, _ := json.Marshal(map[string]interface{}{
		"task_id":      taskID,
		"resource_id":  resourceID,
		"user_id":      userID,
		"gen_type":     "image",
		"title":        "图片生成: " + resReq.Name,
		"request_json": reqJSON,
	})
	task := asynq.NewTask(tasktypes.TypeResourceImage, payload)
	if _, err := h.asynqClient.Enqueue(task); err != nil {
		h.log.Warn("asynq 入队失败，降级 goroutine", zap.Error(err))
		go h.completeImageAsync(userID, resourceID, req)
		return resourceID
	}
	return taskID
}

// createImagePlaceholder 创建图生占位资源
func (h *Handler) createImagePlaceholder(c *gin.Context, userID string, req GenerateImageRequest) (*resource.Resource, error) {
	return h.resourceSvc.CreateImagePlaceholder(c.Request.Context(), userID, h.toResourceImageReq(req))
}

// completeImageAsync 后台 goroutine 完成图生
func (h *Handler) completeImageAsync(userID, resourceID string, req GenerateImageRequest) {
	ctx := context.Background()
	h.broadcastResourceTask(userID, resourceID, "image", "图片生成", 10, "running")

	res, err := h.resourceSvc.CompleteImage(ctx, userID, resourceID, h.toResourceImageReq(req))
	if err != nil {
		h.log.Error("图生异步完成失败",
			zap.String("resource_id", resourceID),
			zap.Error(err),
		)
		_ = h.resourceSvc.MarkResourceGenFailed(ctx, resourceID, userID, err.Error())
		h.broadcastResourceTask(userID, resourceID, "image", "图片生成", 0, "failed")
		return
	}
	h.broadcastResourceTask(userID, resourceID, "image", "图片生成", 100, "completed")
	if h.broadcaster != nil {
		h.broadcaster.BroadcastResourceCreated(userID, res.ID, "resource_image")
	}
}

func (h *Handler) toResourceImageReq(req GenerateImageRequest) resource.GenerateImageRequest {
	libraryType := req.Output.LibraryType
	if libraryType == "" {
		libraryType = "style"
	}
	modality := req.Output.Modality
	if modality == "" {
		modality = "visual"
	}
	name := req.Output.Name
	if name == "" {
		name = "生成图片"
	}
	refURL := ""
	if len(req.ReferenceImageURLs) > 0 {
		refURL = req.ReferenceImageURLs[0]
	}
	return resource.GenerateImageRequest{
		Prompt:            req.Prompt,
		NegativePrompt:    req.NegativePrompt,
		ReferenceImageURL: refURL,
		LibraryType:       libraryType,
		Modality:          modality,
		Provider:          req.Provider,
		Model:             req.Model,
		Name:              name,
		Width:             req.Width,
		Height:            req.Height,
		AspectRatio:       req.AspectRatio,
	}
}

// broadcastResourceTask 推送素材生成任务进度
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

// GenerateText 统一文本生成接口 POST /ai/generate/text
func (h *Handler) GenerateText(c *gin.Context) {
	userID := pkg.GetUserIDStr(c)
	if userID == "" {
		pkg.Unauthorized(c, "未登录")
		return
	}
	var req GenerateTextRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if req.Action == "" {
		pkg.BadRequest(c, "action 必填")
		return
	}

	switch req.Action {
	case "prompt":
		if req.Output.Type != "resource" && req.Output.Type != "" {
			pkg.BadRequest(c, "action=prompt 仅支持 output.type=resource")
			return
		}
		r := resource.GeneratePromptRequest{
			Name:        req.Name,
			Instruction: req.Instruction,
			TargetModel: req.TargetModel,
			Category:    req.Category,
			LibraryType: req.LibraryType,
			Language:    req.Language,
		}
		if req.ReferenceText != "" {
			r.Instruction = req.ReferenceText + "\n\n" + r.Instruction
		}
		res, err := h.resourceSvc.GeneratePrompt(c.Request.Context(), userID, r)
		if err != nil {
			if errors.Is(err, pkg.ErrBadRequest) {
				pkg.BadRequest(c, err.Error())
				return
			}
			pkg.HandleError(c, err)
			return
		}
		pkg.Created(c, res)
	case "storyboard", "parse":
		pkg.BadRequest(c, "action="+req.Action+" 请使用对应项目接口 POST /projects/:id/storyboard/generate-sync 或 /script/parse-sync")
	default:
		pkg.BadRequest(c, "不支持的 action: "+req.Action)
	}
}

// GenerateVoice 统一音频生成接口 POST /ai/generate/voice
func (h *Handler) GenerateVoice(c *gin.Context) {
	pkg.BadRequest(c, "音频生成暂未实现，请使用 POST /resources/generate-voice 或 /resources/generate-voice-design")
}
