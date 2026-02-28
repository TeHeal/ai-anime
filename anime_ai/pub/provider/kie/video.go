package kie

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// KIEVideoProvider 通过 KIE Market 统一 API 实现 VideoProvider
type KIEVideoProvider struct {
	apiKey  string
	baseURL string
	client  *http.Client
}

// NewKIEVideoProvider 创建 KIE 文生视频 Provider
func NewKIEVideoProvider(apiKey string) *KIEVideoProvider {
	return &KIEVideoProvider{
		apiKey:  apiKey,
		baseURL: "https://api.kie.ai",
		client:  &http.Client{Timeout: 30 * time.Second},
	}
}

func (p *KIEVideoProvider) Name() string { return "kie_video" }

type kieVideoInput struct {
	Prompt   string `json:"prompt,omitempty"`
	ImageURL string `json:"image_url,omitempty"`
	Duration int    `json:"duration,omitempty"`
}

type kieVideoCreateReq struct {
	Model string        `json:"model"`
	Input kieVideoInput `json:"input"`
}

func kieVideoModel(reqModel string) string {
	switch reqModel {
	case "gen3a_turbo":
		return "runway/gen3a_turbo"
	case "kling-v1", "kling-2.6/text-to-video":
		return "kling-2.6/text-to-video"
	default:
		return "kling-2.6/text-to-video"
	}
}

func (p *KIEVideoProvider) SubmitVideoTask(ctx context.Context, req capability.VideoRequest) (string, error) {
	model := kieVideoModel(req.Model)
	input := kieVideoInput{
		Prompt: req.Prompt,
	}
	if req.ImageURL != "" {
		input.ImageURL = req.ImageURL
		if req.Model == "" || req.Model == "gen3a_turbo" {
			model = "runway/gen3a_turbo"
		} else {
			model = "kling-2.6/image-to-video"
		}
	}
	if req.Duration > 0 {
		input.Duration = req.Duration
	}

	body := kieVideoCreateReq{Model: model, Input: input}
	jsonBody, err := json.Marshal(body)
	if err != nil {
		return "", fmt.Errorf("marshal request: %w", err)
	}

	endpoint := p.baseURL + "/api/v1/jobs/createTask"
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, bytes.NewReader(jsonBody))
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

	var result kieCreateTaskResp
	if err := json.Unmarshal(data, &result); err != nil {
		return "", fmt.Errorf("unmarshal response: %w", err)
	}

	if result.Code != 200 {
		return "", fmt.Errorf("KIE API error %d: %s", result.Code, result.Msg)
	}

	return result.Data.TaskID, nil
}

func (p *KIEVideoProvider) QueryVideoTask(ctx context.Context, taskID string) (*capability.VideoResult, error) {
	endpoint := fmt.Sprintf("%s/api/v1/jobs/recordInfo?taskId=%s", p.baseURL, taskID)

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
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

	var info kieRecordInfoResp
	if err := json.Unmarshal(data, &info); err != nil {
		return nil, fmt.Errorf("unmarshal response: %w", err)
	}

	vidResult := &capability.VideoResult{}
	switch info.Data.State {
	case "success":
		vidResult.Status = "completed"
		if info.Data.ResultJSON != "" {
			var payload kieResultPayload
			if err := json.Unmarshal([]byte(info.Data.ResultJSON), &payload); err == nil && len(payload.ResultURLs) > 0 {
				vidResult.VideoURL = payload.ResultURLs[0]
			}
		}
	case "fail":
		vidResult.Status = "failed"
		vidResult.Error = info.Data.FailMsg
		if vidResult.Error == "" {
			vidResult.Error = "generation failed (code: " + info.Data.FailCode + ")"
		}
	default:
		vidResult.Status = "pending"
	}

	return vidResult, nil
}
