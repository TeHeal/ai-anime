package shot

import "time"

// 审核状态常量（README 领域模型）
const (
	ReviewStatusPending  = "pending_review"
	ReviewStatusApproved  = "approved"
	ReviewStatusRejected  = "rejected"
	ReviewStatusRevision = "revision"
)

// 生成状态
const (
	StatusPending    = "pending"
	StatusGenerating = "generating"
	StatusCompleted  = "completed"
	StatusFailed     = "failed"
)

// Shot 镜头实体，属于 Project
// ID 使用 string（UUID），与 sch/db pgtype.UUID 互转
type Shot struct {
	ID        string    `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	ProjectID   string  `json:"project_id"`
	SegmentID   *string `json:"segment_id"`
	SceneID     *string `json:"scene_id"`
	SortIndex   int     `json:"sort_index"`
	Prompt      string  `json:"prompt"`
	StylePrompt string  `json:"style_prompt"`
	ImageURL    string  `json:"image_url"`
	VideoURL    string  `json:"video_url"`
	TaskID      string  `json:"task_id"`
	Status      string  `json:"status"` // pending, generating, completed, failed
	Duration    int     `json:"duration"`

	// 分镜扩展字段
	CameraType     string  `json:"camera_type"`
	CameraAngle    string  `json:"camera_angle"`
	Dialogue       string  `json:"dialogue"`
	CharacterName  string  `json:"character_name"`
	CharacterID    *string `json:"character_id"`
	Emotion        string  `json:"emotion"`
	Voice          string  `json:"voice"`
	VoiceName      string  `json:"voice_name"`
	LipSync        string  `json:"lip_sync"`
	Transition     string  `json:"transition"`
	AudioDesign    string  `json:"audio_design"`
	Priority       string  `json:"priority"`
	NegativePrompt string  `json:"negative_prompt"`

	// 审核
	ReviewStatus  string     `json:"review_status"`
	ReviewComment string     `json:"review_comment"`
	ReviewedAt    *time.Time `json:"reviewed_at"`
	ReviewedBy    *string   `json:"reviewed_by"`
}
