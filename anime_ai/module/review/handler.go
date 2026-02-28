package review

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 审核 HTTP 接口层
type Handler struct {
	svc *Service
}

// NewHandler 创建审核 Handler
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// SubmitReview 提交审核
func (h *Handler) SubmitReview(c *gin.Context) {
	projectID := c.Param("id")
	var req SubmitReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	record, err := h.svc.SubmitForReview(projectID, req)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, record)
}

// HumanDecide 人工审核决策
func (h *Handler) HumanDecide(c *gin.Context) {
	recordID := c.Param("reviewId")
	reviewerID := pkg.GetUserIDStr(c)
	var req DecideReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	if err := h.svc.HumanDecide(recordID, reviewerID, req); err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.OK(c, gin.H{"message": "审核完成"})
}

// GetRecord 获取审核记录
func (h *Handler) GetRecord(c *gin.Context) {
	id := c.Param("reviewId")
	record, err := h.svc.GetRecord(id)
	if err != nil {
		pkg.NotFound(c, "审核记录不存在")
		return
	}
	pkg.OK(c, record)
}

// ListByProject 获取项目审核列表
func (h *Handler) ListByProject(c *gin.Context) {
	projectID := c.Param("id")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	records, err := h.svc.ListByProject(projectID, limit, offset)
	if err != nil {
		pkg.InternalError(c, "获取审核列表失败")
		return
	}
	pkg.OK(c, records)
}

// CountPending 获取待审核数量
func (h *Handler) CountPending(c *gin.Context) {
	projectID := c.Param("id")
	count, err := h.svc.CountPending(projectID)
	if err != nil {
		pkg.InternalError(c, "获取待审核数量失败")
		return
	}
	pkg.OK(c, gin.H{"count": count})
}

// GetConfig 获取审核配置
func (h *Handler) GetConfig(c *gin.Context) {
	projectID := c.Param("id")
	phase := c.Query("phase")
	if phase != "" {
		cfg, err := h.svc.GetConfig(projectID, phase)
		if err != nil {
			pkg.NotFound(c, "配置不存在")
			return
		}
		pkg.OK(c, cfg)
		return
	}
	configs, err := h.svc.ListConfigs(projectID)
	if err != nil {
		pkg.InternalError(c, "获取配置失败")
		return
	}
	pkg.OK(c, configs)
}

// UpdateConfig 更新审核配置
func (h *Handler) UpdateConfig(c *gin.Context) {
	projectID := c.Param("id")
	var req UpdateConfigRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}
	cfg, err := h.svc.UpdateConfig(projectID, req)
	if err != nil {
		pkg.BadRequest(c, err.Error())
		return
	}
	pkg.OK(c, cfg)
}
