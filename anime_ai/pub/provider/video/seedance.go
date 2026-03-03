// Package video 文生视频 Provider 实现
package video

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

// SeedanceProvider 字节 Seedance 视频生成（对齐火山方舟 Ark Content Generation API）
type SeedanceProvider struct {
	apiKey  string
	baseURL string
	client  *http.Client
}

// NewSeedanceProvider 创建 Seedance Provider
func NewSeedanceProvider(apiKey string) *SeedanceProvider {
	return &SeedanceProvider{
		apiKey:  apiKey,
		baseURL: "https://ark.cn-beijing.volces.com/api/v3",
		client:  &http.Client{Timeout: 60 * time.Second},
	}
}

func (p *SeedanceProvider) Name() string { return "seedance" }

// ── Ark API 请求/响应结构 ──

// arkContentItem 对齐 Ark content 数组项
type arkContentItem struct {
	Type      string        `json:"type"`
	Text      string        `json:"text,omitempty"`
	ImageURL  *arkImageURL  `json:"image_url,omitempty"`
	Role      string        `json:"role,omitempty"`
	DraftTask *arkDraftTask `json:"draft_task,omitempty"`
}

type arkImageURL struct {
	URL string `json:"url"`
}

type arkDraftTask struct {
	ID string `json:"id"`
}

// arkCreateTaskReq 创建视频生成任务请求体
type arkCreateTaskReq struct {
	Model                 string            `json:"model"`
	Content               []arkContentItem  `json:"content"`
	Resolution            string            `json:"resolution,omitempty"`
	Ratio                 string            `json:"ratio,omitempty"`
	Duration              *int              `json:"duration,omitempty"`
	Frames                *int              `json:"frames,omitempty"`
	Seed                  *int64            `json:"seed,omitempty"`
	CameraFixed           *bool             `json:"camera_fixed,omitempty"`
	Watermark             *bool             `json:"watermark,omitempty"`
	GenerateAudio         *bool             `json:"generate_audio,omitempty"`
	Draft                 *bool             `json:"draft,omitempty"`
	ReturnLastFrame       *bool             `json:"return_last_frame,omitempty"`
	ServiceTier           string            `json:"service_tier,omitempty"`
	ExecutionExpiresAfter *int64            `json:"execution_expires_after,omitempty"`
	CallbackURL           string            `json:"callback_url,omitempty"`
}

// arkCreateTaskResp Ark 创建任务响应
type arkCreateTaskResp struct {
	ID    string       `json:"id"`
	Error *arkAPIError `json:"error,omitempty"`
}

type arkAPIError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// arkGetTaskResp Ark 查询任务响应
type arkGetTaskResp struct {
	ID                    string           `json:"id"`
	Model                 string           `json:"model"`
	Status                string           `json:"status"` // queued | running | succeeded | failed | expired
	Content               *arkTaskContent  `json:"content,omitempty"`
	Usage                 *arkTaskUsage    `json:"usage,omitempty"`
	Error                 *arkAPIError     `json:"error,omitempty"`
	Seed                  int64            `json:"seed"`
	Resolution            string           `json:"resolution"`
	Ratio                 string           `json:"ratio"`
	Duration              int              `json:"duration"`
	FramesPerSecond       int              `json:"framespersecond"`
	ServiceTier           string           `json:"service_tier"`
	CreatedAt             int64            `json:"created_at"`
	UpdatedAt             int64            `json:"updated_at"`
}

type arkTaskContent struct {
	VideoURL     string `json:"video_url"`
	LastFrameURL string `json:"last_frame_url,omitempty"`
}

type arkTaskUsage struct {
	CompletionTokens int64 `json:"completion_tokens"`
	TotalTokens      int64 `json:"total_tokens"`
}

// ── 核心方法 ──

