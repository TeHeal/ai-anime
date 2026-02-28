package mesh

import (
	"context"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// Router 对话流式路由
type Router struct {
	policy    Policy
	breaker   *Breaker
	limiter   *RateLimiter
	health    *HealthBook
	metrics   *Metrics
	logger    Logger
	providers map[string]capability.ChatProvider
	forced    string
	failSet   map[string]bool
}

// NewRouter 创建对话路由
func NewRouter(policy Policy, breaker *Breaker, logger Logger) *Router {
	if logger == nil {
		logger = noopLogger{}
	}
	if breaker == nil {
		breaker = NewBreaker(3)
	}
	return &Router{
		policy:    policy,
		breaker:   breaker,
		limiter:   NewRateLimiter(0, 0),
		health:    NewHealthBook(),
		metrics:   NewMetrics(),
		logger:    logger,
		providers: make(map[string]capability.ChatProvider),
		failSet:   make(map[string]bool),
	}
}

// RegisterChatProvider 注册对话 Provider
func (r *Router) RegisterChatProvider(p capability.ChatProvider) {
	if p == nil {
		return
	}
	r.providers[p.Name()] = p
}

// SetMetrics 设置指标收集器
func (r *Router) SetMetrics(m *Metrics) {
	if m != nil {
		r.metrics = m
	}
}

// SetForcedProvider 设置强制使用的 Provider
func (r *Router) SetForcedProvider(name string) {
	r.forced = name
}

// SetFailProviders 设置故障注入的 Provider 列表
func (r *Router) SetFailProviders(names []string) {
	r.failSet = make(map[string]bool, len(names))
	for _, n := range names {
		r.failSet[n] = true
	}
}

// ChatStream 流式对话，按策略链尝试各 Provider
func (r *Router) ChatStream(ctx context.Context, req capability.ChatRequest) (<-chan capability.ChatChunk, error) {
	chain := r.policy.Chat.PrimaryChain
	if req.ProviderHint != "" {
		chain = []string{req.ProviderHint}
	} else if r.forced != "" {
		chain = []string{r.forced}
	}

	var (
		lastErr   error
		routePath []string
	)

	for _, name := range chain {
		if !r.breaker.Allow(name) {
			continue
		}
		if !r.limiter.Allow(name) {
			lastErr = capability.Wrap(capability.ErrRateLimited, "mesh rate limit exceeded", nil)
			continue
		}
		p, ok := r.providers[name]
		if !ok {
			continue
		}
		if r.failSet[name] {
			lastErr = capability.Wrap(capability.ErrUpstream, "fault injection: chat provider forced failure", nil)
			r.breaker.OnFailure(name)
			r.health.OnFailure(name)
			r.metrics.IncRequest("chat", name, "fault_injected")
			continue
		}
		routePath = append(routePath, name)
		r.metrics.IncRequest("chat", name, "attempt")

		attemptReq := req
		var out <-chan capability.ChatChunk
		err := withRetry(ctx, r.policy.Chat.Retry, func(runCtx context.Context) error {
			var cancel context.CancelFunc
			if r.policy.Chat.Timeout > 0 {
				runCtx, cancel = context.WithTimeout(runCtx, r.policy.Chat.Timeout)
				defer cancel()
			}
			stream, err := p.ChatStream(runCtx, attemptReq)
			if err != nil {
				return err
			}
			out = stream
			return nil
		})
		if err != nil {
			lastErr = err
			r.breaker.OnFailure(name)
			r.health.OnFailure(name)
			r.metrics.IncRequest("chat", name, "failed")
			r.logger.Error("mesh chat provider failed", map[string]any{
				"provider":   name,
				"error":      err.Error(),
				"request_id": req.Trace.RequestID,
			})
			continue
		}

		r.breaker.OnSuccess(name)
		r.health.OnSuccess(name)
		r.metrics.IncRequest("chat", name, "success")
		joinedRoute := strings.Join(routePath, "->")
		return withRoutePathStream(ctx, out, joinedRoute), nil
	}

	if lastErr == nil {
		lastErr = capability.Wrap(capability.ErrNotAvail, "no chat provider available", nil)
	}
	return nil, lastErr
}

func withRoutePathStream(ctx context.Context, in <-chan capability.ChatChunk, routePath string) <-chan capability.ChatChunk {
	out := make(chan capability.ChatChunk, 32)
	go func() {
		defer close(out)
		for {
			select {
			case <-ctx.Done():
				out <- capability.ChatChunk{
					Done:  true,
					Error: capability.Wrap(capability.ErrTimeout, "stream canceled", ctx.Err()),
					Meta:  map[string]string{"route_path": routePath},
				}
				return
			case chunk, ok := <-in:
				if !ok {
					return
				}
				if chunk.Meta == nil {
					chunk.Meta = map[string]string{}
				}
				chunk.Meta["route_path"] = routePath
				out <- chunk
				if chunk.Done {
					return
				}
			}
		}
	}()
	return out
}
