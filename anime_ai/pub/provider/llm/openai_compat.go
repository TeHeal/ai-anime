// Package llm LLM Provider 实现（OpenAI 兼容、DeepSeek、Kimi、豆包等）
package llm

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/provider"
)

// OpenAICompatProvider 实现 LLMProvider，兼容 OpenAI API（DeepSeek、Kimi、阿里云等）
type OpenAICompatProvider struct {
	name    string
	baseURL string
	apiKey  string
	client  *http.Client
}

// NewOpenAICompatProvider 创建 OpenAI 兼容 Provider
func NewOpenAICompatProvider(name, baseURL, apiKey string) *OpenAICompatProvider {
	return &OpenAICompatProvider{
		name:    name,
		baseURL: strings.TrimRight(baseURL, "/"),
		apiKey:  apiKey,
		client:  &http.Client{},
	}
}

func (p *OpenAICompatProvider) Name() string { return p.name }

type chatCompletionRequest struct {
	Model          string                 `json:"model"`
	Messages       []provider.ChatMessage `json:"messages"`
	Stream         bool                   `json:"stream"`
	ResponseFormat *responseFormat         `json:"response_format,omitempty"`
}

type responseFormat struct {
	Type string `json:"type"`
}

type sseData struct {
	Choices []struct {
		Delta struct {
			Content string `json:"content"`
		} `json:"delta"`
		FinishReason *string `json:"finish_reason"`
	} `json:"choices"`
}

func (p *OpenAICompatProvider) ChatStream(ctx context.Context, req provider.ChatRequest) (<-chan provider.ChatChunk, error) {
	body := chatCompletionRequest{
		Model:    req.Model,
		Messages: req.Messages,
		Stream:   true,
	}
	if req.ResponseFormat == "json_object" {
		body.ResponseFormat = &responseFormat{Type: "json_object"}
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, p.baseURL+"/chat/completions", bytes.NewReader(bodyBytes))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)
	httpReq.Header.Set("Accept", "text/event-stream")

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("send request: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		resp.Body.Close()
		return nil, fmt.Errorf("API error %d: %s", resp.StatusCode, string(respBody))
	}

	ch := make(chan provider.ChatChunk, 32)
	go func() {
		defer close(ch)
		defer resp.Body.Close()

		scanner := bufio.NewScanner(resp.Body)
		for scanner.Scan() {
			select {
			case <-ctx.Done():
				return
			default:
			}

			line := scanner.Text()
			if !strings.HasPrefix(line, "data: ") {
				continue
			}
			data := strings.TrimPrefix(line, "data: ")
			if data == "[DONE]" {
				ch <- provider.ChatChunk{Done: true}
				return
			}

			var sse sseData
			if err := json.Unmarshal([]byte(data), &sse); err != nil {
				continue
			}

			if len(sse.Choices) > 0 {
				content := sse.Choices[0].Delta.Content
				if content != "" {
					select {
					case ch <- provider.ChatChunk{Content: content}:
					case <-ctx.Done():
						return
					}
				}
				if sse.Choices[0].FinishReason != nil {
					ch <- provider.ChatChunk{Done: true}
					return
				}
			}
		}
		if err := scanner.Err(); err != nil && ctx.Err() == nil {
			ch <- provider.ChatChunk{Error: fmt.Sprintf("stream read error: %v", err)}
		}
	}()

	return ch, nil
}
