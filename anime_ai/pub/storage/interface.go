package storage

import (
	"context"
	"io"
	"time"
)

// Storage 文件存储接口，支持本地与 S3 兼容后端
type Storage interface {
	// Put 写入文件，返回可访问的 URL
	Put(ctx context.Context, path string, data io.Reader, contentType string) (url string, err error)
	// Get 读取文件内容
	Get(ctx context.Context, path string) (io.ReadCloser, error)
	// Delete 删除文件
	Delete(ctx context.Context, path string) error
	// Presign 生成预签名 URL（本地存储不支持，返回错误）
	Presign(ctx context.Context, path string, method string, expiry time.Duration) (string, error)
	// BaseURL 返回存储的基础 URL 前缀
	BaseURL() string
	// Exists 检查文件是否存在
	Exists(ctx context.Context, path string) bool
}
