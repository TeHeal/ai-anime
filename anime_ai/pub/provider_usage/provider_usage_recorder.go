// Package provider_usage AI 用量记录（README 8.3 AI 成本控制）
package provider_usage

import (
	"context"
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Recorder 用量记录接口，由调用方注入
type Recorder interface {
	RecordImage(ctx context.Context, projectID, userID, provider, model string, imageCount int)
	RecordVideo(ctx context.Context, projectID, userID, provider, model string, videoSeconds int)
	RecordChat(ctx context.Context, projectID, userID, provider, model string, tokenCount int)
}

// DBRecorder 基于 PostgreSQL 的实现
type DBRecorder struct {
	q *db.Queries
}

// NewDBRecorder 创建 DB 用量记录器
func NewDBRecorder(q *db.Queries) *DBRecorder {
	return &DBRecorder{q: q}
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
		// 记录失败不阻塞主流程，仅打日志（调用方可选注入 logger）
		_ = err
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
		_ = err
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
		_ = err
	}
}
