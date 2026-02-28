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

// KIEImageProvider 通过 KIE Market 统一 API 实现 ImageProvider
type KIEImageProvider struct {
	apiKey  string
	baseURL string
	client  *http.Client
}

// NewKIEImageProvider 创建 KIE 文生图 Provider
func NewKIEImageProvider(apiKey string) *KIEImageProvider {
	return &KIEImageProvider{
		apiKey:  apiKey,
		baseURL: "https://api.kie.ai",
		client:  &http.Client{Timeout: 30 * time.Second},
	}
}

func (p *KIEImageProvider) Name() string { return "kie" }

type kieCreateTaskReq struct {
	Model string      `json:"model"`
	Input kieImgInput `json:"input"`
}

type kieImgInput struct {
	Prompt    string `json:"prompt"`
	ImageSize string `json:"image_size,omitempty"`
}

type kieCreateTaskResp struct {
	Code int    `json:"code"`
	Msg  string `json:"msg"`
	Data struct {
		TaskID string `json:"taskId"`
	} `json:"data"`
}

type kieRecordInfoResp struct {
	Code int    `json:"code"`
	Msg  string `json:"msg"`
	Data struct {
		TaskID     string `json:"taskId"`
		State      string `json:"state"`
		ResultJSON string `json:"resultJson"`
		FailCode   string `json:"failCode"`
		FailMsg    string `json:"failMsg"`
	} `json:"data"`
}

type kieResultPayload struct {
	ResultURLs []string `json:"resultUrls"`
}

func imageSizeFromDimensions(w, h int) string {
	if w <= 0 || h <= 0 {
		return "square_hd"
	}
	ratio := float64(w) / float64(h)
	switch {
	case ratio > 1.6:
		return "landscape_16_9"
	case ratio > 1.2:
		return "landscape_4_3"
	case ratio < 0.625:
		return "portrait_16_9"
	case ratio < 0.83:
		return "portrait_4_3"
	default:
		return "square_hd"
	}
}

func kieModelForProvider(reqModel string) string {
	switch reqModel {
	case "seedream-3.0", "bytedance/seedream":
		return "bytedance/seedream"
	case "flux-pro-1.1", "flux-2/pro-text-to-image":
		return "flux-2/pro-text-to-image"
	case "flux-flex", "flux-2/flex-text-to-image":
		return "flux-2/flex-text-to-image"
	case "sd3.5-large":
		return "bytedance/seedream"
	default:
		return "bytedance/seedream"
	}
}

func (p *KIEImageProvider) SubmitImageTask(ctx context.Context, req capability.ImageRequest) (string, error) {
	model := kieModelForProvider(req.Model)
	body := kieCreateTaskReq{
		Model: model,
		Input: kieImgInput{
			Prompt:    req.Prompt,
			ImageSize: imageSizeFromDimensions(req.Width, req.Height),
		},
	}

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

func (p *KIEImageProvider) QueryImageTask(ctx context.Context, taskID string) (*capability.ImageResult, error) {
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

	imgResult := &capability.ImageResult{}
	switch info.Data.State {
	case "success":
		imgResult.Status = "completed"
		if info.Data.ResultJSON != "" {
			var payload kieResultPayload
			if err := json.Unmarshal([]byte(info.Data.ResultJSON), &payload); err == nil {
				imgResult.URLs = payload.ResultURLs
			}
		}
	case "fail":
		imgResult.Status = "failed"
		imgResult.Error = info.Data.FailMsg
		if imgResult.Error == "" {
			imgResult.Error = "generation failed (code: " + info.Data.FailCode + ")"
		}
	default:
		imgResult.Status = "pending"
	}

	return imgResult, nil
}
