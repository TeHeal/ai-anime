package script

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/module/script/parser"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/llm"
)

// LLMServiceAdapter 将 llm.LLMService 适配为 parser.LLMClient
type LLMServiceAdapter struct {
	svc *llm.LLMService
}

// NewLLMServiceAdapter 创建适配器
func NewLLMServiceAdapter(svc *llm.LLMService) *LLMServiceAdapter {
	return &LLMServiceAdapter{svc: svc}
}

// ChatSync 实现 parser.LLMClient
func (a *LLMServiceAdapter) ChatSync(ctx context.Context, systemPrompt, userPrompt string) (string, error) {
	return a.svc.Chat(ctx, systemPrompt, userPrompt)
}

// 编译时确保实现接口
var _ parser.LLMClient = (*LLMServiceAdapter)(nil)
