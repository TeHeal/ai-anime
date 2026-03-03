package style

import "time"

// Style 风格实体，API 响应使用 camelCase 以兼容前端
type Style struct {
	ID                  string    `json:"id"`
	ProjectID           string    `json:"projectId"`
	CreatedAt           time.Time `json:"createdAt"`
	UpdatedAt           time.Time `json:"updatedAt"`
	Name                string    `json:"name"`
	Description         string    `json:"description"`
	NegativePrompt      string    `json:"negativePrompt"`
	ReferenceImagesJSON string    `json:"referenceImagesJson"`
	ThumbnailURL        string    `json:"thumbnailUrl"`
	IsPreset            bool      `json:"isPreset"`
	IsProjectDefault    bool      `json:"isProjectDefault"`
}

// CreateRequest 创建风格请求
type CreateRequest struct {
	Name             string `json:"name" binding:"required"`
	Description      string `json:"description"`
	NegativePrompt   string `json:"negativePrompt"`
	ReferenceImages  string `json:"referenceImagesJson"`
	ThumbnailURL     string `json:"thumbnailUrl"`
	IsProjectDefault bool   `json:"isProjectDefault"`
}

// UpdateRequest 更新风格请求
type UpdateRequest struct {
	Name             *string `json:"name"`
	Description      *string `json:"description"`
	NegativePrompt   *string `json:"negativePrompt"`
	ReferenceImages  *string `json:"referenceImagesJson"`
	ThumbnailURL     *string `json:"thumbnailUrl"`
	IsProjectDefault *bool   `json:"isProjectDefault"`
}
