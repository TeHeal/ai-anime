package capability

import "context"

// ImageRequest 文生图请求
type ImageRequest struct {
	Prompt             string   `json:"prompt"`
	NegativePrompt     string   `json:"negative_prompt,omitempty"`
	Model              string   `json:"model"`
	Width              int      `json:"width,omitempty"`
	Height             int      `json:"height,omitempty"`
	Count              int      `json:"count,omitempty"`
	ReferenceImageURLs []string `json:"reference_image_urls,omitempty"`
	Size               string   `json:"size,omitempty"`
	Seed               int64    `json:"seed,omitempty"`
	AspectRatio        string   `json:"aspect_ratio,omitempty"`
}

// ImageResult 文生图结果
type ImageResult struct {
	Status string   `json:"status"`
	URLs   []string `json:"urls,omitempty"`
	Error  string   `json:"error,omitempty"`
}

// ImageProvider 文生图 Provider 统一接口
type ImageProvider interface {
	Name() string
	SubmitImageTask(ctx context.Context, req ImageRequest) (taskID string, err error)
	QueryImageTask(ctx context.Context, taskID string) (*ImageResult, error)
}

// ImageCapability 面向应用的统一文生图路由能力
type ImageCapability interface {
	Submit(ctx context.Context, req ImageRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*ImageResult, error)
}
