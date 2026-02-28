package llm

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider"
)

// ChatProviderAdapter 将 provider.LLMProvider 适配为 capability.ChatProvider
type ChatProviderAdapter struct {
	inner *OpenAICompatProvider
}

// AsChatProvider 将 OpenAICompatProvider 转换为 capability.ChatProvider
func AsChatProvider(p *OpenAICompatProvider) capability.ChatProvider {
	return &ChatProviderAdapter{inner: p}
}

// Name 返回 Provider 名称
func (a *ChatProviderAdapter) Name() string {
	return a.inner.Name()
}

// ChatStream 将 capability.ChatRequest 转换为 provider.ChatRequest 后调用
func (a *ChatProviderAdapter) ChatStream(ctx context.Context, req capability.ChatRequest) (<-chan capability.ChatChunk, error) {
	// 转换消息格式
	msgs := make([]provider.ChatMessage, len(req.Messages))
	for i, m := range req.Messages {
		msgs[i] = provider.ChatMessage{Role: m.Role, Content: m.Content}
	}

	provReq := provider.ChatRequest{
		Model:    req.Model,
		Messages: msgs,
	}

	provCh, err := a.inner.ChatStream(ctx, provReq)
	if err != nil {
		return nil, err
	}

	// 转换输出流
	out := make(chan capability.ChatChunk, 16)
	go func() {
		defer close(out)
		for chunk := range provCh {
			cc := capability.ChatChunk{
				Content: chunk.Content,
				Done:    chunk.Done,
			}
			if chunk.Error != "" {
				cc.Error = fmt.Errorf("%s", chunk.Error)
			}
			out <- cc
		}
	}()
	return out, nil
}
