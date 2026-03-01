package shot_video

import "time"

// ShotVideo 镜头视频实体，每个镜头的视频片段（README 镜头阶段）
type ShotVideo struct {
	ID            string     `json:"id"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
	ShotID        string     `json:"shot_id"`
	ProjectID     string     `json:"project_id"`
	ShotImageID   *string    `json:"shot_image_id,omitempty"`
	VideoURL      string     `json:"video_url"`
	TaskID        string     `json:"task_id"`
	Status        string     `json:"status"` // pending, generating, completed, failed
	Duration      int        `json:"duration"`
	Provider      string     `json:"provider"`
	Model         string     `json:"model"`
	Version       int        `json:"version"`
	ReviewStatus  string     `json:"review_status"`
	ReviewComment string     `json:"review_comment"`
	ReviewedAt    *time.Time `json:"reviewed_at,omitempty"`
	ReviewedBy    *string    `json:"reviewed_by,omitempty"`
}
