package llm

const DoubaoBaseURL = "https://ark.cn-beijing.volces.com/api/v3"

// NewDoubaoProvider 创建豆包 Provider（默认模型 doubao-pro-4k）
func NewDoubaoProvider(apiKey string) *OpenAICompatProvider {
	return NewOpenAICompatProviderWithModel("doubao", DoubaoBaseURL, apiKey, "doubao-pro-4k")
}