func (p *SeedanceProvider) SubmitVideoTask(ctx context.Context, req capability.VideoRequest) (string, error) {
	arkReq := p.buildCreateRequest(req)

	jsonBody, err := json.Marshal(arkReq)
	if err != nil {
		return "", fmt.Errorf("序列化请求失败: %w", err)
	}

	endpoint := p.baseURL + "/contents/generations/tasks"
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, bytes.NewReader(jsonBody))
	if err != nil {
		return "", fmt.Errorf("创建 HTTP 请求失败: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("发送请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("读取响应失败: %w", err)
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return "", fmt.Errorf("Ark API 返回 %d: %s", resp.StatusCode, string(body))
	}

	var result arkCreateTaskResp
	if err := json.Unmarshal(body, &result); err != nil {
		return "", fmt.Errorf("解析响应失败: %w", err)
	}

	if result.Error != nil {
		return "", fmt.Errorf("Ark API 错误 [%s]: %s", result.Error.Code, result.Error.Message)
	}

	if result.ID == "" {
		return "", fmt.Errorf("Ark API 返回空任务 ID")
	}

	return result.ID, nil
}

func (p *SeedanceProvider) QueryVideoTask(ctx context.Context, taskID string) (*capability.VideoResult, error) {
	endpoint := fmt.Sprintf("%s/contents/generations/tasks/%s", p.baseURL, taskID)

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return nil, fmt.Errorf("创建查询请求失败: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("查询请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取查询响应失败: %w", err)
	}

	var taskResp arkGetTaskResp
	if err := json.Unmarshal(body, &taskResp); err != nil {
		return nil, fmt.Errorf("解析查询响应失败: %w", err)
	}

	result := &capability.VideoResult{
		ProviderTaskID: taskResp.ID,
		Resolution:     taskResp.Resolution,
		Ratio:          taskResp.Ratio,
		Duration:       taskResp.Duration,
		FPS:            taskResp.FramesPerSecond,
		Seed:           taskResp.Seed,
		ServiceTier:    taskResp.ServiceTier,
	}

	if taskResp.Usage != nil {
		result.TokensUsed = taskResp.Usage.TotalTokens
	}

	switch taskResp.Status {
	case "succeeded":
		result.Status = "completed"
		if taskResp.Content != nil {
			result.VideoURL = taskResp.Content.VideoURL
			result.LastFrameURL = taskResp.Content.LastFrameURL
		}
	case "failed":
		result.Status = "failed"
		if taskResp.Error != nil {
			result.Error = taskResp.Error.Message
			result.ErrorCode = taskResp.Error.Code
		}
	case "expired":
		result.Status = "failed"
		result.Error = "任务已过期"
	case "queued":
		result.Status = "pending"
	case "running":
		result.Status = "pending"
	default:
		result.Status = "pending"
	}

	return result, nil
}

// buildCreateRequest 根据 VideoRequest 构建 Ark API 请求体
func (p *SeedanceProvider) buildCreateRequest(req capability.VideoRequest) arkCreateTaskReq {
	arkReq := arkCreateTaskReq{
		Model:         p.resolveModel(req.Model),
		Resolution:    req.Resolution,
		Ratio:         req.Ratio,
		Seed:          req.Seed,
		CameraFixed:   req.CameraFixed,
		Watermark:     req.Watermark,
		GenerateAudio: req.GenerateAudio,
		Draft:         req.Draft,
		ReturnLastFrame: req.ReturnLastFrame,
		ServiceTier:   req.ServiceTier,
		CallbackURL:   req.CallbackURL,
	}

	if req.Duration > 0 {
		d := req.Duration
		arkReq.Duration = &d
	}
	if req.Frames > 0 {
		f := req.Frames
		arkReq.Frames = &f
	}
	if req.ExecutionExpiresAfter > 0 {
		e := req.ExecutionExpiresAfter
		arkReq.ExecutionExpiresAfter = &e
	}

	// 如果有高级 ContentItems，直接使用
	if len(req.ContentItems) > 0 {
		arkReq.Content = p.convertContentItems(req.ContentItems)
		return arkReq
	}

	// 否则从基础字段构建 content 数组
	arkReq.Content = p.buildContentFromBasicFields(req)
	return arkReq
}

