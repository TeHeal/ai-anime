// Package provider AI Provider 实现（llm、image、video、audio、music、kie）
package provider

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// ── Chat 类型（Provider 层，与 capability.Chat* 区分）──

// ChatMessage 对话消息
type ChatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// ChatRequest 流式对话请求
type ChatRequest struct {
	Model          string        `json:"model"`
	Messages       []ChatMessage `json:"messages"`
	ResponseFormat string        `json:"response_format,omitempty"`
}

// ChatChunk 流式输出块
type ChatChunk struct {
	Content string `json:"content"`
	Done    bool   `json:"done"`
	Error   string `json:"error,omitempty"`
}

// LLMProvider 流式对话抽象
type LLMProvider interface {
	Name() string
	ChatStream(ctx context.Context, req ChatRequest) (<-chan ChatChunk, error)
}

// ── 与 capability 对齐的类型别名 ──

type ImageRequest = capability.ImageRequest
type ImageResult = capability.ImageResult
type ImageProvider = capability.ImageProvider

type VideoRequest = capability.VideoRequest
type VideoResult = capability.VideoResult
type VideoProvider = capability.VideoProvider

type TTSRequest = capability.TTSRequest
type TTSResult = capability.TTSResult
type TTSProvider = capability.TTSProvider

type MusicRequest = capability.MusicRequest
type MusicResult = capability.MusicResult
type MusicProvider = capability.MusicProvider
