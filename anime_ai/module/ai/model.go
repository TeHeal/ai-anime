package ai

// GenerateTextRequest 统一文本生成请求
type GenerateTextRequest struct {
	Mode          string     `json:"mode"`   // stream | sync | batch
	Action        string     `json:"action"` // polish | expand | prompt | optimize | storyboard | parse
	Instruction   string     `json:"instruction"`
	ReferenceText string     `json:"referenceText"`
	Output        TextOutput `json:"output"`
	Name          string     `json:"name"`
	TargetModel   string     `json:"targetModel"`
	Category      string     `json:"category"`
	LibraryType   string     `json:"libraryType"`
	Language      string     `json:"language"`
}

// TextOutput 文本生成输出目标
type TextOutput struct {
	Type      string `json:"type"` // resource | inline | storyboard | parse_result
	TargetID  string `json:"targetId"`
	ProjectID string `json:"projectId"`
}

// GenerateVoiceRequest 统一音频生成请求
type GenerateVoiceRequest struct {
	Mode        string       `json:"mode"` // clone | design
	Name        string       `json:"name"`
	SampleURL   string       `json:"sampleUrl"`
	Prompt      string       `json:"prompt"`
	PreviewText string       `json:"previewText"`
	Output      VoiceOutput  `json:"output"`
	Provider    string       `json:"provider"`
	Model       string       `json:"model"`
}

// VoiceOutput 音频生成输出目标
type VoiceOutput struct {
	Type       string `json:"type"`
	TargetID   string `json:"targetId"`
	LibraryType string `json:"libraryType"`
}

// GenerateImageRequest 统一图生请求，与计划 §2.3 对齐
type GenerateImageRequest struct {
	Prompt             string   `json:"prompt" binding:"required"`
	NegativePrompt     string   `json:"negativePrompt"`
	ReferenceImageURLs []string `json:"referenceImageUrls"`
	Provider           string   `json:"provider"`
	Model              string   `json:"model"`
	Width              int      `json:"width"`
	Height             int      `json:"height"`
	AspectRatio        string   `json:"aspectRatio"`
	Count              int      `json:"count"`
	Output             Output   `json:"output" binding:"required"`
	Async              bool     `json:"async"`
}

// Output 图生输出目标
type Output struct {
	Type       string `json:"type" binding:"required"` // resource | character | location | shot
	TargetID   string `json:"targetId"`
	ProjectID  string `json:"projectId"`
	LibraryType string `json:"libraryType"`
	Modality   string `json:"modality"`
	Name       string `json:"name"`
}
