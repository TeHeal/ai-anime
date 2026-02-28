package character

import (
	"errors"
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// ListByCharacter 按角色列出快照 GET /characters/:charId/snapshots
func (h *Handler) ListByCharacter(c *gin.Context) {
	charID, err := parseCharID(c.Param("charId"))
	if err != nil {
		pkg.BadRequest(c, "无效的角色 ID")
		return
	}

	snapshots, err := h.svc.ListSnapshotsByCharacter(charID)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, snapshots)
}

// ListSnapshotsByProject 按项目列出快照 GET /projects/:id/character-snapshots
func (h *Handler) ListSnapshotsByProject(c *gin.Context) {
	projectID, err := parseProjectID(c.Param("id"))
	if err != nil {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userID := c.GetUint("user_id")

	snapshots, err := h.svc.ListSnapshotsByProject(projectID, userID)
	if err != nil {
		if errors.Is(err, pkg.ErrNotFound) {
			pkg.NotFound(c, "项目不存在")
			return
		}
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, snapshots)
}

// GetSnapshot 获取快照详情 GET /character-snapshots/:snapshotId
func (h *Handler) GetSnapshot(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("snapshotId"), 10, 64)
	if err != nil {
		pkg.BadRequest(c, "无效的快照 ID")
		return
	}

	snap, err := h.svc.GetSnapshot(uint(id))
	if err != nil {
		pkg.InternalError(c, "快照不存在")
		return
	}
	pkg.OK(c, snap)
}

// CreateSnapshot 创建快照 POST /character-snapshots
func (h *Handler) CreateSnapshot(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req CreateSnapshotRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	snap, err := h.svc.CreateSnapshot(userID, req)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.Created(c, snap)
}

// UpdateSnapshot 更新快照 PUT /character-snapshots/:snapshotId
func (h *Handler) UpdateSnapshot(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("snapshotId"), 10, 64)
	if err != nil {
		pkg.BadRequest(c, "无效的快照 ID")
		return
	}

	var req UpdateSnapshotRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkg.BadRequest(c, "参数错误: "+err.Error())
		return
	}

	snap, err := h.svc.UpdateSnapshot(uint(id), req)
	if err != nil {
		pkg.InternalError(c, "快照不存在")
		return
	}
	pkg.OK(c, snap)
}

// DeleteSnapshot 删除快照 DELETE /character-snapshots/:snapshotId
func (h *Handler) DeleteSnapshot(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("snapshotId"), 10, 64)
	if err != nil {
		pkg.BadRequest(c, "无效的快照 ID")
		return
	}

	if err := h.svc.DeleteSnapshot(uint(id)); err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, nil)
}

// AnalyzePreview 角色分析预览 POST /projects/:id/characters/analyze-preview
func (h *Handler) AnalyzePreview(c *gin.Context) {
	projectID, err := parseProjectID(c.Param("id"))
	if err != nil {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userID := c.GetUint("user_id")

	var req AnalyzeRequest
	_ = c.ShouldBindJSON(&req)

	result, err := h.svc.AnalyzePreview(c.Request.Context(), projectID, userID, req)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, result)
}

// AnalyzeConfirm 角色分析确认 POST /projects/:id/characters/analyze
func (h *Handler) AnalyzeConfirm(c *gin.Context) {
	projectID, err := parseProjectID(c.Param("id"))
	if err != nil {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userID := c.GetUint("user_id")

	var req AnalyzeRequest
	_ = c.ShouldBindJSON(&req)

	result, err := h.svc.AnalyzeConfirm(c.Request.Context(), projectID, userID, req)
	if err != nil {
		pkg.InternalError(c, err.Error())
		return
	}
	pkg.OK(c, result)
}
