package character

import (
	"errors"
	"strconv"

	"anime_ai/pub/auth"
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 角色 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建 Handler 实例
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// parseCharID 解析角色 ID，支持 UUID 或数字格式，直接返回字符串
func parseCharID(s string) (string, error) {
	if s == "" {
		return "", errors.New("empty character id")
	}
	return s, nil
}

// Create 创建角色
func (h *Handler) Create(c *gin.Context) {
	userIDStr := pkg.GetUserIDStr(c)
	if userIDStr == "" {
		pkg.Unauthorized(c, "未登录或无效用户")
		return
	}

	var req CreateCharacterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	char, err := h.svc.Create(userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, char)
}

// Get 获取角色详情
func (h *Handler) Get(c *gin.Context) {
	id, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	char, err := h.svc.Get(id, userIDStr)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// ListByProject 按项目列出角色
func (h *Handler) ListByProject(c *gin.Context) {
	projectIDStr := auth.GetProjectIDStr(c)
	if projectIDStr == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)
	if userIDStr == "" {
		pkg.BadRequest(c, "未登录或无效用户")
		return
	}
	chars, err := h.svc.ListByProject(projectIDStr, userIDStr)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, chars)
}

// ListLibrary 列出角色库
func (h *Handler) ListLibrary(c *gin.Context) {
	userIDStr := pkg.GetUserIDStr(c)
	if userIDStr == "" {
		pkg.Unauthorized(c, "未登录或无效用户")
		return
	}

	chars, err := h.svc.ListLibrary(userIDStr)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, chars)
}

// Update 更新角色
func (h *Handler) Update(c *gin.Context) {
	id, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req UpdateCharacterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	char, err := h.svc.Update(id, userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// Delete 删除角色
func (h *Handler) Delete(c *gin.Context) {
	id, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	if err := h.svc.Delete(id, userIDStr); err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, nil)
}

// Confirm 确认角色
func (h *Handler) Confirm(c *gin.Context) {
	id, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	char, err := h.svc.Confirm(id, userIDStr)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// BatchConfirm 批量确认
func (h *Handler) BatchConfirm(c *gin.Context) {
	userIDStr := pkg.GetUserIDStr(c)
	if userIDStr == "" {
		pkg.Unauthorized(c, "未登录或无效用户")
		return
	}

	var req struct {
		IDs []string `json:"ids" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	chars, err := h.svc.BatchConfirmWithUserStr(req.IDs, userIDStr)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, chars)
}

// BatchSetStyle 批量设置风格
func (h *Handler) BatchSetStyle(c *gin.Context) {
	userIDStr := pkg.GetUserIDStr(c)
	if userIDStr == "" {
		pkg.Unauthorized(c, "未登录或无效用户")
		return
	}

	var req struct {
		IDs   []string `json:"ids" binding:"required"`
		Style string   `json:"style" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	count, err := h.svc.BatchSetStyle(req.IDs, userIDStr, req.Style)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"updated": count})
}

// BatchAIComplete 批量 AI 补全
func (h *Handler) BatchAIComplete(c *gin.Context) {
	userIDStr := pkg.GetUserIDStr(c)
	if userIDStr == "" {
		pkg.Unauthorized(c, "未登录或无效用户")
		return
	}

	var req struct {
		IDs []string `json:"ids" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	count, err := h.svc.BatchAIComplete(req.IDs, userIDStr)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, gin.H{"completed": count})
}

// AddVariant 添加变体
func (h *Handler) AddVariant(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req AddVariantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	char, err := h.svc.AddVariant(charID, userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, char)
}

// UpdateVariant 更新变体
func (h *Handler) UpdateVariant(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	idx, err := strconv.Atoi(c.Param("idx"))
	if err != nil {
		pkg.BadRequest(c, "无效的变体索引")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req UpdateVariantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	char, err := h.svc.UpdateVariant(charID, userIDStr, idx, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// DeleteVariant 删除变体
func (h *Handler) DeleteVariant(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	idx, err := strconv.Atoi(c.Param("idx"))
	if err != nil {
		pkg.BadRequest(c, "无效的变体索引")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	char, err := h.svc.DeleteVariant(charID, userIDStr, idx)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// AddReferenceImage 添加参考图
func (h *Handler) AddReferenceImage(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req AddReferenceImageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	char, err := h.svc.AddReferenceImage(charID, userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.Created(c, char)
}

// DeleteReferenceImage 删除参考图
func (h *Handler) DeleteReferenceImage(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	idx, err := strconv.Atoi(c.Param("idx"))
	if err != nil {
		pkg.BadRequest(c, "无效的参考图索引")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	char, err := h.svc.DeleteReferenceImage(charID, userIDStr, idx)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// GenerateImage 形象生成
func (h *Handler) GenerateImage(c *gin.Context) {
	id, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req struct {
		Provider string `json:"provider"`
		Model    string `json:"model"`
	}
	_ = c.ShouldBindJSON(&req)

	char, err := h.svc.GenerateImage(id, userIDStr, req.Provider, req.Model)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// GenerateCandidates 生成候选
func (h *Handler) GenerateCandidates(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req GenerateCandidatesRequest
	_ = c.ShouldBindJSON(&req)

	resp, err := h.svc.GenerateCandidates(charID, userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, resp)
}

// GetCandidates 获取候选
func (h *Handler) GetCandidates(c *gin.Context) {
	taskID := c.Query("taskId")
	if taskID == "" {
		pkg.BadRequest(c, "缺少 taskId 参数")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	resp, err := h.svc.GetCandidates(taskID, userIDStr)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, resp)
}

// SelectCandidate 选择候选
func (h *Handler) SelectCandidate(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req SelectCandidateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	char, err := h.svc.SelectCandidate(charID, userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// UpdateBio 更新小传
func (h *Handler) UpdateBio(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req struct {
		Bio string `json:"bio"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "请求参数错误")
		return
	}

	char, err := h.svc.UpdateBio(charID, userIDStr, req.Bio)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// ExtractBio 从剧本提取小传
func (h *Handler) ExtractBio(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	projectIDStr := auth.GetProjectIDStr(c)
	if projectIDStr == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)
	if userIDStr == "" {
		pkg.BadRequest(c, "未登录或无效用户")
		return
	}
	var req ExtractBioRequest
	_ = c.ShouldBindJSON(&req)

	char, err := h.svc.ExtractBio(c.Request.Context(), projectIDStr, charID, userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}

// RegenerateBio 重新生成小传
func (h *Handler) RegenerateBio(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}
	userIDStr := pkg.GetUserIDStr(c)

	var req ExtractBioRequest
	_ = c.ShouldBindJSON(&req)

	char, err := h.svc.RegenerateBio(c.Request.Context(), charID, userIDStr, req)
	if err != nil {
		pkg.HandleError(c, err)
		return
	}
	pkg.OK(c, char)
}
