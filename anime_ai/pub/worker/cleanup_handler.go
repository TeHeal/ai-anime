package worker

import (
	"context"
	"os"
	"path/filepath"
	"time"

	"go.uber.org/zap"
)

// CleanupConfig 文件清理配置（§8.6 文件清理策略）
type CleanupConfig struct {
	LocalRoot     string        // 本地文件根目录
	RetentionDays int           // 保留天数（过期后清理）
	Enabled       bool          // 是否启用清理
	Interval      time.Duration // 扫描间隔
}

// FileCleanupWorker 文件清理工作器
type FileCleanupWorker struct {
	cfg    CleanupConfig
	logger *zap.Logger
}

// NewFileCleanupWorker 创建文件清理工作器
func NewFileCleanupWorker(cfg CleanupConfig, logger *zap.Logger) *FileCleanupWorker {
	return &FileCleanupWorker{cfg: cfg, logger: logger}
}

// Start 启动定期清理任务
func (w *FileCleanupWorker) Start(ctx context.Context) {
	if !w.cfg.Enabled || w.cfg.LocalRoot == "" {
		w.logger.Info("文件清理未启用")
		return
	}

	ticker := time.NewTicker(w.cfg.Interval)
	defer ticker.Stop()

	w.logger.Info("文件清理工作器已启动",
		zap.String("root", w.cfg.LocalRoot),
		zap.Int("retention_days", w.cfg.RetentionDays),
	)

	for {
		select {
		case <-ctx.Done():
			w.logger.Info("文件清理工作器已停止")
			return
		case <-ticker.C:
			w.cleanup()
		}
	}
}

// cleanup 执行一次清理扫描
func (w *FileCleanupWorker) cleanup() {
	cutoff := time.Now().AddDate(0, 0, -w.cfg.RetentionDays)
	var cleaned int

	err := filepath.Walk(w.cfg.LocalRoot, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		if info.IsDir() {
			return nil
		}
		if info.ModTime().Before(cutoff) {
			if removeErr := os.Remove(path); removeErr == nil {
				cleaned++
			} else {
				w.logger.Warn("删除过期文件失败", zap.String("path", path), zap.Error(removeErr))
			}
		}
		return nil
	})

	if err != nil {
		w.logger.Error("文件清理扫描失败", zap.Error(err))
	}
	if cleaned > 0 {
		w.logger.Info("文件清理完成", zap.Int("cleaned", cleaned))
	}
}
