package composite

// 成片状态（状态机：editing → exporting → done）
const (
	StatusEditing   = "editing"
	StatusExporting = "exporting"
	StatusDone      = "done"
	StatusFailed    = "failed"
)

// CompositeTask 成片任务模型
type CompositeTask struct {
	ID             string         `json:"id"`
	CreatedAt      string         `json:"created_at,omitempty"`
	ProjectID      string         `json:"project_id"`
	EpisodeID      string         `json:"episode_id,omitempty"`
	Status         string         `json:"status"`
	Timeline       []TimelineItem `json:"timeline"`
	AudioTracks    []AudioTrack   `json:"audio_tracks"`
	SubtitleTracks []SubtitleItem `json:"subtitle_tracks"`
	OutputURL      string         `json:"output_url,omitempty"`
	OutputFormat   string         `json:"output_format"`
	Resolution     string         `json:"resolution"`
	Duration       int            `json:"duration"`
	Progress       int            `json:"progress"`
	ErrorMessage   string         `json:"error_message,omitempty"`
	CreatedBy      string         `json:"created_by"`
}

// TimelineItem 时间线条目
type TimelineItem struct {
	ShotID   string  `json:"shot_id"`
	VideoURL string  `json:"video_url"`
	Start    float64 `json:"start"`
	Duration float64 `json:"duration"`
	Order    int     `json:"order"`
}

// AudioTrack 音频轨道
type AudioTrack struct {
	URL      string  `json:"url"`
	Type     string  `json:"type"` // bgm / narration / effect
	Start    float64 `json:"start"`
	Duration float64 `json:"duration"`
	Volume   float64 `json:"volume"`
}

// SubtitleItem 字幕条目
type SubtitleItem struct {
	Start   float64 `json:"start"`
	End     float64 `json:"end"`
	Content string  `json:"content"`
}

// CreateRequest 创建成片任务请求
type CreateRequest struct {
	EpisodeID    string `json:"episode_id"`
	OutputFormat string `json:"output_format"`
	Resolution   string `json:"resolution"`
}

// UpdateTimelineRequest 更新时间线请求
type UpdateTimelineRequest struct {
	Timeline       []TimelineItem `json:"timeline"`
	AudioTracks    []AudioTrack   `json:"audio_tracks"`
	SubtitleTracks []SubtitleItem `json:"subtitle_tracks"`
}

// ExportRequest 导出成片请求
type ExportRequest struct {
	TaskID string `json:"task_id" binding:"required"`
}
