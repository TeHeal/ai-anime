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

// SunoProvider 实现 MusicProvider，使用 Suno API 网关
type SunoProvider struct {
	apiKey  string
	baseURL string
	client  *http.Client
}

// NewSunoProvider 创建 Suno Provider
func NewSunoProvider(apiKey, baseURL string) *SunoProvider {
	if baseURL == "" {
		baseURL = "https://studio-api.suno.ai/api"
	}
	return &SunoProvider{
		apiKey:  apiKey,
		baseURL: baseURL,
		client:  &http.Client{Timeout: 30 * time.Second},
	}
}

func (p *SunoProvider) Name() string { return "suno" }

type sunoGenerateReq struct {
	Prompt           string `json:"prompt"`
	MakeInstrumental bool   `json:"make_instrumental,omitempty"`
	Model            string `json:"model,omitempty"`
}

type sunoGenerateResp struct {
	ID    string `json:"id"`
	Error string `json:"error,omitempty"`
}

type sunoClip struct {
	ID       string  `json:"id"`
	Status   string  `json:"status"`
	AudioURL string  `json:"audio_url,omitempty"`
	Title    string  `json:"title,omitempty"`
	Duration float64 `json:"duration,omitempty"`
}

type sunoQueryResp struct {
	ID    string     `json:"id"`
	Clips []sunoClip `json:"clips,omitempty"`
	Error string     `json:"error,omitempty"`
}

func (p *SunoProvider) SubmitMusicTask(ctx context.Context, req provider.MusicRequest) (string, error) {
	body := sunoGenerateReq{
		Prompt: req.Prompt,
		Model:  req.Model,
	}

	jsonBody, err := json.Marshal(body)
	if err != nil {
		return "", fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, p.baseURL+"/generate/v2", bytes.NewReader(jsonBody))
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

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return "", fmt.Errorf("API returned %d: %s", resp.StatusCode, string(data))
	}

	var result sunoGenerateResp
	if err := json.Unmarshal(data, &result); err != nil {
		return "", fmt.Errorf("unmarshal response: %w", err)
	}
	if result.Error != "" {
		return "", fmt.Errorf("API error: %s", result.Error)
	}

	return result.ID, nil
}

func (p *SunoProvider) QueryMusicTask(ctx context.Context, taskID string) (*provider.MusicResult, error) {
	url := fmt.Sprintf("%s/feed/%s", p.baseURL, taskID)

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

	var qr sunoQueryResp
	if err := json.Unmarshal(data, &qr); err != nil {
		return nil, fmt.Errorf("unmarshal response: %w", err)
	}

	result := &provider.MusicResult{}

	if len(qr.Clips) == 0 {
		result.Status = "pending"
		return result, nil
	}

	clip := qr.Clips[0]
	switch clip.Status {
	case "complete":
		result.Status = "completed"
		result.AudioURL = clip.AudioURL
	case "error":
		result.Status = "failed"
		result.Error = qr.Error
	default:
		result.Status = "pending"
	}

	return result, nil
}
