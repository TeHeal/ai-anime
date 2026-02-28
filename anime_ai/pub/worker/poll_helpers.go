// Package worker 提供轮询与下载等通用辅助函数。
package worker

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/storage"
	"go.uber.org/zap"
)

// PollResult 轮询查询返回的结果
type PollResult struct {
	Status    string                 // "completed", "failed" 或 pending
	ResultURL string                 // 完成时的首个 URL
	Error     string                 // 失败时的错误信息
	Extra     map[string]interface{} // 扩展数据，如 urls
}

// PollConfig 轮询配置
type PollConfig struct {
	MaxAttempts  int
	Interval     time.Duration
	BaseProgress int
	Label        string
}

// ProgressFn 进度回调，用于推送任务进度（如 RealtimeHub）
type ProgressFn func(progress int, status string)

// PollUntilDone 轮询 queryFn 直到返回 completed/failed 或 context 取消。
// progressFn 可选，用于推送进度（如 BroadcastTaskProgress）。
func PollUntilDone(
	ctx context.Context,
	log *zap.Logger,
	taskID string,
	cfg PollConfig,
	queryFn func(ctx context.Context) (*PollResult, error),
	progressFn ProgressFn,
) (*PollResult, error) {
	for i := 0; i < cfg.MaxAttempts; i++ {
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		case <-time.After(cfg.Interval):
		}

		result, err := queryFn(ctx)
		if err != nil {
			log.Warn("轮询查询失败",
				zap.String("task_id", taskID),
				zap.String("type", cfg.Label),
				zap.Error(err))
			continue
		}

		switch result.Status {
		case "completed":
			return result, nil
		case "failed":
			return result, nil
		default:
			progress := cfg.BaseProgress + i*60/cfg.MaxAttempts
			if progress > 95 {
				progress = 95
			}
			if progressFn != nil {
				progressFn(progress, "running")
			}
		}
	}

	return nil, fmt.Errorf("%s 生成轮询超时", cfg.Label)
}

// DownloadToLocal 将远程 URL 下载到本地存储，最多重试 3 次。
// category 为存储路径前缀，如 "resource/generated"；defaultExt 如 ".png"。
func DownloadToLocal(
	ctx context.Context,
	log *zap.Logger,
	store storage.Storage,
	remoteURL, taskID, category, defaultExt string,
) (string, error) {
	if store == nil {
		return "", fmt.Errorf("storage 未配置")
	}

	var lastErr error
	for attempt := 0; attempt < 3; attempt++ {
		if attempt > 0 {
			time.Sleep(time.Duration(attempt) * 2 * time.Second)
		}

		localURL, err := doDownload(ctx, store, remoteURL, taskID, category, defaultExt)
		if err == nil {
			return localURL, nil
		}
		lastErr = err
		log.Warn("下载尝试失败",
			zap.Int("attempt", attempt+1),
			zap.String("task_id", taskID),
			zap.Error(err))
	}
	return "", fmt.Errorf("下载失败，已重试 3 次: %w", lastErr)
}

func doDownload(
	ctx context.Context,
	store storage.Storage,
	remoteURL, taskID, category, defaultExt string,
) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, remoteURL, nil)
	if err != nil {
		return "", fmt.Errorf("创建请求: %w", err)
	}

	client := &http.Client{Timeout: 60 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("下载: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("下载返回状态 %d", resp.StatusCode)
	}

	ext := defaultExt
	ct := resp.Header.Get("Content-Type")
	if detected := detectExtension(ct); detected != "" {
		ext = detected
	}

	storagePath := fmt.Sprintf("%s/%s%s", category, taskID, ext)
	localURL, err := store.Put(ctx, storagePath, resp.Body, ct)
	if err != nil {
		return "", fmt.Errorf("存储写入: %w", err)
	}

	return localURL, nil
}

func detectExtension(contentType string) string {
	switch {
	case strings.Contains(contentType, "jpeg"):
		return ".jpg"
	case strings.Contains(contentType, "webp"):
		return ".webp"
	case strings.Contains(contentType, "gif"):
		return ".gif"
	case strings.Contains(contentType, "bmp"):
		return ".bmp"
	case strings.Contains(contentType, "svg"):
		return ".svg"
	case strings.Contains(contentType, "png"):
		return ".png"
	case strings.Contains(contentType, "wav"):
		return ".wav"
	case strings.Contains(contentType, "ogg"):
		return ".ogg"
	case strings.Contains(contentType, "flac"):
		return ".flac"
	case strings.Contains(contentType, "m4a"), strings.Contains(contentType, "mp4") && !strings.Contains(contentType, "video"):
		return ".m4a"
	case strings.Contains(contentType, "mpeg") && !strings.Contains(contentType, "video"):
		return ".mp3"
	case strings.Contains(contentType, "video/mp4"):
		return ".mp4"
	}
	return ""
}
