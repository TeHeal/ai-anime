package storyboard

// ShotItem 分镜单镜头（与旧版 ConfirmShotInput 对齐，存于 project.storyboard_json）
type ShotItem struct {
	SceneID        uint   `json:"scene_id"`
	Prompt         string `json:"prompt"`
	StylePrompt    string `json:"style_prompt"`
	CameraType     string `json:"camera_type"`
	CameraAngle    string `json:"camera_angle"`
	Dialogue       string `json:"dialogue"`
	Voice          string `json:"voice"`
	Duration       int    `json:"duration"`
	SortIndex      int    `json:"sort_index"`
	CharacterName  string `json:"character_name"`
	CharacterID    *uint  `json:"character_id,omitempty"`
	Emotion        string `json:"emotion"`
	Transition     string `json:"transition"`
	NegativePrompt string `json:"negative_prompt"`
}

// GenerateRequest 异步/同步拆镜请求
type GenerateRequest struct {
	EpisodeID uint   `json:"episode_id" binding:"required"`
	Provider  string `json:"provider"`
	Model     string `json:"model"`
}

// PreviewRequest 单场景预览请求
type PreviewRequest struct {
	SceneID  uint   `json:"scene_id" binding:"required"`
	Provider string `json:"provider"`
	Model    string `json:"model"`
}

// ConfirmRequest 确认导入请求
type ConfirmRequest struct {
	Shots []ShotItem `json:"shots" binding:"required,min=1"`
}

// GenerateTaskResponse 异步生成任务响应（占位，后续接 Worker）
type GenerateTaskResponse struct {
	TaskID string `json:"task_id"`
	Status string `json:"status"`
}
