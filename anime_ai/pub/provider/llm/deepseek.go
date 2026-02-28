package llm

const DeepSeekBaseURL = "https://api.deepseek.com/v1"

// NewDeepSeekProvider 创建 DeepSeek Provider
func NewDeepSeekProvider(apiKey string) *OpenAICompatProvider {
	return NewOpenAICompatProvider("deepseek", DeepSeekBaseURL, apiKey)
}
