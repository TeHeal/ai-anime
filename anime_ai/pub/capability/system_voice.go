package capability

import "context"

// SystemVoiceItem 系统音色项（用于合并到资源列表展示）
type SystemVoiceItem struct {
	VoiceID     string   `json:"voiceId"`
	VoiceName   string   `json:"voiceName"`
	Description string   `json:"description"`
	Provider    string   `json:"provider"`
}

// SystemVoiceLister 系统音色列表能力（如 MiniMax get_voice）
type SystemVoiceLister interface {
	ListSystemVoices(ctx context.Context, provider string) ([]SystemVoiceItem, error)
}
