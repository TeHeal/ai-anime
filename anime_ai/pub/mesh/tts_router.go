package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// TTSRouter TTS 路由
type TTSRouter struct {
	*TaskRouter[capability.TTSProvider]
}

// NewTTSRouter 创建 TTS 路由
func NewTTSRouter(policy Policy, breaker *Breaker) *TTSRouter {
	return &TTSRouter{
		NewTaskRouter[capability.TTSProvider](policy, breaker, "tts", func(p Policy) []string { return p.TTS }),
	}
}

// Submit 提交 TTS 任务
func (r *TTSRouter) Submit(ctx context.Context, req capability.TTSRequest, preferred string) (string, string, error) {
	name, p, err := r.SelectProvider(preferred)
	if err != nil {
		return "", "", capability.Wrap(capability.ErrNotAvail, "tts provider unavailable", err)
	}
	if err := r.PreSubmit(name); err != nil {
		return "", "", err
	}
	taskID, err := p.SubmitTTSTask(ctx, req)
	if err != nil {
		r.RecordFailure(name)
		return "", "", err
	}
	r.RecordSuccess(name, taskID)
	return name, taskID, nil
}

// Query 查询 TTS 任务结果
func (r *TTSRouter) Query(ctx context.Context, taskID string) (*capability.TTSResult, error) {
	name, p, err := r.LookupTaskProvider(taskID)
	if err != nil {
		return nil, err
	}
	res, err := p.QueryTTSTask(ctx, taskID)
	if err != nil {
		r.RecordQueryResult(name, true)
		return nil, err
	}
	r.RecordQueryResult(name, res != nil && res.Status == "failed")
	return res, nil
}
