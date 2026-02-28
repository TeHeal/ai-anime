package capability

import "context"

// TraceMeta 请求追踪元数据
type TraceMeta struct {
	RequestID string
	TaskID    string
}

// ChatMessage 对话消息
type ChatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// ChatRequest 流式对话请求
type ChatRequest struct {
	ProviderHint string
	Model        string
	Messages     []ChatMessage
	Temperature  *float64
	MaxTokens    *int
	Trace        TraceMeta
}

// ChatChunk 流式输出块
type ChatChunk struct {
	Content string
	Done    bool
	Error   error
	Meta    map[string]string
}

// ChatProvider 面向 Provider 的对话能力契约
type ChatProvider interface {
	Name() string
	ChatStream(ctx context.Context, req ChatRequest) (<-chan ChatChunk, error)
}

// ChatCapability 面向应用的统一对话能力契约
type ChatCapability interface {
	ChatStream(ctx context.Context, req ChatRequest) (<-chan ChatChunk, error)
}
