package capability

import "context"

// TTSRequest TTS 请求
type TTSRequest struct {
	Text    string `json:"text"`
	VoiceID string `json:"voice_id"`
	Model   string `json:"model"`
	Emotion string `json:"emotion,omitempty"`
}

// TTSResult TTS 结果
type TTSResult struct {
	Status   string `json:"status"`
	AudioURL string `json:"audio_url,omitempty"`
	Error    string `json:"error,omitempty"`
}

// TTSProvider TTS Provider 统一接口
type TTSProvider interface {
	Name() string
	SubmitTTSTask(ctx context.Context, req TTSRequest) (taskID string, err error)
	QueryTTSTask(ctx context.Context, taskID string) (*TTSResult, error)
}

// TTSCapability 面向应用的统一 TTS 路由能力
type TTSCapability interface {
	Submit(ctx context.Context, req TTSRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*TTSResult, error)
}
