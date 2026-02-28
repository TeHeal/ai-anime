package mesh

import (
	"context"
	"fmt"
	"sync"
)

// Logger 日志接口
type Logger interface {
	Info(msg string, fields map[string]any)
	Error(msg string, fields map[string]any)
}

type noopLogger struct{}

func (n noopLogger) Info(string, map[string]any)  {}
func (n noopLogger) Error(string, map[string]any) {}

type contextKey string

const (
	routePathKey contextKey = "mesh.route_path"
)

// WithRoutePath 将路由路径写入 Context
func WithRoutePath(ctx context.Context, routePath string) context.Context {
	return context.WithValue(ctx, routePathKey, routePath)
}

// RoutePathFrom 从 Context 读取路由路径
func RoutePathFrom(ctx context.Context) string {
	v := ctx.Value(routePathKey)
	if s, ok := v.(string); ok {
		return s
	}
	return ""
}

// Metrics 指标收集
type Metrics struct {
	mu       sync.RWMutex
	counters map[string]int64
}

// NewMetrics 创建指标收集器
func NewMetrics() *Metrics {
	return &Metrics{
		counters: make(map[string]int64),
	}
}

// Inc 增加计数
func (m *Metrics) Inc(name string) {
	if m == nil {
		return
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	m.counters[name]++
}

// IncRequest 记录请求指标
func (m *Metrics) IncRequest(capability, provider, status string) {
	m.Inc(fmt.Sprintf("ai_request_total.%s.%s.%s", capability, provider, status))
}

// IncFallback 记录降级指标
func (m *Metrics) IncFallback(fromProvider, toProvider string) {
	m.Inc(fmt.Sprintf("ai_fallback_total.%s.%s", fromProvider, toProvider))
}

// Snapshot 获取指标快照
func (m *Metrics) Snapshot() map[string]any {
	if m == nil {
		return map[string]any{}
	}
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make(map[string]any, len(m.counters))
	for k, v := range m.counters {
		out[k] = v
	}
	return out
}
