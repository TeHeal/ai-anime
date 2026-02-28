package llm

const DoubaoBaseURL = "https://ark.cn-beijing.volces.com/api/v3"

// NewDoubaoProvider 创建豆包 Provider
func NewDoubaoProvider(apiKey string) *OpenAICompatProvider {
	return NewOpenAICompatProvider("doubao", DoubaoBaseURL, apiKey)
}
