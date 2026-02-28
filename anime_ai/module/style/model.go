package style

// Style 风格资产模型
type Style struct {
	ID             string `json:"id"`
	CreatedAt      string `json:"created_at,omitempty"`
	ProjectID      string `json:"project_id"`
	Name           string `json:"name"`
	Description    string `json:"description,omitempty"`
	Category       string `json:"category,omitempty"`
	PreviewURL     string `json:"preview_url,omitempty"`
	PromptTemplate string `json:"prompt_template,omitempty"`
	NegativePrompt string `json:"negative_prompt,omitempty"`
	Status         string `json:"status"`
}
