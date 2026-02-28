package image

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// WanxProvider 阿里云通义万相文生图（骨架，后续完善）
type WanxProvider struct {
	apiKey string
}

// NewWanxProvider 创建 Wanx Provider
func NewWanxProvider(apiKey string) *WanxProvider {
	return &WanxProvider{apiKey: apiKey}
}

func (p *WanxProvider) Name() string { return "wanx" }

func (p *WanxProvider) SubmitImageTask(ctx context.Context, req capability.ImageRequest) (string, error) {
	_ = ctx
	_ = req
	return "", fmt.Errorf("wanx provider: 骨架待完善")
}

func (p *WanxProvider) QueryImageTask(ctx context.Context, taskID string) (*capability.ImageResult, error) {
	_ = ctx
	_ = taskID
	return nil, fmt.Errorf("wanx provider: 骨架待完善")
}
