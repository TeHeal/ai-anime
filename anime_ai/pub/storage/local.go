package storage

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// LocalStorage 本地文件系统存储实现
type LocalStorage struct {
	root    string
	baseURL string
}

// NewLocalStorage 创建本地存储实例
func NewLocalStorage(root, baseURL string) *LocalStorage {
	// 确保 baseURL 不以 / 结尾，便于拼接
	baseURL = strings.TrimSuffix(baseURL, "/")
	return &LocalStorage{root: root, baseURL: baseURL}
}

// Put 写入文件到本地目录
func (s *LocalStorage) Put(_ context.Context, path string, data io.Reader, _ string) (string, error) {
	fullPath := filepath.Join(s.root, path)

	if err := os.MkdirAll(filepath.Dir(fullPath), 0o755); err != nil {
		return "", fmt.Errorf("创建目录失败: %w", err)
	}

	f, err := os.Create(fullPath)
	if err != nil {
		return "", fmt.Errorf("创建文件失败: %w", err)
	}
	defer f.Close()

	if _, err := io.Copy(f, data); err != nil {
		return "", fmt.Errorf("写入文件失败: %w", err)
	}

	return s.url(path), nil
}

// Get 从本地读取文件
func (s *LocalStorage) Get(_ context.Context, path string) (io.ReadCloser, error) {
	fullPath := filepath.Join(s.root, path)
	return os.Open(fullPath)
}

// Delete 删除本地文件
func (s *LocalStorage) Delete(_ context.Context, path string) error {
	fullPath := filepath.Join(s.root, path)
	return os.Remove(fullPath)
}

// Presign 本地存储不支持预签名
func (s *LocalStorage) Presign(_ context.Context, _ string, _ string, _ time.Duration) (string, error) {
	return "", fmt.Errorf("本地存储不支持 Presign")
}

// BaseURL 返回基础 URL
func (s *LocalStorage) BaseURL() string {
	return s.baseURL
}

// Exists 检查文件是否存在
func (s *LocalStorage) Exists(_ context.Context, path string) bool {
	fullPath := filepath.Join(s.root, path)
	_, err := os.Stat(fullPath)
	return err == nil
}

func (s *LocalStorage) url(path string) string {
	if s.baseURL == "" {
		return "/" + path
	}
	return s.baseURL + "/" + path
}
