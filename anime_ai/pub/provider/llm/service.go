package llm

import (
	"context"
	"fmt"
	"strings"

	"anime_ai/pub/provider"
)

// LLMService 统一 LLM 调用入口，自动路由到可用 Provider
type LLMService struct {
	providers []provider.LLMProvider
	byName    map[string]provider.LLMProvider
}

// NewLLMService 创建 LLMService，providers 按优先级排列
func NewLLMService(providers ...provider.LLMProvider) *LLMService {
	byName := make(map[string]provider.LLMProvider, len(providers))
	for _, p := range providers {
		byName[p.Name()] = p
	}
	return &LLMService{providers: providers, byName: byName}
}

// Available 返回是否有可用的 LLM Provider
func (s *LLMService) Available() bool {
	return len(s.providers) > 0
}

// ProviderNames 返回可用 Provider 名称列表
func (s *LLMService) ProviderNames() []string {
	names := make([]string, len(s.providers))
	for i, p := range s.providers {
		names[i] = p.Name()
	}
	return names
}

// Chat 同步调用 LLM，收集完整响应
func (s *LLMService) Chat(ctx context.Context, systemPrompt, userPrompt string) (string, error) {
	ch, err := s.ChatStream(ctx, "", "", systemPrompt, userPrompt)
	if err != nil {
		return "", err
	}
	var sb strings.Builder
	for chunk := range ch {
		if chunk.Error != "" {
			return sb.String(), fmt.Errorf("LLM 流式错误: %s", chunk.Error)
		}
		if chunk.Done {
			break
		}
		sb.WriteString(chunk.Content)
	}
	return sb.String(), nil
}

// ChatStream 流式调用 LLM，providerHint 可指定 Provider，为空则自动选择
func (s *LLMService) ChatStream(ctx context.Context, providerHint, model, systemPrompt, userPrompt string) (<-chan provider.ChatChunk, error) {
	if !s.Available() {
		return nil, fmt.Errorf("LLM 未配置：未找到可用的 LLM Provider")
	}

	messages := []provider.ChatMessage{
		{Role: "system", Content: systemPrompt},
		{Role: "user", Content: userPrompt},
	}
	req := provider.ChatRequest{
		Model:    model,
		Messages: messages,
	}

	// 指定了 Provider 则优先使用
	if providerHint != "" {
		if p, ok := s.byName[providerHint]; ok {
			return p.ChatStream(ctx, req)
		}
		return nil, fmt.Errorf("指定的 LLM Provider 不存在: %s", providerHint)
	}

	// 按优先级逐个尝试
	var lastErr error
	for _, p := range s.providers {
		ch, err := p.ChatStream(ctx, req)
		if err != nil {
			lastErr = err
			continue
		}
		return ch, nil
	}
	return nil, fmt.Errorf("所有 LLM Provider 调用失败: %w", lastErr)
}

// ChatWithJSON 同步调用 LLM 并要求返回 JSON 格式
func (s *LLMService) ChatWithJSON(ctx context.Context, systemPrompt, userPrompt string) (string, error) {
	if !s.Available() {
		return "", fmt.Errorf("LLM 未配置：未找到可用的 LLM Provider")
	}

	messages := []provider.ChatMessage{
		{Role: "system", Content: systemPrompt},
		{Role: "user", Content: userPrompt},
	}
	req := provider.ChatRequest{
		Model:          "",
		Messages:       messages,
		ResponseFormat: "json_object",
	}

	var lastErr error
	for _, p := range s.providers {
		ch, err := p.ChatStream(ctx, req)
		if err != nil {
			lastErr = err
			continue
		}
		var sb strings.Builder
		for chunk := range ch {
			if chunk.Error != "" {
				lastErr = fmt.Errorf("LLM 流式错误: %s", chunk.Error)
				break
			}
			if chunk.Done {
				break
			}
			sb.WriteString(chunk.Content)
		}
		result := sb.String()
		if result != "" {
			return result, nil
		}
	}
	if lastErr != nil {
		return "", fmt.Errorf("所有 LLM Provider 调用失败: %w", lastErr)
	}
	return "", fmt.Errorf("LLM 返回空结果")
}
