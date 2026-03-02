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

	// 视频生成扩展字段（Seedance 完整能力）
	GenMode        string `json:"genMode,omitempty"`        // 生成模式: text2video, first_frame, first_last_frame, reference_images, draft_to_final
	Resolution     string `json:"resolution,omitempty"`     // 480p | 720p | 1080p
	Ratio          string `json:"ratio,omitempty"`          // 16:9, 4:3, 1:1, 3:4, 9:16, 21:9, adaptive
	Seed           int64  `json:"seed,omitempty"`           // 生成种子
	LastFrameURL   string `json:"lastFrameUrl,omitempty"`   // 尾帧 URL（连续生成用）
	IsDraft        bool   `json:"isDraft,omitempty"`        // 是否为样片
	DraftTaskID    string `json:"draftTaskId,omitempty"`    // 对应的 Draft 任务 ID
	ServiceTier    string `json:"serviceTier,omitempty"`    // default | flex（离线推理）
	TokensUsed     int64  `json:"tokensUsed,omitempty"`     // 消耗 token 数
	FPS            int    `json:"fps,omitempty"`            // 帧率
	GenerateAudio  bool   `json:"generateAudio,omitempty"`  // 是否带音频
}

// VideoCreateRequest 创建镜头视频的请求体
type VideoCreateRequest struct {
	// 生成模式
	GenMode string `json:"genMode,omitempty"` // text2video | first_frame | first_last_frame | reference_images | draft_to_final

	// 提示词
	Prompt         string `json:"prompt,omitempty"`
	NegativePrompt string `json:"negativePrompt,omitempty"`

	// 图片输入
	ImageURL           string   `json:"imageUrl,omitempty"`           // 首帧图 URL
	LastFrameImageURL  string   `json:"lastFrameImageUrl,omitempty"`  // 尾帧图 URL
	ReferenceImageURLs []string `json:"referenceImageUrls,omitempty"` // 参考图 URL 列表

	// 视频规格
	Resolution  string `json:"resolution,omitempty"`  // 480p | 720p | 1080p
	Ratio       string `json:"ratio,omitempty"`       // 16:9, 4:3, 1:1 等
	Duration    int    `json:"duration,omitempty"`     // 时长（秒）
	Frames      int    `json:"frames,omitempty"`       // 帧数
	Seed        *int64 `json:"seed,omitempty"`         // 随机种子
	CameraFixed *bool  `json:"cameraFixed,omitempty"`  // 固定摄像头
	Watermark   *bool  `json:"watermark,omitempty"`    // 水印

	// 音频
	GenerateAudio *bool `json:"generateAudio,omitempty"` // 生成有声视频

	// 高级选项
	Draft                 *bool  `json:"draft,omitempty"`                 // 样片模式
	ReturnLastFrame       *bool  `json:"returnLastFrame,omitempty"`       // 返回尾帧
	ServiceTier           string `json:"serviceTier,omitempty"`           // default | flex
	ExecutionExpiresAfter int64  `json:"executionExpiresAfter,omitempty"` // 离线超时
	CallbackURL           string `json:"callbackUrl,omitempty"`           // Webhook

	// Draft 转正式
	DraftTaskID string `json:"draftTaskId,omitempty"` // Draft 任务 ID

	// 模型指定
	Provider string `json:"provider,omitempty"`
	Model    string `json:"model,omitempty"`
}
