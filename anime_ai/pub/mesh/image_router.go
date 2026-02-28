package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// ImageRouter 文生图路由
type ImageRouter struct {
	*TaskRouter[capability.ImageProvider]
}

// NewImageRouter 创建文生图路由
func NewImageRouter(policy Policy, breaker *Breaker) *ImageRouter {
	return &ImageRouter{
		NewTaskRouter[capability.ImageProvider](policy, breaker, "image", func(p Policy) []string { return p.Image }),
	}
}

// Submit 提交文生图任务
func (r *ImageRouter) Submit(ctx context.Context, req capability.ImageRequest, preferred string) (string, string, error) {
	name, p, err := r.SelectProvider(preferred)
	if err != nil {
		return "", "", capability.Wrap(capability.ErrNotAvail, "image provider unavailable", err)
	}
	if err := r.PreSubmit(name); err != nil {
		return "", "", err
	}
	taskID, err := p.SubmitImageTask(ctx, req)
	if err != nil {
		r.RecordFailure(name)
		return "", "", err
	}
	r.RecordSuccess(name, taskID)
	return name, taskID, nil
}

// Query 查询文生图任务结果
func (r *ImageRouter) Query(ctx context.Context, taskID string) (*capability.ImageResult, error) {
	name, p, err := r.LookupTaskProvider(taskID)
	if err != nil {
		return nil, err
	}
	res, err := p.QueryImageTask(ctx, taskID)
	if err != nil {
		r.RecordQueryResult(name, true)
		return nil, err
	}
	r.RecordQueryResult(name, res != nil && res.Status == "failed")
	return res, nil
}
