package capability

import "context"

// VideoRequest 文生视频请求
type VideoRequest struct {
	ImageURL string `json:"image_url"`
	Prompt   string `json:"prompt"`
	Model    string `json:"model"`
	Duration int    `json:"duration,omitempty"`
}

// VideoResult 文生视频结果
type VideoResult struct {
	Status   string `json:"status"`
	VideoURL string `json:"video_url,omitempty"`
	Error    string `json:"error,omitempty"`
}

// VideoProvider 文生视频 Provider 统一接口
type VideoProvider interface {
	Name() string
	SubmitVideoTask(ctx context.Context, req VideoRequest) (taskID string, err error)
	QueryVideoTask(ctx context.Context, taskID string) (*VideoResult, error)
}

// VideoCapability 面向应用的统一文生视频路由能力
type VideoCapability interface {
	Submit(ctx context.Context, req VideoRequest, preferred string) (providerName string, taskID string, err error)
	Query(ctx context.Context, taskID string) (*VideoResult, error)
}
