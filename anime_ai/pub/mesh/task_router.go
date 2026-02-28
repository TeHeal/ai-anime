package mesh

import (
	"fmt"
	"sync"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// Named Provider 名称约束
type Named interface {
	Name() string
}

// TaskRouter 通用任务路由，处理 Provider 选择、熔断、限流、健康追踪、指标、任务索引
// 具体类型路由（ImageRouter、VideoRouter 等）是 TaskRouter 的类型别名
type TaskRouter[P Named] struct {
	policy    Policy
	breaker   *Breaker
	limiter   *RateLimiter
	health    *HealthBook
	metrics   *Metrics
	category  string
	chain     func(Policy) []string
	providers map[string]P
	taskIndex map[string]string
	mu        sync.RWMutex
	forced    string
	failSet   map[string]bool
}

// NewTaskRouter 创建通用任务路由
func NewTaskRouter[P Named](policy Policy, breaker *Breaker, category string, chainFn func(Policy) []string) *TaskRouter[P] {
	if breaker == nil {
		breaker = NewBreaker(3)
	}
	return &TaskRouter[P]{
		policy:    policy,
		breaker:   breaker,
		limiter:   NewRateLimiter(0, 0),
		health:    NewHealthBook(),
		metrics:   NewMetrics(),
		category:  category,
		chain:     chainFn,
		providers: make(map[string]P),
		taskIndex: make(map[string]string),
		failSet:   make(map[string]bool),
	}
}

// RegisterProvider 注册 Provider
func (r *TaskRouter[P]) RegisterProvider(p P) {
	r.providers[p.Name()] = p
}

// SetMetrics 设置指标收集器
func (r *TaskRouter[P]) SetMetrics(m *Metrics) {
	if m != nil {
		r.metrics = m
	}
}

// SetForcedProvider 设置强制使用的 Provider
func (r *TaskRouter[P]) SetForcedProvider(name string) {
	r.forced = name
}

// SetFailProviders 设置故障注入的 Provider 列表
func (r *TaskRouter[P]) SetFailProviders(names []string) {
	r.failSet = make(map[string]bool, len(names))
	for _, n := range names {
		r.failSet[n] = true
	}
}

// SelectProvider 按偏好、强制覆盖或策略链顺序选择 Provider
func (r *TaskRouter[P]) SelectProvider(preferred string) (string, P, error) {
	var zero P
	if preferred != "" {
		p, ok := r.providers[preferred]
		if !ok {
			return "", zero, fmt.Errorf("%s provider not found: %s", r.category, preferred)
		}
		return preferred, p, nil
	}
	if r.forced != "" {
		p, ok := r.providers[r.forced]
		if !ok {
			return "", zero, fmt.Errorf("forced %s provider not found: %s", r.category, r.forced)
		}
		return r.forced, p, nil
	}
	for _, name := range r.chain(r.policy) {
		if !r.breaker.Allow(name) || !r.limiter.Allow(name) {
			continue
		}
		if p, ok := r.providers[name]; ok {
			return name, p, nil
		}
	}
	return "", zero, fmt.Errorf("no %s provider available", r.category)
}

// GetProvider 按名称获取 Provider
func (r *TaskRouter[P]) GetProvider(name string) (P, error) {
	r.mu.RLock()
	p, ok := r.providers[name]
	r.mu.RUnlock()
	if !ok {
		var zero P
		return zero, fmt.Errorf("%s provider not found: %s", r.category, name)
	}
	return p, nil
}

// PreSubmit 提交前检查（故障注入、记录尝试指标）
func (r *TaskRouter[P]) PreSubmit(name string) error {
	if r.failSet[name] {
		r.breaker.OnFailure(name)
		r.health.OnFailure(name)
		r.metrics.IncRequest(r.category, name, "fault_injected")
		return capability.Wrap(capability.ErrUpstream, "fault injection: "+r.category+" provider forced failure", nil)
	}
	r.metrics.IncRequest(r.category, name, "attempt")
	return nil
}

// RecordSuccess 记录提交或查询成功
func (r *TaskRouter[P]) RecordSuccess(name, taskID string) {
	r.breaker.OnSuccess(name)
	r.health.OnSuccess(name)
	r.metrics.IncRequest(r.category, name, "success")
	if taskID != "" {
		r.mu.Lock()
		r.taskIndex[taskID] = name
		r.mu.Unlock()
	}
}

// RecordFailure 记录提交失败
func (r *TaskRouter[P]) RecordFailure(name string) {
	r.breaker.OnFailure(name)
	r.health.OnFailure(name)
}

// LookupTaskProvider 根据任务 ID 查找 Provider
func (r *TaskRouter[P]) LookupTaskProvider(taskID string) (string, P, error) {
	r.mu.RLock()
	name, ok := r.taskIndex[taskID]
	r.mu.RUnlock()
	if !ok {
		var zero P
		return "", zero, capability.Wrap(capability.ErrNotAvail, "unknown "+r.category+" task provider", nil)
	}
	p, ok := r.providers[name]
	if !ok {
		var zero P
		return "", zero, capability.Wrap(capability.ErrNotAvail, r.category+" provider missing", nil)
	}
	return name, p, nil
}

// RecordQueryResult 记录查询轮询结果
func (r *TaskRouter[P]) RecordQueryResult(name string, failed bool) {
	if failed {
		r.breaker.OnFailure(name)
		r.health.OnFailure(name)
		r.metrics.IncRequest(r.category, name, "query_failed")
	} else {
		r.breaker.OnSuccess(name)
		r.health.OnSuccess(name)
	}
}
