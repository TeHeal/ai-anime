package ai

import (
	"errors"

	"anime_ai/module/assets/resource"
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler AI 生成统一入口（图生、LLM、音频）
type Handler struct {
	resourceSvc *resource.Service
}

// NewHandler 创建 Handler
func NewHandler(resourceSvc *resource.Service) *Handler {
	return &Handler{resourceSvc: resourceSvc}
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
		res, err := h.generateImageResource(c, userID, req)
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
		pkg.Created(c, res)
	case "character", "location":
		pkg.BadRequest(c, "output.type="+req.Output.Type+" 暂未实现，请使用对应模块接口")
	case "shot":
		pkg.BadRequest(c, "output.type=shot 请使用 POST /projects/:id/shot-images/generate 批量生成")
	default:
		pkg.BadRequest(c, "不支持的 output.type: "+req.Output.Type)
	}
}

// generateImageResource output.type=resource 时复用 ResourceService 逻辑
func (h *Handler) generateImageResource(c *gin.Context, userID string, req GenerateImageRequest) (*resource.Resource, error) {
	ctx := c.Request.Context()
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
	r := resource.GenerateImageRequest{
		Prompt:         req.Prompt,
		NegativePrompt: req.NegativePrompt,
		ReferenceImageURL: refURL,
		LibraryType:    libraryType,
		Modality:       modality,
		Provider:       req.Provider,
		Model:          req.Model,
		Name:           name,
		Width:          req.Width,
		Height:         req.Height,
		AspectRatio:    req.AspectRatio,
	}
	return h.resourceSvc.GenerateImage(ctx, userID, r)
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
