package llm

const KimiBaseURL = "https://api.moonshot.cn/v1"

// NewKimiProvider 创建 Kimi Provider（默认模型 moonshot-v1-8k）
func NewKimiProvider(apiKey string) *OpenAICompatProvider {
	return NewOpenAICompatProviderWithModel("kimi", KimiBaseURL, apiKey, "moonshot-v1-8k")
}
