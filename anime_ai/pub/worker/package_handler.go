// Package worker 按集打包任务 Handler（README 2.7 生成物下载，可配置）
package worker

import (
	"archive/zip"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/module/package_task"
	"github.com/TeHeal/ai-anime/anime_ai/pub/storage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// PackageTaskPayload 按集打包任务载荷
type PackageTaskPayload struct {
	PackageTaskID string `json:"package_task_id"`
	ProjectID     string `json:"project_id"`
	EpisodeID     string `json:"episode_id"`
	UserID        string `json:"user_id"`
	Config        struct {
		IncludeShotImages bool `json:"include_shot_images"`
		IncludeVoices     bool `json:"include_voices"`
		IncludeShots      bool `json:"include_shots"`
		IncludeFinal      bool `json:"include_final"`
	} `json:"config"`
}

// PackageTaskDeps 按集打包 Handler 依赖
type PackageTaskDeps struct {
	PackageStore package_task.Store
	Storage      storage.Storage
}

// PackageTaskHandler 按集打包任务 Handler
type PackageTaskHandler struct {
	log  *zap.Logger
	deps PackageTaskDeps
}

// NewPackageTaskHandler 创建按集打包 Handler
func NewPackageTaskHandler(log *zap.Logger, deps PackageTaskDeps) *PackageTaskHandler {
	return &PackageTaskHandler{
		log:  log.Named("package_worker"),
		deps: deps,
	}
}

// Handle 处理按集打包任务
func (h *PackageTaskHandler) Handle(ctx context.Context, t *asynq.Task) error {
	var payload PackageTaskPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("解析 payload: %w", err)
	}

	h.log.Info("处理按集打包任务",
		zap.String("package_task_id", payload.PackageTaskID),
		zap.String("episode_id", payload.EpisodeID),
	)

	if h.deps.PackageStore == nil {
		h.log.Warn("PackageStore 未配置，跳过")
		return nil
	}

	_ = h.deps.PackageStore.UpdateStatus(ctx, payload.PackageTaskID, package_task.StatusPackaging, "", "")

	// 占位：实际需根据 Config 收集镜图/镜头/成片，打包 ZIP
	// 当前创建空 ZIP 占位
	outputURL := ""
	if h.deps.Storage != nil {
		buf := new(bytes.Buffer)
		w := zip.NewWriter(buf)
		readme, _ := w.Create("README.txt")
		_, _ = readme.Write([]byte("按集打包占位，后续接入镜图/镜头/成片收集逻辑"))
		_ = w.Close()
		path := fmt.Sprintf("projects/%s/episodes/%s/package_%s.zip", payload.ProjectID, payload.EpisodeID, payload.PackageTaskID[:8])
		url, err := h.deps.Storage.Put(ctx, path, bytes.NewReader(buf.Bytes()), "application/zip")
		if err == nil {
			outputURL = url
		}
	}

	select {
	case <-time.After(1 * time.Second):
	case <-ctx.Done():
		_ = h.deps.PackageStore.UpdateStatus(ctx, payload.PackageTaskID, package_task.StatusFailed, "", "任务取消")
		return ctx.Err()
	}

	_ = h.deps.PackageStore.UpdateStatus(ctx, payload.PackageTaskID, package_task.StatusDone, outputURL, "")

	h.log.Info("按集打包任务完成",
		zap.String("package_task_id", payload.PackageTaskID),
		zap.String("output_url", outputURL),
	)
	return nil
}

// RegisterPackageHandler 注册按集打包 Handler
func RegisterPackageHandler(mux *asynq.ServeMux, h *PackageTaskHandler) {
	mux.HandleFunc(tasktypes.TypePackage, h.Handle)
}
