// Package volc 火山引擎适配器（豆包等）
package volc

import (
	"context"
	"errors"
	"io"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/volcengine/volcengine-go-sdk/service/arkruntime"
	"github.com/volcengine/volcengine-go-sdk/service/arkruntime/model"
)

// Config 火山引擎适配器配置
type Config struct {
	Name         string
	APIKey       string
	DefaultModel string
}

// ChatProvider 实现 capability.ChatProvider
type ChatProvider struct {
	name         string
	defaultModel string
	client       *arkruntime.Client
}

// NewChatProvider 创建火山引擎 ChatProvider
func NewChatProvider(cfg Config) *ChatProvider {
	return &ChatProvider{
		name:         cfg.Name,
		defaultModel: cfg.DefaultModel,
		client:       arkruntime.NewClientWithApiKey(cfg.APIKey),
	}
}

func (p *ChatProvider) Name() string {
	return p.name
}

func (p *ChatProvider) ChatStream(ctx context.Context, req capability.ChatRequest) (<-chan capability.ChatChunk, error) {
	modelName := req.Model
	if modelName == "" {
		modelName = p.defaultModel
	}
	if modelName == "" {
		return nil, capability.Wrap(capability.ErrBadResponse, "model is required", nil)
	}

	messages := make([]*model.ChatCompletionMessage, 0, len(req.Messages))
	for _, m := range req.Messages {
		content := m.Content
		msg := &model.ChatCompletionMessage{
			Role:    normalizedRole(m.Role),
			Content: &model.ChatCompletionMessageContent{StringValue: &content},
		}
		messages = append(messages, msg)
	}

	chatReq := model.ChatCompletionRequest{
		Model:    modelName,
		Messages: messages,
		Stream:   true,
	}

	stream, err := p.client.CreateChatCompletionStream(ctx, chatReq)
	if err != nil {
		return nil, mapVolcError(err)
	}

	out := make(chan capability.ChatChunk, 32)
	go func() {
		defer close(out)
		defer stream.Close()

		for {
			resp, err := stream.Recv()
			if errors.Is(err, io.EOF) {
				out <- capability.ChatChunk{
					Done: true,
					Meta: map[string]string{
						"provider": p.name,
						"model":    modelName,
					},
				}
				return
			}
			if err != nil {
				out <- capability.ChatChunk{
					Done:  true,
					Error: mapVolcError(err),
					Meta: map[string]string{
						"provider": p.name,
						"model":    modelName,
					},
				}
				return
			}
			if len(resp.Choices) == 0 {
				continue
			}
			content := resp.Choices[0].Delta.Content
			if content == "" {
				continue
			}
			out <- capability.ChatChunk{
				Content: content,
				Meta: map[string]string{
					"provider": p.name,
					"model":    modelName,
				},
			}
		}
	}()

	return out, nil
}

func normalizedRole(role string) string {
	switch strings.ToLower(role) {
	case model.ChatMessageRoleSystem:
		return model.ChatMessageRoleSystem
	case model.ChatMessageRoleAssistant:
		return model.ChatMessageRoleAssistant
	case "developer":
		return model.ChatMessageRoleSystem
	default:
		return model.ChatMessageRoleUser
	}
}

func mapVolcError(err error) error {
	if errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled) {
		return capability.Wrap(capability.ErrTimeout, "volc request timed out", err)
	}
	return capability.Wrap(capability.ErrUpstream, "volc chat stream failed", err)
}
