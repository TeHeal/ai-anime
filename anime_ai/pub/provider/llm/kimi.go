package llm

const KimiBaseURL = "https://api.moonshot.cn/v1"

// NewKimiProvider 创建 Kimi Provider
func NewKimiProvider(apiKey string) *OpenAICompatProvider {
	return NewOpenAICompatProvider("kimi", KimiBaseURL, apiKey)
}
