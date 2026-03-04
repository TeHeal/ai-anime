// Package provider_usage AI 用量记录（README 8.3 AI 成本控制）
package provider_usage

import (
	"context"
	"encoding/json"

	"anime_ai/pub/pkg"
	"anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
	"go.uber.org/zap"
)

// Recorder 用量记录接口，由调用方注入
type Recorder interface {
	RecordImage(ctx context.Context, projectID, userID, provider, model string, imageCount int)
	RecordVideo(ctx context.Context, projectID, userID, provider, model string, videoSeconds int)
	RecordChat(ctx context.Context, projectID, userID, provider, model string, tokenCount int)
}

// DBRecorder 基于 PostgreSQL 的实现
type DBRecorder struct {
	q      *db.Queries
	logger *zap.Logger
}

// NewDBRecorder 创建 DB 用量记录器（无 logger，错误不记录）
func NewDBRecorder(q *db.Queries) *DBRecorder {
	return &DBRecorder{q: q}
}

// NewDBRecorderWithLogger 创建带 logger 的 DB 用量记录器，记录失败时打 Warn 日志
func NewDBRecorderWithLogger(q *db.Queries, logger *zap.Logger) *DBRecorder {
	if logger == nil {
		logger = zap.NewNop()
	}
	return &DBRecorder{q: q, logger: logger}
}

// RecordImage 记录文生图用量
func (r *DBRecorder) RecordImage(ctx context.Context, projectID, userID, provider, model string, imageCount int) {
	if r == nil || r.q == nil || imageCount <= 0 {
		return
	}
	pid := pkg.StrToUUID(projectID)
	uid := pkg.StrToUUID(userID)
	_, err := r.q.CreateProviderUsage(ctx, db.CreateProviderUsageParams{
		ProjectID:    pid,
		UserID:       uid,
		OrgID:        pgtype.UUID{Valid: false},
		Provider:     provider,
		Model:        model,
		ServiceType:  "image",
		TokenCount:   0,
		ImageCount:   imageCount,
		VideoSeconds: 0,
		CostCents:    0,
		MetaJson:     json.RawMessage("{}"),
	})
	if err != nil {
		logger := r.logger
		if logger == nil {
			logger = zap.NewNop()
		}
		logger.Warn("provider_usage RecordImage 失败", zap.String("serviceType", "image"), zap.String("projectID", projectID), zap.Error(err))
	}
}

// RecordVideo 记录文生视频用量
func (r *DBRecorder) RecordVideo(ctx context.Context, projectID, userID, provider, model string, videoSeconds int) {
	if r == nil || r.q == nil || videoSeconds <= 0 {
		return
	}
	pid := pkg.StrToUUID(projectID)
	uid := pkg.StrToUUID(userID)
	_, err := r.q.CreateProviderUsage(ctx, db.CreateProviderUsageParams{
		ProjectID:    pid,
		UserID:       uid,
		OrgID:        pgtype.UUID{Valid: false},
		Provider:     provider,
		Model:        model,
		ServiceType:  "video",
		TokenCount:   0,
		ImageCount:   0,
		VideoSeconds: videoSeconds,
		CostCents:    0,
		MetaJson:     json.RawMessage("{}"),
	})
	if err != nil {
		logger := r.logger
		if logger == nil {
			logger = zap.NewNop()
		}
		logger.Warn("provider_usage RecordVideo 失败", zap.String("serviceType", "video"), zap.String("projectID", projectID), zap.Error(err))
	}
}

// RecordChat 记录对话/LLM 用量
func (r *DBRecorder) RecordChat(ctx context.Context, projectID, userID, provider, model string, tokenCount int) {
	if r == nil || r.q == nil || tokenCount <= 0 {
		return
	}
	pid := pkg.StrToUUID(projectID)
	uid := pkg.StrToUUID(userID)
	_, err := r.q.CreateProviderUsage(ctx, db.CreateProviderUsageParams{
		ProjectID:    pid,
		UserID:       uid,
		OrgID:        pgtype.UUID{Valid: false},
		Provider:     provider,
		Model:        model,
		ServiceType:  "chat",
		TokenCount:   tokenCount,
		ImageCount:   0,
		VideoSeconds: 0,
		CostCents:    0,
		MetaJson:     json.RawMessage("{}"),
	})
	if err != nil {
		logger := r.logger
		if logger == nil {
			logger = zap.NewNop()
		}
		logger.Warn("provider_usage RecordChat 失败", zap.String("serviceType", "chat"), zap.String("projectID", projectID), zap.Error(err))
	}
}
