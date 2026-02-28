package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// ChatCapability 对话能力封装
type ChatCapability struct {
	router *Router
}

// NewChatCapability 创建对话能力
func NewChatCapability(router *Router) *ChatCapability {
	return &ChatCapability{router: router}
}

// ChatStream 流式对话
func (c *ChatCapability) ChatStream(ctx context.Context, req capability.ChatRequest) (<-chan capability.ChatChunk, error) {
	return c.router.ChatStream(ctx, req)
}
