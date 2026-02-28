package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// VideoCapability 文生视频能力封装
type VideoCapability struct {
	router *VideoRouter
}

// NewVideoCapability 创建文生视频能力
func NewVideoCapability(router *VideoRouter) *VideoCapability {
	return &VideoCapability{router: router}
}

// Submit 提交文生视频任务
func (c *VideoCapability) Submit(ctx context.Context, req capability.VideoRequest, preferred string) (string, string, error) {
	return c.router.Submit(ctx, req, preferred)
}

// Query 查询文生视频任务结果
func (c *VideoCapability) Query(ctx context.Context, taskID string) (*capability.VideoResult, error) {
	return c.router.Query(ctx, taskID)
}
