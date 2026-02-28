package storage

import (
	"context"
	"fmt"
	"io"
	"strings"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/config"
	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// S3Storage S3 兼容存储实现（支持 AWS S3、阿里云 OSS、MinIO 等）
type S3Storage struct {
	client  *s3.Client
	bucket  string
	baseURL string
}

// NewS3Storage 根据配置创建 S3 存储实例
func NewS3Storage(cfg *config.StorageConfig) (*S3Storage, error) {
	if cfg.Bucket == "" {
		return nil, fmt.Errorf("S3/OSS 存储需要配置 bucket")
	}
	region := cfg.Region
	if region == "" {
		region = "us-east-1"
	}

	loadOpts := []func(*awsconfig.LoadOptions) error{
		awsconfig.WithRegion(region),
	}
	if cfg.AccessKey != "" && cfg.SecretKey != "" {
		loadOpts = append(loadOpts, awsconfig.WithCredentialsProvider(
			credentials.NewStaticCredentialsProvider(cfg.AccessKey, cfg.SecretKey, ""),
		))
	}

	awsCfg, err := awsconfig.LoadDefaultConfig(context.Background(), loadOpts...)
	if err != nil {
		return nil, fmt.Errorf("加载 AWS 配置失败: %w", err)
	}

	s3Opts := []func(*s3.Options){
		func(o *s3.Options) {
			o.UsePathStyle = true
		},
	}
	if cfg.Endpoint != "" {
		ep := cfg.Endpoint
		if !strings.HasPrefix(ep, "http") {
			ep = "https://" + ep
		}
		s3Opts = append(s3Opts, func(o *s3.Options) {
			o.BaseEndpoint = aws.String(ep)
		})
	}

	client := s3.NewFromConfig(awsCfg, s3Opts...)

	baseURL := cfg.BaseURL
	if baseURL == "" && cfg.Endpoint != "" {
		baseURL = strings.TrimSuffix(cfg.Endpoint, "/") + "/" + cfg.Bucket
	}

	return &S3Storage{
		client:  client,
		bucket:  cfg.Bucket,
		baseURL: strings.TrimSuffix(baseURL, "/"),
	}, nil
}

// Put 上传文件到 S3
func (s *S3Storage) Put(ctx context.Context, path string, data io.Reader, contentType string) (string, error) {
	_, err := s.client.PutObject(ctx, &s3.PutObjectInput{
		Bucket:      aws.String(s.bucket),
		Key:         aws.String(path),
		Body:        data,
		ContentType: aws.String(contentType),
	})
	if err != nil {
		return "", fmt.Errorf("S3 PutObject 失败: %w", err)
	}
	return s.url(path), nil
}

// Get 从 S3 下载文件
func (s *S3Storage) Get(ctx context.Context, path string) (io.ReadCloser, error) {
	out, err := s.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s.bucket),
		Key:    aws.String(path),
	})
	if err != nil {
		return nil, fmt.Errorf("S3 GetObject 失败: %w", err)
	}
	return out.Body, nil
}

// Delete 从 S3 删除文件
func (s *S3Storage) Delete(ctx context.Context, path string) error {
	_, err := s.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(s.bucket),
		Key:    aws.String(path),
	})
	if err != nil {
		return fmt.Errorf("S3 DeleteObject 失败: %w", err)
	}
	return nil
}

// Presign 生成预签名 URL
func (s *S3Storage) Presign(ctx context.Context, path string, method string, expiry time.Duration) (string, error) {
	presignClient := s3.NewPresignClient(s.client)
	switch strings.ToUpper(method) {
	case "GET":
		req, err := presignClient.PresignGetObject(ctx, &s3.GetObjectInput{
			Bucket: aws.String(s.bucket),
			Key:    aws.String(path),
		}, s3.WithPresignExpires(expiry))
		if err != nil {
			return "", fmt.Errorf("Presign Get 失败: %w", err)
		}
		return req.URL, nil
	case "PUT":
		req, err := presignClient.PresignPutObject(ctx, &s3.PutObjectInput{
			Bucket: aws.String(s.bucket),
			Key:    aws.String(path),
		}, s3.WithPresignExpires(expiry))
		if err != nil {
			return "", fmt.Errorf("Presign Put 失败: %w", err)
		}
		return req.URL, nil
	default:
		return "", fmt.Errorf("不支持的 Presign method: %s", method)
	}
}

// BaseURL 返回基础 URL
func (s *S3Storage) BaseURL() string {
	return s.baseURL
}

// Exists 检查对象是否存在
func (s *S3Storage) Exists(ctx context.Context, path string) bool {
	_, err := s.client.HeadObject(ctx, &s3.HeadObjectInput{
		Bucket: aws.String(s.bucket),
		Key:    aws.String(path),
	})
	return err == nil
}

func (s *S3Storage) url(path string) string {
	if s.baseURL == "" {
		return "/" + path
	}
	return s.baseURL + "/" + path
}
