package audio

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"anime_ai/pub/capability"
)

// CosyVoiceTTSProvider CosyVoice TTS（OpenAI 兼容 API）
type CosyVoiceTTSProvider struct {
	apiKey  string
	baseURL string
	client  *http.Client
}

// NewCosyVoiceTTSProvider 创建 CosyVoice TTS Provider
// baseURL 默认使用 DashScope OpenAI 兼容端点
func NewCosyVoiceTTSProvider(apiKey string) *CosyVoiceTTSProvider {
	return &CosyVoiceTTSProvider{
		apiKey:  apiKey,
		baseURL: "https://dashscope.aliyuncs.com/compatible-mode/v1",
		client:  &http.Client{Timeout: 60 * time.Second},
	}
}

func (p *CosyVoiceTTSProvider) Name() string { return "cosyvoice" }

// ttsRequest OpenAI 兼容 TTS 请求体
type ttsRequest struct {
	Model string `json:"model"`
	Input string `json:"input"`
	Voice string `json:"voice"`
}

// ttsAsyncResponse 异步任务返回体
type ttsAsyncResponse struct {
	ID     string `json:"id"`
	Status string `json:"status"`
	Output struct {
		AudioURL string `json:"audio_url"`
	} `json:"output"`
	Error struct {
		Message string `json:"message"`
	} `json:"error"`
}

// SubmitTTSTask 提交 TTS 任务
func (p *CosyVoiceTTSProvider) SubmitTTSTask(ctx context.Context, req capability.TTSRequest) (string, error) {
	model := req.Model
	if model == "" {
		model = "cosyvoice-v1"
	}
	voice := req.VoiceID
	if voice == "" {
		voice = "longxiaochun"
	}

	body := ttsRequest{
		Model: model,
		Input: req.Text,
		Voice: voice,
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return "", fmt.Errorf("序列化请求失败: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, p.baseURL+"/audio/speech", bytes.NewReader(bodyBytes))
	if err != nil {
		return "", fmt.Errorf("创建请求失败: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)
	httpReq.Header.Set("X-DashScope-Async", "enable")

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("请求 CosyVoice 失败: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return "", fmt.Errorf("CosyVoice 返回错误 %d: %s", resp.StatusCode, string(respBody))
	}

	var result ttsAsyncResponse
	if err := json.Unmarshal(respBody, &result); err != nil {
		return "", fmt.Errorf("解析响应失败: %w", err)
	}

	if result.ID == "" {
		return "", fmt.Errorf("CosyVoice 未返回任务 ID")
	}

	return result.ID, nil
}

// QueryTTSTask 查询 TTS 任务状态
func (p *CosyVoiceTTSProvider) QueryTTSTask(ctx context.Context, taskID string) (*capability.TTSResult, error) {
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, p.baseURL+"/tasks/"+taskID, nil)
	if err != nil {
		return nil, fmt.Errorf("创建查询请求失败: %w", err)
	}
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("查询 CosyVoice 任务失败: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var result ttsAsyncResponse
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("解析查询响应失败: %w", err)
	}

	ttsResult := &capability.TTSResult{
		Status: result.Status,
	}
	if result.Output.AudioURL != "" {
		ttsResult.AudioURL = result.Output.AudioURL
		ttsResult.Status = "completed"
	}
	if result.Error.Message != "" {
		ttsResult.Error = result.Error.Message
		ttsResult.Status = "failed"
	}

	return ttsResult, nil
}
