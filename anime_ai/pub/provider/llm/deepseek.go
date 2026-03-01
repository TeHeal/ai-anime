package llm

const DeepSeekBaseURL = "https://api.deepseek.com/v1"

// NewDeepSeekProvider 创建 DeepSeek Provider（默认模型 deepseek-chat）
func NewDeepSeekProvider(apiKey string) *OpenAICompatProvider {
	return NewOpenAICompatProviderWithModel("deepseek", DeepSeekBaseURL, apiKey, "deepseek-chat")
}
