// Package audio TTS、克隆等音频 Provider 实现
package audio

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// MiniMaxTTSProvider MiniMax TTS（骨架，后续完善）
type MiniMaxTTSProvider struct {
	apiKey string
}

// NewMiniMaxTTSProvider 创建 MiniMax TTS Provider
func NewMiniMaxTTSProvider(apiKey string) *MiniMaxTTSProvider {
	return &MiniMaxTTSProvider{apiKey: apiKey}
}

func (p *MiniMaxTTSProvider) Name() string { return "minimax_tts" }

func (p *MiniMaxTTSProvider) SubmitTTSTask(ctx context.Context, req capability.TTSRequest) (string, error) {
	_ = ctx
	_ = req
	return "", fmt.Errorf("minimax_tts provider: 骨架待完善")
}

func (p *MiniMaxTTSProvider) QueryTTSTask(ctx context.Context, taskID string) (*capability.TTSResult, error) {
	_ = ctx
	_ = taskID
	return nil, fmt.Errorf("minimax_tts provider: 骨架待完善")
}
