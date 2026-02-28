package mesh

import "sync"

// ProviderHealth Provider 健康统计
type ProviderHealth struct {
	Success int64
	Failure int64
	Score   float64
}

// HealthBook 健康记录本
type HealthBook struct {
	mu    sync.RWMutex
	stats map[string]ProviderHealth
}

// NewHealthBook 创建健康记录本
func NewHealthBook() *HealthBook {
	return &HealthBook{
		stats: make(map[string]ProviderHealth),
	}
}

// OnSuccess 记录成功
func (h *HealthBook) OnSuccess(provider string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	st := h.stats[provider]
	st.Success++
	st.Score = computeScore(st.Success, st.Failure)
	h.stats[provider] = st
}

// OnFailure 记录失败
func (h *HealthBook) OnFailure(provider string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	st := h.stats[provider]
	st.Failure++
	st.Score = computeScore(st.Success, st.Failure)
	h.stats[provider] = st
}

// Score 获取 Provider 健康分
func (h *HealthBook) Score(provider string) float64 {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return h.stats[provider].Score
}

func computeScore(success, failure int64) float64 {
	total := success + failure
	if total == 0 {
		return 100
	}
	return (float64(success) / float64(total)) * 100
}
