// Package mesh AI 能力路由、熔断、重试、限流
package mesh

import (
	"sync"
	"time"
)

const halfOpenAfter = 30 * time.Second

type breakerState struct {
	failures  int
	open      bool
	openSince time.Time
}

// Breaker Provider 级熔断器，支持半开恢复
// 达到阈值后熔断打开；halfOpenAfter 后进入半开状态，允许一次探测请求
type Breaker struct {
	mu        sync.Mutex
	threshold int
	states    map[string]breakerState
}

// NewBreaker 创建熔断器
func NewBreaker(threshold int) *Breaker {
	if threshold <= 0 {
		threshold = 3
	}
	return &Breaker{
		threshold: threshold,
		states:   make(map[string]breakerState),
	}
}

// Allow 判断是否允许请求
func (b *Breaker) Allow(provider string) bool {
	b.mu.Lock()
	defer b.mu.Unlock()
	st := b.states[provider]
	if !st.open {
		return true
	}
	if time.Since(st.openSince) >= halfOpenAfter {
		return true
	}
	return false
}

// OnSuccess 记录成功
func (b *Breaker) OnSuccess(provider string) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.states[provider] = breakerState{}
}

// OnFailure 记录失败
func (b *Breaker) OnFailure(provider string) {
	b.mu.Lock()
	defer b.mu.Unlock()
	st := b.states[provider]
	st.failures++
	if st.failures >= b.threshold {
		st.open = true
		st.openSince = time.Now()
	}
	b.states[provider] = st
}
