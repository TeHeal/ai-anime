// Package openai OpenAI 兼容适配器（DeepSeek、Kimi、阿里云等）
package openai

import (
	"context"
	"errors"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	openai "github.com/openai/openai-go/v3"
	"github.com/openai/openai-go/v3/option"
)

// Config OpenAI 兼容适配器配置
type Config struct {
	Name         string
	APIKey       string
	BaseURL      string
	DefaultModel string
}

// ChatProvider 实现 capability.ChatProvider
type ChatProvider struct {
	name         string
	defaultModel string
	client       openai.Client
}

// NewChatProvider 创建 OpenAI 兼容的 ChatProvider
func NewChatProvider(cfg Config) *ChatProvider {
	opts := []option.RequestOption{
		option.WithAPIKey(cfg.APIKey),
	}
	if cfg.BaseURL != "" {
		base := cfg.BaseURL
		if !strings.HasSuffix(base, "/") {
			base += "/"
		}
		opts = append(opts, option.WithBaseURL(base))
	}

	return &ChatProvider{
		name:         cfg.Name,
		defaultModel: cfg.DefaultModel,
		client:       openai.NewClient(opts...),
	}
}

func (p *ChatProvider) Name() string {
	return p.name
}

func (p *ChatProvider) ChatStream(ctx context.Context, req capability.ChatRequest) (<-chan capability.ChatChunk, error) {
	model := req.Model
	if model == "" {
		model = p.defaultModel
	}
	if model == "" {
		return nil, capability.Wrap(capability.ErrBadResponse, "model is required", nil)
	}

	stream := p.client.Chat.Completions.NewStreaming(ctx, openai.ChatCompletionNewParams{
		Messages: toOpenAIMessages(req.Messages),
		Model:    openai.ChatModel(model),
	})

	out := make(chan capability.ChatChunk, 32)
	go func() {
		defer close(out)
		for stream.Next() {
			event := stream.Current()
			if len(event.Choices) == 0 {
				continue
			}
			content := event.Choices[0].Delta.Content
			if content == "" {
				continue
			}
			out <- capability.ChatChunk{
				Content: content,
				Meta: map[string]string{
					"provider": p.name,
					"model":    model,
				},
			}
		}

		if err := stream.Err(); err != nil {
			out <- capability.ChatChunk{
				Done:  true,
				Error: mapOpenAIError(err),
				Meta: map[string]string{
					"provider": p.name,
					"model":    model,
				},
			}
			return
		}

		out <- capability.ChatChunk{
			Done: true,
			Meta: map[string]string{
				"provider": p.name,
				"model":    model,
			},
		}
	}()

	return out, nil
}

func toOpenAIMessages(msgs []capability.ChatMessage) []openai.ChatCompletionMessageParamUnion {
	out := make([]openai.ChatCompletionMessageParamUnion, 0, len(msgs))
	for _, m := range msgs {
		switch strings.ToLower(m.Role) {
		case "system":
			out = append(out, openai.SystemMessage(m.Content))
		case "assistant":
			out = append(out, openai.AssistantMessage(m.Content))
		case "developer":
			out = append(out, openai.DeveloperMessage(m.Content))
		default:
			out = append(out, openai.UserMessage(m.Content))
		}
	}
	return out
}

func mapOpenAIError(err error) error {
	var apiErr *openai.Error
	if errors.As(err, &apiErr) {
		switch apiErr.StatusCode {
		case 401, 403:
			return capability.Wrap(capability.ErrAuthFailed, "upstream auth failed", err)
		case 429:
			return capability.Wrap(capability.ErrRateLimited, "upstream rate limited", err)
		default:
			if apiErr.StatusCode >= 500 {
				return capability.Wrap(capability.ErrUpstream, "upstream server error", err)
			}
			return capability.Wrap(capability.ErrBadResponse, "upstream bad response", err)
		}
	}
	if errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled) {
		return capability.Wrap(capability.ErrTimeout, "request timed out", err)
	}
	return capability.Wrap(capability.ErrUpstream, "chat stream failed", err)
}
