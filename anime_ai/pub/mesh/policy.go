package mesh

import "time"

// RetryPolicy 重试策略
type RetryPolicy struct {
	MaxAttempts int
	Backoff     []time.Duration
}

// ChatRoutePolicy 对话路由策略
type ChatRoutePolicy struct {
	PrimaryChain []string
	Timeout      time.Duration
	Retry        RetryPolicy
}

// Policy 各能力路由策略
type Policy struct {
	Chat  ChatRoutePolicy
	Image []string
	Video []string
	TTS   []string
	Music []string
}

// DefaultPolicy 默认路由策略
func DefaultPolicy() Policy {
	return Policy{
		Chat: ChatRoutePolicy{
			PrimaryChain: []string{"deepseek", "kimi", "aliyun", "doubao"},
			Timeout:      30 * time.Second,
			Retry: RetryPolicy{
				MaxAttempts: 2,
				Backoff:     []time.Duration{200 * time.Millisecond, 800 * time.Millisecond},
			},
		},
		Image: []string{"seedream", "wanx", "kie"},
		Video: []string{"seedance", "kie_video"},
		TTS:   []string{"minimax_tts", "cosyvoice", "volcengine_tts", "fish_audio"},
		Music: []string{"suno"},
	}
}
