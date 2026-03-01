package crossmodule

import "time"

// ShotImage 镜图实体（供 pub/worker 等编排层使用，与 shot_image 模块对齐）
type ShotImage struct {
	ID            string     `json:"id"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
	ShotID        string     `json:"shot_id"`
	ProjectID     string     `json:"project_id"`
	ImageURL      string     `json:"image_url"`
	TaskID        string     `json:"task_id"`
	Status        string     `json:"status"`
	SortIndex     int        `json:"sort_index"`
	ReviewStatus  string     `json:"review_status"`
	ReviewComment string     `json:"review_comment"`
	ReviewedAt    *time.Time `json:"reviewed_at"`
	ReviewedBy    *string    `json:"reviewed_by"`
}

// ShotImageStore 镜图数据访问接口，供 pub/worker 调用
// 由 shot_image 模块实现并注入
type ShotImageStore interface {
	Create(s *ShotImage) error
	BulkCreate(images []ShotImage) error
	FindByID(id string) (*ShotImage, error)
	ListByShot(shotID string) ([]ShotImage, error)
	ListByProject(projectID string) ([]ShotImage, error)
	Update(s *ShotImage) error
	Delete(id string) error
	DeleteByShot(shotID string) error
}
