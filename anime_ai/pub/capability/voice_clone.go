package capability

import "context"

// VoiceCloneRequest 音色克隆请求（基于音频样本）
type VoiceCloneRequest struct {
	// SampleAudio 待克隆音频的字节内容（mp3/m4a/wav，10s~5min，≤20MB）
	SampleAudio []byte
	// SampleFilename 文件名，用于确定格式
	SampleFilename string
	// VoiceID 自定义音色 ID，8~256 字符，首字符须为字母
	VoiceID string
	// PreviewText 试听文本，≤1000 字符，模型用克隆音色朗读并返回试听音频
	PreviewText string
	// Model 试听合成模型，提供 PreviewText 时必填
	Model string
}

// VoiceCloneResult 音色克隆结果
type VoiceCloneResult struct {
	VoiceID  string `json:"voiceId"`
	DemoURL  string `json:"demoUrl"`  // 试听音频 URL
	Provider string `json:"provider"`
}

// VoiceCloneProvider 音色克隆 Provider 接口
type VoiceCloneProvider interface {
	Name() string
	Clone(ctx context.Context, req VoiceCloneRequest) (*VoiceCloneResult, error)
}