// convertContentItems 将 capability.VideoContentItem 转为 Ark API 格式
func (p *SeedanceProvider) convertContentItems(items []capability.VideoContentItem) []arkContentItem {
	var result []arkContentItem
	for _, item := range items {
		ai := arkContentItem{
			Type: item.Type,
			Role: item.Role,
		}
		switch item.Type {
		case "text":
			ai.Text = item.Text
		case "image_url":
			ai.ImageURL = &arkImageURL{URL: item.ImageURL}
		case "draft_task":
			ai.DraftTask = &arkDraftTask{ID: item.DraftID}
		}
		result = append(result, ai)
	}
	return result
}

// buildContentFromBasicFields 从简化字段构建 Ark content 数组
func (p *SeedanceProvider) buildContentFromBasicFields(req capability.VideoRequest) []arkContentItem {
	var items []arkContentItem

	// Draft 模式：基于 Draft 生成正式视频
	if req.Mode == capability.VideoModeDraftToFinal && req.DraftTaskID != "" {
		items = append(items, arkContentItem{
			Type:      "draft_task",
			DraftTask: &arkDraftTask{ID: req.DraftTaskID},
		})
		return items
	}

	// 提示词
	if req.Prompt != "" {
		items = append(items, arkContentItem{
			Type: "text",
			Text: req.Prompt,
		})
	}

	switch req.Mode {
	case capability.VideoModeFirstFrame:
		// 首帧图生视频
		if req.ImageURL != "" {
			items = append(items, arkContentItem{
				Type:     "image_url",
				ImageURL: &arkImageURL{URL: req.ImageURL},
			})
		}

	case capability.VideoModeFirstLastFrame:
		// 首尾帧图生视频
		if req.ImageURL != "" {
			items = append(items, arkContentItem{
				Type:     "image_url",
				ImageURL: &arkImageURL{URL: req.ImageURL},
				Role:     "first_frame",
			})
		}
		if req.LastFrameImageURL != "" {
			items = append(items, arkContentItem{
				Type:     "image_url",
				ImageURL: &arkImageURL{URL: req.LastFrameImageURL},
				Role:     "last_frame",
			})
		}

	case capability.VideoModeReferenceImages:
		// 参考图生视频（1~4 张）
		for _, url := range req.ReferenceImageURLs {
			items = append(items, arkContentItem{
				Type:     "image_url",
				ImageURL: &arkImageURL{URL: url},
				Role:     "reference_image",
			})
		}

	default:
		// text2video 或兼容旧接口
		if req.ImageURL != "" {
			items = append(items, arkContentItem{
				Type:     "image_url",
				ImageURL: &arkImageURL{URL: req.ImageURL},
			})
		}
	}

	return items
}

// resolveModel 解析模型名称到 Ark 模型 ID
func (p *SeedanceProvider) resolveModel(model string) string {
	switch model {
	case "seedance-1.5-pro", "seedance_1_5_pro":
		return "doubao-seedance-1-5-pro-251215"
	case "seedance-1.0-pro", "seedance_1_0_pro":
		return "doubao-seedance-1-0-pro-250528"
	case "seedance-1.0-pro-fast", "seedance_1_0_pro_fast":
		return "doubao-seedance-1-0-pro-fast-251015"
	case "seedance-1.0-lite-i2v", "seedance_1_0_lite_i2v":
		return "doubao-seedance-1-0-lite-i2v-250428"
	case "seedance-1.0-lite-t2v", "seedance_1_0_lite_t2v":
		return "doubao-seedance-1-0-lite-t2v-250428"
	case "":
		return "doubao-seedance-1-5-pro-251215"
	default:
		// 已经是完整 model ID 的情况直接使用
		return model
	}
}
