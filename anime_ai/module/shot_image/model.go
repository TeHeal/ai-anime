package shot_image

import "time"

// ShotImage 镜图实体，属于 Shot，表示一个镜头的关键帧图像（或候选）
// ID 使用 string（UUID），与 sch/db pgtype.UUID 互转
type ShotImage struct {
	ID        string    `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	ShotID    string `json:"shot_id"`
	ProjectID string `json:"project_id"`
	ImageURL  string `json:"image_url"`
	TaskID    string `json:"task_id"`
	Status    string `json:"status"` // pending, generating, completed, failed
	SortIndex int    `json:"sort_index"`

	// 审核
	ReviewStatus  string     `json:"review_status"`
	ReviewComment string     `json:"review_comment"`
	ReviewedAt    *time.Time `json:"reviewed_at"`
	ReviewedBy    *string   `json:"reviewed_by"`
}

// GenerateConfig 镜图生成配置
type GenerateConfig struct {
	GlobalPrompt    string `json:"global_prompt"`
	NegativePrompt  string `json:"negative_prompt"`
	Provider        string `json:"provider"`
	Model           string `json:"model"`
	OutputCount     int    `json:"output_count"`
	AspectRatio     string `json:"aspect_ratio"`
	CardMode        bool   `json:"card_mode"`
	Width           int    `json:"width"`
	Height          int    `json:"height"`
	IncludeAdjacent bool   `json:"include_adjacent"`
}
