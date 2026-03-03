package file

import (
	"fmt"
	"path/filepath"
	"strings"

	"anime_ai/pub/pkg"
	"anime_ai/pub/storage"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// Handler 通用文件上传接口
type Handler struct {
	store storage.Storage
}

// NewHandler 创建文件上传 Handler
func NewHandler(store storage.Storage) *Handler {
	return &Handler{store: store}
}

// Upload 上传文件，返回可访问 URL
// POST /files/upload
// Form: category (voice|general), file (multipart)
// Response: { url: "/files/{category}/{uuid}.{ext}" }
func (h *Handler) Upload(c *gin.Context) {
	if h.store == nil {
		pkg.InternalError(c, "存储未配置")
		return
	}
	file, err := c.FormFile("file")
	if err != nil {
		pkg.BadRequest(c, "缺少文件: "+err.Error())
		return
	}
	category := c.PostForm("category")
	if category == "" {
		category = "general"
	}
	// 仅允许安全分类
	if category != "voice" && category != "general" {
		category = "general"
	}

	ext := filepath.Ext(file.Filename)
	if ext == "" {
		ext = ".bin"
	}
	path := fmt.Sprintf("%s/%s%s", category, uuid.New().String(), ext)

	f, err := file.Open()
	if err != nil {
		pkg.InternalError(c, "打开文件失败")
		return
	}
	defer f.Close()

	url, err := h.store.Put(c.Request.Context(), path, f, file.Header.Get("Content-Type"))
	if err != nil {
		pkg.InternalError(c, "上传失败: "+err.Error())
		return
	}
	// 确保返回的 URL 可被 fetchSampleAudio 识别（/files/xxx）
	if !strings.HasPrefix(url, "/") {
		url = "/" + url
	}
	pkg.OK(c, map[string]string{"url": url})
}
