package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// MusicRouter 音乐生成路由
type MusicRouter struct {
	*TaskRouter[capability.MusicProvider]
}

// NewMusicRouter 创建音乐生成路由
func NewMusicRouter(policy Policy, breaker *Breaker) *MusicRouter {
	return &MusicRouter{
		NewTaskRouter[capability.MusicProvider](policy, breaker, "music", func(p Policy) []string { return p.Music }),
	}
}

// Submit 提交音乐生成任务
func (r *MusicRouter) Submit(ctx context.Context, req capability.MusicRequest, preferred string) (string, string, error) {
	name, p, err := r.SelectProvider(preferred)
	if err != nil {
		return "", "", capability.Wrap(capability.ErrNotAvail, "music provider unavailable", err)
	}
	if err := r.PreSubmit(name); err != nil {
		return "", "", err
	}
	taskID, err := p.SubmitMusicTask(ctx, req)
	if err != nil {
		r.RecordFailure(name)
		return "", "", err
	}
	r.RecordSuccess(name, taskID)
	return name, taskID, nil
}

// Query 查询音乐生成任务结果
func (r *MusicRouter) Query(ctx context.Context, taskID string) (*capability.MusicResult, error) {
	name, p, err := r.LookupTaskProvider(taskID)
	if err != nil {
		return nil, err
	}
	res, err := p.QueryMusicTask(ctx, taskID)
	if err != nil {
		r.RecordQueryResult(name, true)
		return nil, err
	}
	r.RecordQueryResult(name, res != nil && res.Status == "failed")
	return res, nil
}
