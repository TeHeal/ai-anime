package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// TTSCapability TTS 能力封装
type TTSCapability struct {
	router *TTSRouter
}

// NewTTSCapability 创建 TTS 能力
func NewTTSCapability(router *TTSRouter) *TTSCapability {
	return &TTSCapability{router: router}
}

// Submit 提交 TTS 任务
func (c *TTSCapability) Submit(ctx context.Context, req capability.TTSRequest, preferred string) (string, string, error) {
	return c.router.Submit(ctx, req, preferred)
}

// Query 查询 TTS 任务结果
func (c *TTSCapability) Query(ctx context.Context, taskID string) (*capability.TTSResult, error) {
	return c.router.Query(ctx, taskID)
}
