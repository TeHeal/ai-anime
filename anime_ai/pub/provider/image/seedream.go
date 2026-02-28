// Package image 文生图 Provider 实现
package image

import (
	"context"
	"fmt"
	"math"
	"sync"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/volcengine/volcengine-go-sdk/service/arkruntime"
	"github.com/volcengine/volcengine-go-sdk/service/arkruntime/model"
	"github.com/volcengine/volcengine-go-sdk/volcengine"
)

const (
	defaultSeedreamModel  = "doubao-seedream-4-5-251128"
	seedreamMinPixels     = 3686400
	seedreamDefaultSize   = "2048x2048"
)

// SeedreamProvider 火山 Seedream 文生图
type SeedreamProvider struct {
	client  *arkruntime.Client
	mu      sync.Mutex
	results map[string]*capability.ImageResult
}

// NewSeedreamProvider 创建 Seedream Provider
func NewSeedreamProvider(apiKey string) *SeedreamProvider {
	return &SeedreamProvider{
		client:  arkruntime.NewClientWithApiKey(apiKey),
		results: make(map[string]*capability.ImageResult),
	}
}

func (p *SeedreamProvider) Name() string { return "seedream" }

func (p *SeedreamProvider) SubmitImageTask(ctx context.Context, req capability.ImageRequest) (string, error) {
	mdl := req.Model
	if mdl == "" {
		mdl = defaultSeedreamModel
	}

	generateReq := model.GenerateImagesRequest{
		Model:          mdl,
		Prompt:         req.Prompt,
		ResponseFormat: volcengine.String(model.GenerateImagesResponseFormatURL),
		Watermark:      volcengine.Bool(false),
	}

	size := resolveSize(req)
	generateReq.Size = volcengine.String(size)

	if req.Seed != 0 {
		generateReq.Seed = volcengine.Int64(req.Seed)
	}

	if len(req.ReferenceImageURLs) == 1 {
		generateReq.Image = req.ReferenceImageURLs[0]
	} else if len(req.ReferenceImageURLs) > 1 {
		generateReq.Image = req.ReferenceImageURLs
	}

	resp, err := p.client.GenerateImages(ctx, generateReq)
	if err != nil {
		return "", fmt.Errorf("seedream generate: %w", err)
	}

	if resp.Error != nil {
		return "", fmt.Errorf("seedream API error %s: %s", resp.Error.Code, resp.Error.Message)
	}

	if len(resp.Data) == 0 {
		return "", fmt.Errorf("seedream API returned no images")
	}

	taskID := fmt.Sprintf("seedream_%d", time.Now().UnixNano())

	imgResult := &capability.ImageResult{Status: "completed"}
	for _, img := range resp.Data {
		if img != nil && img.Url != nil {
			imgResult.URLs = append(imgResult.URLs, *img.Url)
		}
	}

	p.mu.Lock()
	p.results[taskID] = imgResult
	p.mu.Unlock()

	return taskID, nil
}

func resolveSize(req capability.ImageRequest) string {
	w, h := req.Width, req.Height
	if req.Size != "" {
		if _, err := fmt.Sscanf(req.Size, "%dx%d", &w, &h); err != nil {
			return req.Size
		}
	}
	if w <= 0 || h <= 0 {
		return seedreamDefaultSize
	}
	pixels := w * h
	if pixels >= seedreamMinPixels {
		return fmt.Sprintf("%dx%d", w, h)
	}
	scale := math.Sqrt(float64(seedreamMinPixels) / float64(pixels))
	w = int(math.Ceil(float64(w) * scale))
	h = int(math.Ceil(float64(h) * scale))
	if w%2 != 0 {
		w++
	}
	if h%2 != 0 {
		h++
	}
	return fmt.Sprintf("%dx%d", w, h)
}

func (p *SeedreamProvider) QueryImageTask(_ context.Context, taskID string) (*capability.ImageResult, error) {
	p.mu.Lock()
	r, ok := p.results[taskID]
	if ok {
		delete(p.results, taskID)
	}
	p.mu.Unlock()

	if !ok {
		return &capability.ImageResult{
			Status: "failed",
			Error:  "task not found (may have expired)",
		}, nil
	}

	return r, nil
}
