package capability

import "context"

// VideoGenMode 视频生成模式
type VideoGenMode string

const (
	VideoModeText2Video      VideoGenMode = "text2video"       // 文生视频
	VideoModeFirstFrame      VideoGenMode = "first_frame"      // 首帧图生视频
	VideoModeFirstLastFrame  VideoGenMode = "first_last_frame" // 首尾帧图生视频
	VideoModeReferenceImages VideoGenMode = "reference_images" // 参考图生视频（1~4张）
	VideoModeDraftToFinal    VideoGenMode = "draft_to_final"   // 基于 Draft 样片生成正式视频
)

// VideoContentItem 视频生成内容项（对齐 Seedance API content 数组）
type VideoContentItem struct {
	Type     string `json:"type"`                // text | image_url | draft_task
	Text     string `json:"text,omitempty"`      // 提示词
	ImageURL string `json:"image_url,omitempty"` // 图片 URL
	Role     string `json:"role,omitempty"`      // first_frame | last_frame | reference_image
	DraftID  string `json:"draft_id,omitempty"`  // Draft 任务 ID（draft_to_final 模式）
}

// VideoRequest 文生视频请求（完整对齐 Seedance API）
type VideoRequest struct {
	// 基础字段
	Prompt   string `json:"prompt"`
	ImageURL string `json:"image_url"` // 兼容旧接口，首帧图 URL
	Model    string `json:"model"`
	Duration int    `json:"duration,omitempty"` // 时长（秒），4~12

	// 生成模式
	Mode VideoGenMode `json:"mode,omitempty"` // 生成模式

	// Seedance 扩展内容项（支持多图、首尾帧等高级模式）
	ContentItems []VideoContentItem `json:"content_items,omitempty"`

	// 视频输出规格
	Resolution  string `json:"resolution,omitempty"`   // 480p | 720p | 1080p
	Ratio       string `json:"ratio,omitempty"`        // 16:9 | 4:3 | 1:1 | 3:4 | 9:16 | 21:9 | adaptive
	Frames      int    `json:"frames,omitempty"`       // 帧数，与 Duration 二选一
	Seed        *int64 `json:"seed,omitempty"`         // 随机种子，可复现
	CameraFixed *bool  `json:"camera_fixed,omitempty"` // 是否固定摄像头
	Watermark   *bool  `json:"watermark,omitempty"`    // 是否包含水印

	// 音频
	GenerateAudio *bool `json:"generate_audio,omitempty"` // 是否生成有声视频（Seedance 1.5 pro）

	// 样片/离线
	Draft                *bool  `json:"draft,omitempty"`                  // 样片模式（低成本预览）
	ReturnLastFrame      *bool  `json:"return_last_frame,omitempty"`      // 是否返回尾帧（连续生成用）
	ServiceTier          string `json:"service_tier,omitempty"`           // default | flex（离线推理）
	ExecutionExpiresAfter int64  `json:"execution_expires_after,omitempty"` // 离线推理超时（秒）

	// Webhook 回调
	CallbackURL string `json:"callback_url,omitempty"` // 状态变更回调地址

	// 参考图 URL 列表（reference_images 模式，1~4 张）
	ReferenceImageURLs []string `json:"reference_image_urls,omitempty"`
	// 尾帧图 URL（first_last_frame 模式）
	LastFrameImageURL string `json:"last_frame_image_url,omitempty"`

	// Draft 任务 ID（draft_to_final 模式）
	DraftTaskID string `json:"draft_task_id,omitempty"`

	// 反向提示词
	NegativePrompt string `json:"negative_prompt,omitempty"`
}

// VideoResult 文生视频结果
type VideoResult struct {
	Status        string `json:"status"`
	VideoURL      string `json:"video_url,omitempty"`
	LastFrameURL  string `json:"last_frame_url,omitempty"` // 尾帧 URL（连续生成）
	Error         string `json:"error,omitempty"`
	ErrorCode     string `json:"error_code,omitempty"`
	Resolution    string `json:"resolution,omitempty"`
	Ratio         string `json:"ratio,omitempty"`
	Duration      int    `json:"duration,omitempty"`
	FPS           int    `json:"fps,omitempty"`
	Seed          int64  `json:"seed,omitempty"`
	TokensUsed    int64  `json:"tokens_used,omitempty"`
	ServiceTier   string `json:"service_tier,omitempty"`
	IsDraft       bool   `json:"is_draft,omitempty"`
	ProviderTaskID string `json:"provider_task_id,omitempty"` // 上游任务 ID
}

// VideoProvider 文生视频 Provider 统一接口
type VideoProvider interface {
	Name() string
	SubmitVideoTask(ctx context.Context, req VideoRequest) (taskID string, err error)
	QueryVideoTask(ctx context.Context, taskID string) (*VideoResult, error)
}

// VideoCapability 面向应用的统一文生视频路由能力
type VideoCapability interface {
	Submit(ctx context.Context, req VideoRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*VideoResult, error)
}
