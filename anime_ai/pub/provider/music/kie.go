package music

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/provider"
)

// KieMusicProvider 通过 kie.ai API 实现 MusicProvider（Suno 等音乐模型）
// 参考 docs.kie.ai/suno-api/generate-music、get-music-details
type KieMusicProvider struct {
	apiKey    string
	baseURL   string
	callbackURL string
	client    *http.Client
}

// NewKieMusicProvider 创建 Kie 音乐 Provider
func NewKieMusicProvider(apiKey string) *KieMusicProvider {
	return &KieMusicProvider{
		apiKey:      apiKey,
		baseURL:     "https://api.kie.ai",
		callbackURL: "https://example.com/kie-music-callback",
		client:      &http.Client{Timeout: 60 * time.Second},
	}
}

// NewKieMusicProviderWithCallback 指定 callback URL（可选，用于 webhook）
func NewKieMusicProviderWithCallback(apiKey, callbackURL string) *KieMusicProvider {
	p := NewKieMusicProvider(apiKey)
	if callbackURL != "" {
		p.callbackURL = callbackURL
	}
	return p
}

func (p *KieMusicProvider) Name() string { return "kie" }

type kieMusicGenerateReq struct {
	CustomMode   bool   `json:"customMode"`
	Instrumental bool   `json:"instrumental"`
	Model        string `json:"model"`
	Prompt       string `json:"prompt"`
	CallBackUrl  string `json:"callBackUrl"`
	Style        string `json:"style,omitempty"`
	Title        string `json:"title,omitempty"`
}

type kieMusicCreateResp struct {
	Code int    `json:"code"`
	Msg  string `json:"msg"`
	Data struct {
		TaskID string `json:"taskId"`
	} `json:"data"`
}

type kieMusicRecordResp struct {
	Code int    `json:"code"`
	Msg  string `json:"msg"`
	Data struct {
		TaskID   string `json:"taskId"`
		Status   string `json:"status"`
		Response struct {
			SunoData []struct {
				AudioURL string  `json:"audioUrl"`
				Duration float64 `json:"duration"`
			} `json:"sunoData"`
		} `json:"response"`
		ErrorMessage string `json:"errorMessage"`
	} `json:"data"`
}

func kieMusicModel(reqModel string) string {
	switch reqModel {
	case "V5", "v5":
		return "V5"
	case "V4_5PLUS", "v4_5plus":
		return "V4_5PLUS"
	case "V4_5", "v4_5":
		return "V4_5"
	case "V4_5ALL", "v4_5all":
		return "V4_5ALL"
	case "V4", "v4":
		return "V4"
	default:
		return "V4"
	}
}

func (p *KieMusicProvider) SubmitMusicTask(ctx context.Context, req provider.MusicRequest) (string, error) {
	model := kieMusicModel(req.Model)
	body := kieMusicGenerateReq{
		CustomMode:   false,
		Instrumental: false,
		Model:        model,
		Prompt:       req.Prompt,
		CallBackUrl:  p.callbackURL,
	}

	jsonBody, err := json.Marshal(body)
	if err != nil {
		return "", fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, p.baseURL+"/api/v1/generate", bytes.NewReader(jsonBody))
	if err != nil {
		return "", err
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("http request failed: %w", err)
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("read response: %w", err)
	}

	var result kieMusicCreateResp
	if err := json.Unmarshal(data, &result); err != nil {
		return "", fmt.Errorf("unmarshal response: %w", err)
	}

	if result.Code != 200 {
		return "", fmt.Errorf("KIE music API error %d: %s", result.Code, result.Msg)
	}

	if result.Data.TaskID == "" {
		return "", fmt.Errorf("KIE music API returned empty taskId")
	}

	return result.Data.TaskID, nil
}

func (p *KieMusicProvider) QueryMusicTask(ctx context.Context, taskID string) (*provider.MusicResult, error) {
	url := fmt.Sprintf("%s/api/v1/generate/record-info?taskId=%s", p.baseURL, taskID)

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("http request failed: %w", err)
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	var info kieMusicRecordResp
	if err := json.Unmarshal(data, &info); err != nil {
		return nil, fmt.Errorf("unmarshal response: %w", err)
	}

	result := &provider.MusicResult{}

	switch info.Data.Status {
	case "SUCCESS":
		result.Status = "completed"
		if len(info.Data.Response.SunoData) > 0 {
			result.AudioURL = info.Data.Response.SunoData[0].AudioURL
		}
	case "CREATE_TASK_FAILED", "GENERATE_AUDIO_FAILED", "CALLBACK_EXCEPTION", "SENSITIVE_WORD_ERROR":
		result.Status = "failed"
		result.Error = info.Data.ErrorMessage
		if result.Error == "" {
			result.Error = "music generation failed (" + info.Data.Status + ")"
		}
	default:
		result.Status = "pending"
	}

	return result, nil
}
