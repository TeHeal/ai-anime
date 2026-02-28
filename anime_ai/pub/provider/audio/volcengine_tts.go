package audio

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// VolcengineTTSProvider 火山引擎 TTS（骨架，后续完善）
type VolcengineTTSProvider struct {
	apiKey  string
	appID   string
}

// NewVolcengineTTSProvider 创建火山引擎 TTS Provider
func NewVolcengineTTSProvider(apiKey, appID string) *VolcengineTTSProvider {
	return &VolcengineTTSProvider{apiKey: apiKey, appID: appID}
}

func (p *VolcengineTTSProvider) Name() string { return "volcengine_tts" }

func (p *VolcengineTTSProvider) SubmitTTSTask(ctx context.Context, req capability.TTSRequest) (string, error) {
	_ = ctx
	_ = req
	return "", fmt.Errorf("volcengine_tts provider: 骨架待完善")
}

func (p *VolcengineTTSProvider) QueryTTSTask(ctx context.Context, taskID string) (*capability.TTSResult, error) {
	_ = ctx
	_ = taskID
	return nil, fmt.Errorf("volcengine_tts provider: 骨架待完善")
}
