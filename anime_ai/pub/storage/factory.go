package storage

import (
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/config"
)

// NewFromConfig 根据 StorageConfig 创建 Storage 实例
// driver=local 使用本地存储；driver=s3 或 oss 使用 S3 兼容存储（需配置 endpoint、bucket 等）
func NewFromConfig(cfg *config.StorageConfig) (Storage, error) {
	switch cfg.Driver {
	case "local":
		return NewLocalStorage(cfg.LocalRoot, cfg.BaseURL), nil
	case "s3", "oss":
		return NewS3Storage(cfg)
	default:
		return nil, fmt.Errorf("不支持的存储驱动: %s，支持 local、s3、oss", cfg.Driver)
	}
}
