package shot_video

import "context"

// Store 镜头视频数据访问接口
type Store interface {
	Create(ctx context.Context, v *ShotVideo) error
	FindByID(ctx context.Context, id string) (*ShotVideo, error)
	ListByShot(ctx context.Context, shotID string) ([]ShotVideo, error)
	ListByProject(ctx context.Context, projectID string) ([]ShotVideo, error)
	Update(ctx context.Context, v *ShotVideo) error
	UpdateStatus(ctx context.Context, id, status, videoURL, taskID string) error
	UpdateReview(ctx context.Context, id, status, comment string, reviewedBy *string) error
	Delete(ctx context.Context, id string) error
}
