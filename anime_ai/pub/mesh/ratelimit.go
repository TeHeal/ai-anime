package mesh

import (
	"sync"

	"golang.org/x/time/rate"
)

// RateLimiter 限流器
type RateLimiter struct {
	global   *rate.Limiter
	provider map[string]*rate.Limiter
	mu       sync.RWMutex
}

// NewRateLimiter 创建限流器
func NewRateLimiter(globalRPS float64, globalBurst int) *RateLimiter {
	rl := &RateLimiter{
		provider: make(map[string]*rate.Limiter),
	}
	if globalRPS > 0 && globalBurst > 0 {
		rl.global = rate.NewLimiter(rate.Limit(globalRPS), globalBurst)
	}
	return rl
}

// SetProviderLimit 设置单个 Provider 的限流
func (r *RateLimiter) SetProviderLimit(name string, rps float64, burst int) {
	if rps <= 0 || burst <= 0 {
		return
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	r.provider[name] = rate.NewLimiter(rate.Limit(rps), burst)
}

// Allow 判断是否允许请求
func (r *RateLimiter) Allow(provider string) bool {
	if r == nil {
		return true
	}
	if r.global != nil && !r.global.Allow() {
		return false
	}
	r.mu.RLock()
	defer r.mu.RUnlock()
	lim, ok := r.provider[provider]
	if !ok {
		return true
	}
	return lim.Allow()
}
