package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// ImageCapability 文生图能力封装
type ImageCapability struct {
	router *ImageRouter
}

// NewImageCapability 创建文生图能力
func NewImageCapability(router *ImageRouter) *ImageCapability {
	return &ImageCapability{router: router}
}

// Submit 提交文生图任务
func (c *ImageCapability) Submit(ctx context.Context, req capability.ImageRequest, preferred string) (string, string, error) {
	return c.router.Submit(ctx, req, preferred)
}

// Query 查询文生图任务结果
func (c *ImageCapability) Query(ctx context.Context, taskID string) (*capability.ImageResult, error) {
	return c.router.Query(ctx, taskID)
}
