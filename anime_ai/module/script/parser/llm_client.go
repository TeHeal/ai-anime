package parser

import "context"

// LLMClient 抽象 LLM 调用，parser 不依赖具体 Provider
type LLMClient interface {
	// ChatSync 发送 prompt 并返回完整响应文本
	ChatSync(ctx context.Context, systemPrompt, userPrompt string) (string, error)
}
