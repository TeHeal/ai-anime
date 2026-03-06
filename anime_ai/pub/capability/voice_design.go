package capability

import "context"

// VoiceDesignRequest 音色设计请求（文生音色：文本描述 → 新音色 + 试听音频）
// 与 TTS（预设音色+合成）不同，此为「生成新音色」能力
type VoiceDesignRequest struct {
	Prompt      string `json:"prompt"`       // 音色描述
	PreviewText string `json:"preview_text"` // 试听文本，maxLength 500
	VoiceID     string `json:"voice_id"`     // 可选，自定义 voice_id；不传则自动生成
}

// VoiceDesignResult 音色设计结果
type VoiceDesignResult struct {
	VoiceID   string `json:"voiceId"`   // 生成的音色 ID，可用于后续 TTS
	AudioData []byte `json:"-"`        // 试听音频原始字节（mp3），由调用方写入存储
	Provider  string `json:"provider"`
}

// VoiceDesignProvider 音色设计 Provider 接口（支持文生音色的厂商，如 MiniMax）
type VoiceDesignProvider interface {
	Name() string
	Design(ctx context.Context, req VoiceDesignRequest) (*VoiceDesignResult, error)
}
