// Package video 文生视频 Provider 实现
package video

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// SeedanceProvider 字节 Seedance 文生视频（骨架，后续完善）
type SeedanceProvider struct {
	apiKey string
}

// NewSeedanceProvider 创建 Seedance Provider
func NewSeedanceProvider(apiKey string) *SeedanceProvider {
	return &SeedanceProvider{apiKey: apiKey}
}

func (p *SeedanceProvider) Name() string { return "seedance" }

func (p *SeedanceProvider) SubmitVideoTask(ctx context.Context, req capability.VideoRequest) (string, error) {
	_ = ctx
	_ = req
	return "", fmt.Errorf("seedance provider: 骨架待完善")
}

func (p *SeedanceProvider) QueryVideoTask(ctx context.Context, taskID string) (*capability.VideoResult, error) {
	_ = ctx
	_ = taskID
	return nil, fmt.Errorf("seedance provider: 骨架待完善")
}
