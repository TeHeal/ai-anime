package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// VideoRouter 文生视频路由
type VideoRouter struct {
	*TaskRouter[capability.VideoProvider]
}

// NewVideoRouter 创建文生视频路由
func NewVideoRouter(policy Policy, breaker *Breaker) *VideoRouter {
	return &VideoRouter{
		NewTaskRouter[capability.VideoProvider](policy, breaker, "video", func(p Policy) []string { return p.Video }),
	}
}

// Submit 提交文生视频任务
func (r *VideoRouter) Submit(ctx context.Context, req capability.VideoRequest, preferred string) (string, string, error) {
	name, p, err := r.SelectProvider(preferred)
	if err != nil {
		return "", "", capability.Wrap(capability.ErrNotAvail, "video provider unavailable", err)
	}
	if err := r.PreSubmit(name); err != nil {
		return "", "", err
	}
	taskID, err := p.SubmitVideoTask(ctx, req)
	if err != nil {
		r.RecordFailure(name)
		return "", "", err
	}
	r.RecordSuccess(name, taskID)
	return name, taskID, nil
}

// Query 查询文生视频任务结果
func (r *VideoRouter) Query(ctx context.Context, taskID string) (*capability.VideoResult, error) {
	name, p, err := r.LookupTaskProvider(taskID)
	if err != nil {
		return nil, err
	}
	res, err := p.QueryVideoTask(ctx, taskID)
	if err != nil {
		r.RecordQueryResult(name, true)
		return nil, err
	}
	r.RecordQueryResult(name, res != nil && res.Status == "failed")
	return res, nil
}
