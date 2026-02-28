package capability

import "context"

// MusicRequest 音乐生成请求
type MusicRequest struct {
	Prompt string `json:"prompt"`
	Model  string `json:"model"`
}

// MusicResult 音乐生成结果
type MusicResult struct {
	Status   string `json:"status"`
	AudioURL string `json:"audio_url,omitempty"`
	Error    string `json:"error,omitempty"`
}

// MusicProvider 音乐生成 Provider 统一接口
type MusicProvider interface {
	Name() string
	SubmitMusicTask(ctx context.Context, req MusicRequest) (taskID string, err error)
	QueryMusicTask(ctx context.Context, taskID string) (*MusicResult, error)
}

// MusicCapability 面向应用的统一音乐生成路由能力
type MusicCapability interface {
	Submit(ctx context.Context, req MusicRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*MusicResult, error)
}
