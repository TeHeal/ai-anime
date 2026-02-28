// Package worker 占位任务 Handler，后续由 pub 编排注入真实实现。
package worker

import (
	"context"
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// placeholderHandler 通用占位 handler：解析 payload、打日志、返回 nil。
// 后续阶段将替换为真实业务逻辑（需 TaskRepo、Router、Storage 等依赖）。
func placeholderHandler(log *zap.Logger, taskType string) func(context.Context, *asynq.Task) error {
	return func(ctx context.Context, t *asynq.Task) error {
		var payload map[string]interface{}
		_ = json.Unmarshal(t.Payload(), &payload)
		log.Info("placeholder handler received task",
			zap.String("type", taskType),
			zap.Any("payload", payload),
		)
		return nil
	}
}

// SetupMux 注册所有任务类型的 handler，返回 asynq.ServeMux。
// 无 deps 时使用占位 handler。
func SetupMux(log *zap.Logger) *asynq.ServeMux {
	return SetupMuxWithDeps(log, nil)
}

// MuxDeps 可选依赖，用于注册真实 handler；nil 字段使用占位
type MuxDeps struct {
	ImageHandler   *ImageTaskHandler
	ExportHandler  *ExportTaskHandler
	PackageHandler *PackageTaskHandler
}

// SetupMuxWithDeps 注册任务 handler，deps 非空时注入真实实现
func SetupMuxWithDeps(log *zap.Logger, deps *MuxDeps) *asynq.ServeMux {
	mux := asynq.NewServeMux()
	l := log.Named("worker")

	if deps != nil && deps.ImageHandler != nil {
		RegisterImageHandler(mux, deps.ImageHandler)
	} else {
		mux.HandleFunc(tasktypes.TypeImageGeneration, placeholderHandler(l, tasktypes.TypeImageGeneration))
	}

	if deps != nil && deps.ExportHandler != nil {
		RegisterExportHandler(mux, deps.ExportHandler)
	} else {
		mux.HandleFunc(tasktypes.TypeExport, placeholderHandler(l, tasktypes.TypeExport))
	}

	if deps != nil && deps.PackageHandler != nil {
		RegisterPackageHandler(mux, deps.PackageHandler)
	} else {
		mux.HandleFunc(tasktypes.TypePackage, placeholderHandler(l, tasktypes.TypePackage))
	}

	mux.HandleFunc(tasktypes.TypeVideoGeneration, placeholderHandler(l, tasktypes.TypeVideoGeneration))
	mux.HandleFunc(tasktypes.TypeCharacterGeneration, placeholderHandler(l, tasktypes.TypeCharacterGeneration))
	mux.HandleFunc(tasktypes.TypeTTS, placeholderHandler(l, tasktypes.TypeTTS))
	mux.HandleFunc(tasktypes.TypeVoiceClone, placeholderHandler(l, tasktypes.TypeVoiceClone))
	mux.HandleFunc(tasktypes.TypeMusicGeneration, placeholderHandler(l, tasktypes.TypeMusicGeneration))
	mux.HandleFunc(tasktypes.TypeScriptParse, placeholderHandler(l, tasktypes.TypeScriptParse))
	mux.HandleFunc(tasktypes.TypeStoryboardGenerate, placeholderHandler(l, tasktypes.TypeStoryboardGenerate))

	return mux
}
