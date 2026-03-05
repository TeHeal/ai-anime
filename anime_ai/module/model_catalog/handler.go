package model_catalog

import (
	"sort"
	"strings"

	"anime_ai/pub/controlplane"
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// Handler 模型目录 HTTP 接口层
type Handler struct{}

// NewHandler 创建 Handler 实例
func NewHandler() *Handler {
	return &Handler{}
}

// List 获取模型目录列表，按 service 筛选
// GET /models?service=image|video|tts|music|llm
func (h *Handler) List(c *gin.Context) {
	svcParam := strings.TrimSpace(c.Query("service"))

	// service 必填，避免返回全量
	if svcParam == "" {
		pkg.BadRequest(c, "参数 service 必填，可选值: image, video, tts, music, llm")
		return
	}

	// 支持前端别名映射
	canonical := normalizeService(svcParam)

	catalog := controlplane.BuildModelCatalog()
	items := filterByService(catalog, canonical)
	sort.Slice(items, func(i, j int) bool {
		if items[i].Priority != items[j].Priority {
			return items[i].Priority > items[j].Priority
		}
		return items[i].DisplayName < items[j].DisplayName
	})

	pkg.OK(c, gin.H{"items": items})
}

// normalizeService 将前端 serviceType 映射为后端 canonical 值
func normalizeService(s string) string {
	if alias, ok := controlplane.ServiceAliases()[s]; ok {
		return alias
	}
	return s
}

// filterByService 按 service 筛选模型
func filterByService(catalog []controlplane.ModelCatalogAPIItem, service string) []controlplane.ModelCatalogAPIItem {
	if service == "" {
		return catalog
	}
	out := make([]controlplane.ModelCatalogAPIItem, 0, len(catalog))
	for _, m := range catalog {
		if m.Service == service {
			out = append(out, m)
		}
	}
	return out
}
