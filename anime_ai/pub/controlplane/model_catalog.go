package controlplane

// ServiceType 服务类型
type ServiceType string

const (
	ServiceLLM   ServiceType = "llm"
	ServiceImage ServiceType = "image"
	ServiceVideo ServiceType = "video"
	ServiceTTS   ServiceType = "tts"
	ServiceMusic ServiceType = "music"
)

// ModelEntry 模型目录条目
type ModelEntry struct {
	Provider string      `json:"provider"`
	Group    string      `json:"group"`
	Service  ServiceType `json:"service"`
	Model    string      `json:"model"`
	Enabled  bool        `json:"enabled"`
	Priority int         `json:"priority"`
	Features []string    `json:"features,omitempty"`
}
