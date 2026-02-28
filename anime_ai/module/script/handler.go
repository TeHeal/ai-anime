package script

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 脚本 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建脚本 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) getProjectID(c *gin.Context) (uint, bool) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		pkg.BadRequest(c, "无效的项目 ID")
		return 0, false
	}
	return uint(id), true
}

// getSegmentID 解析分段 ID，支持 UUID 或数字格式
func (h *Handler) getSegmentID(c *gin.Context) (string, bool) {
	id := c.Param("segId")
	if id == "" {
		pkg.BadRequest(c, "无效的段落 ID")
		return "", false
	}
	return id, true
}

// Create 创建分段
func (h *Handler) Create(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req CreateSegmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	seg, err := h.svc.Create(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, seg.ToResponse())
}

// BulkCreate 批量创建分段
func (h *Handler) BulkCreate(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req BulkCreateSegmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	segments, err := h.svc.BulkCreate(projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	resp := make([]SegmentResponse, len(segments))
	for i := range segments {
		resp[i] = segments[i].ToResponse()
	}
	pkg.OK(c, resp)
}

// List 列出分段
func (h *Handler) List(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	segments, err := h.svc.List(projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	resp := make([]SegmentResponse, len(segments))
	for i := range segments {
		resp[i] = segments[i].ToResponse()
	}
	pkg.OK(c, resp)
}

// Update 更新分段
func (h *Handler) Update(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	segID, ok := h.getSegmentID(c)
	if !ok {
		return
	}
	var req UpdateSegmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	seg, err := h.svc.Update(segID, projectID, userID, req)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "段落不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, seg.ToResponse())
}

// Delete 删除分段
func (h *Handler) Delete(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	segID, ok := h.getSegmentID(c)
	if !ok {
		return
	}
	if err := h.svc.Delete(segID, projectID, userID); err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "段落不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// Reorder 排序分段
func (h *Handler) Reorder(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req ReorderSegmentsRequest
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

// Parse 提交异步解析任务
func (h *Handler) Parse(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req ScriptParseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	task, err := h.svc.SubmitParse(projectID, userID, req)
	if err != nil {
		pkg.InternalError(c, "提交解析任务失败: "+err.Error())
		return
	}
	pkg.OK(c, gin.H{
		"task_id": task.TaskID,
		"status":  task.Status,
	})
}

// ParseSync 同步解析
func (h *Handler) ParseSync(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req ScriptParseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	result, err := h.svc.ParseSync(c.Request.Context(), projectID, userID, req)
	if err != nil {
		pkg.InternalError(c, "解析失败: "+err.Error())
		return
	}
	pkg.OK(c, result)
}

// Preview 获取解析预览
func (h *Handler) Preview(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	result, err := h.svc.GetPreview(projectID, userID)
	if err != nil {
		pkg.NotFound(c, "解析结果不存在或未完成: "+err.Error())
		return
	}
	pkg.OK(c, result)
}

// Confirm 确认导入解析结果
func (h *Handler) Confirm(c *gin.Context) {
	userID := c.GetUint("user_id")
	projectID, ok := h.getProjectID(c)
	if !ok {
		return
	}
	var req ScriptConfirmRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.Confirm(projectID, userID, req); err != nil {
		pkg.InternalError(c, "导入失败: "+err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "剧本导入成功"})
}

// Assist AI 流式辅助（SSE）
func (h *Handler) Assist(c *gin.Context) {
	var req ScriptAiRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	ch, err := h.svc.StreamAssist(c.Request.Context(), req)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.Header().Set("X-Accel-Buffering", "no")
	c.Stream(func(w io.Writer) bool {
		chunk, ok := <-ch
		if !ok {
			return false
		}
		if chunk.Error != "" {
			writeSSE(w, map[string]string{"error": chunk.Error})
			return false
		}
		if chunk.Done {
			fmt.Fprint(w, "data: [DONE]\n\n")
			return false
		}
		writeSSE(w, map[string]string{"content": chunk.Content})
		return true
	})
}

func writeSSE(w io.Writer, v interface{}) {
	b, _ := json.Marshal(v)
	fmt.Fprintf(w, "data: %s\n\n", b)
}
