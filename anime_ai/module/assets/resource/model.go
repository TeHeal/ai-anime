package resource

import "time"

// Resource 素材库实体（用户级）
// ID 为 string（UUID 格式），与 sch/db pgtype.UUID 兼容
type Resource struct {
	ID          string    `json:"id"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
	UserID      string    `json:"userId"`
	Name        string    `json:"name"`
	LibraryType string    `json:"libraryType"`
	Modality    string    `json:"modality"`
	ThumbnailURL string   `json:"thumbnailUrl"`
	TagsJSON    string    `json:"tagsJson"`
	Version     string    `json:"version"`
	MetadataJSON string   `json:"metadataJson"`
	BindingIdsJSON string `json:"bindingIdsJson"`
	Description string   `json:"description"`
}

// CreateRequest 创建素材请求
type CreateRequest struct {
	Name           string `json:"name" binding:"required"`
	LibraryType    string `json:"libraryType" binding:"required"`
	Modality       string `json:"modality" binding:"required"`
	ThumbnailURL   string `json:"thumbnailUrl"`
	TagsJSON       string `json:"tagsJson"`
	Version        string `json:"version"`
	MetadataJSON   string `json:"metadataJson"`
	BindingIdsJSON string `json:"bindingIdsJson"`
	Description    string `json:"description"`
}

// UpdateRequest 更新素材请求
type UpdateRequest struct {
	Name           *string `json:"name"`
	LibraryType    *string `json:"libraryType"`
	Modality       *string `json:"modality"`
	ThumbnailURL   *string `json:"thumbnailUrl"`
	TagsJSON       *string `json:"tagsJson"`
	Version        *string `json:"version"`
	MetadataJSON   *string `json:"metadataJson"`
	BindingIdsJSON *string `json:"bindingIdsJson"`
	Description    *string `json:"description"`
}

// ListRequest 列表请求（分页、筛选）
type ListRequest struct {
	Modality    string   `form:"modality"`
	LibraryType string   `form:"libraryType"`
	Tags        []string `form:"tags"`
	Search      string   `form:"search"`
	SortBy      string   `form:"sortBy"`
	Page        int      `form:"page"`
	PageSize    int      `form:"pageSize"`
}

// ListResponse 列表响应
type ListResponse struct {
	Items []Resource `json:"items"`
	Total int64      `json:"total"`
	Page  int        `json:"page"`
	Size  int        `json:"pageSize"`
}

// CountsResponse 各子库数量统计
type CountsResponse struct {
	Counts map[string]int64 `json:"counts"`
}

// GeneratePromptRequest 提示词生成请求
type GeneratePromptRequest struct {
	Name        string `json:"name"`
	Instruction string `json:"instruction" binding:"required"`
	TargetModel string `json:"targetModel"`
	Category    string `json:"category"`
	TagsJSON    string `json:"tagsJson"`
	Description string `json:"description"`
	LibraryType string `json:"libraryType"`
	Language    string `json:"language"`
}

// GenerateVoiceRequest 音色克隆请求（音频样本 -> 克隆音色 + 试听）
type GenerateVoiceRequest struct {
	Name        string `json:"name" binding:"required"`
	SampleURL   string `json:"sample_url" binding:"required"` // 待克隆音频 URL（与前端 sample_url 一致）
	Provider    string `json:"provider"`
	Model       string `json:"model"`
	PreviewText string `json:"preview_text"`
	TagsJSON    string `json:"tags_json"`
	Description string `json:"description"`
}

// GenerateVoiceDesignRequest 音色设计请求（文本描述 -> TTS 预设音色 + 预览音频）
type GenerateVoiceDesignRequest struct {
	Name        string `json:"name" binding:"required"`
	Prompt      string `json:"prompt" binding:"required"`
	PreviewText string `json:"previewText"`
	Provider    string `json:"provider"`
	Model       string `json:"model"`
	VoiceID     string `json:"voiceId"`
	TagsJSON    string `json:"tagsJson"`
	Description string `json:"description"`
}

// GeneratePreviewTextRequest 预览文本生成请求（音色描述 -> 适合试听的示例文本）
type GeneratePreviewTextRequest struct {
	VoicePrompt string `json:"voicePrompt" binding:"required"`
	Operator    string `json:"operator"`
	Model       string `json:"model"`
}

// GenerateImageRequest 图生请求
type GenerateImageRequest struct {
	Prompt             string   `json:"prompt" binding:"required"`
	NegativePrompt     string   `json:"negativePrompt"`
	ReferenceImageURL  string   `json:"referenceImageUrl"`
	LibraryType        string   `json:"libraryType"`
	Modality           string   `json:"modality"`
	Provider           string   `json:"provider"`
	Model              string   `json:"model"`
	Name               string   `json:"name"`
	Width              int      `json:"width"`
	Height             int      `json:"height"`
	AspectRatio        string   `json:"aspectRatio"`
}
