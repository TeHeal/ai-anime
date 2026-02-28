package download

import (
	"io"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/pub/storage"
	"github.com/gin-gonic/gin"
)

// Handler 单文件下载接口（README 2.7 生成物下载）
type Handler struct {
	store    storage.Storage
	verifier crossmodule.ProjectVerifier
}

// NewHandler 创建下载 Handler
func NewHandler(store storage.Storage, verifier crossmodule.ProjectVerifier) *Handler {
	return &Handler{store: store, verifier: verifier}
}

// Download 代理下载：验证项目权限后从存储流式返回文件
// GET /projects/:id/download?path=xxx 或 ?url=xxx
// path: 存储相对路径（如 resource/generated/xxx.png）
// url: 完整 URL，若以 BaseURL 开头则提取 path
func (h *Handler) Download(c *gin.Context) {
	if h.store == nil {
		pkg.InternalError(c, "存储未配置")
		return
	}
	projectID := c.Param("id")
	if projectID == "" {
		pkg.BadRequest(c, "无效的项目 ID")
		return
	}
	userID := pkg.GetUserIDStr(c)
	if h.verifier != nil {
		if err := h.verifier.Verify(projectID, userID); err != nil {
			pkg.Forbidden(c, "无权限访问该项目")
			return
		}
	}
	path := c.Query("path")
	urlParam := c.Query("url")
	if path == "" && urlParam != "" {
		base := h.store.BaseURL()
		if base != "" && strings.HasPrefix(urlParam, base) {
			path = strings.TrimPrefix(strings.TrimPrefix(urlParam, base), "/")
		}
	}
	if path == "" {
		pkg.BadRequest(c, "缺少 path 或 url 参数")
		return
	}
	// 简单校验：path 需包含 project 或 resource，防止任意路径遍历
	if !strings.Contains(path, "project") && !strings.HasPrefix(path, "resource/") {
		pkg.BadRequest(c, "无效的下载路径")
		return
	}
	if strings.Contains(path, "..") {
		pkg.BadRequest(c, "无效的下载路径")
		return
	}
	reader, err := h.store.Get(c.Request.Context(), path)
	if err != nil {
		pkg.NotFound(c, "文件不存在")
		return
	}
	defer reader.Close()
	parts := strings.Split(path, "/")
	filename := "download"
	if len(parts) > 0 {
		filename = parts[len(parts)-1]
	}
	c.Header("Content-Disposition", "attachment; filename=\""+filename+"\"")
	c.Header("Content-Type", "application/octet-stream")
	c.Status(200)
	_, _ = io.Copy(c.Writer, reader)
}
