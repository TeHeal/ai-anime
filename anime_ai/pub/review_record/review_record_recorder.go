// Package review_record 审核记录写入（README 2.2 审核闭环、状态机、反馈给生产 AI）
package review_record

import (
	"context"
	"encoding/json"

	"anime_ai/pub/pkg"
	"anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
	"go.uber.org/zap"
)

// Recorder 审核记录接口，由调用方注入
type Recorder interface {
	Record(ctx context.Context, targetType, targetID, projectID, reviewerID, reviewerType, action, comment string, feedback map[string]interface{})
}

// DBRecorder 基于 PostgreSQL 的实现
type DBRecorder struct {
	q      *db.Queries
	logger *zap.Logger
}

// NewDBRecorder 创建 DB 审核记录器（无 logger，错误不记录）
func NewDBRecorder(q *db.Queries) *DBRecorder {
	return &DBRecorder{q: q}
}

// NewDBRecorderWithLogger 创建带 logger 的 DB 审核记录器，记录失败时打 Warn 日志
func NewDBRecorderWithLogger(q *db.Queries, logger *zap.Logger) *DBRecorder {
	if logger == nil {
		logger = zap.NewNop()
	}
	return &DBRecorder{q: q, logger: logger}
}

// Record 写入审核记录
func (r *DBRecorder) Record(ctx context.Context, targetType, targetID, projectID, reviewerID, reviewerType, action, comment string, feedback map[string]interface{}) {
	if r == nil || r.q == nil || targetType == "" || targetID == "" || projectID == "" || action == "" {
		return
	}
	tid := pkg.StrToUUID(targetID)
	pid := pkg.StrToUUID(projectID)
	rid := pkg.StrToUUID(reviewerID)
	if !tid.Valid || !pid.Valid {
		return
	}
	if reviewerType == "" {
		reviewerType = "human"
	}
	var fb interface{} = json.RawMessage("{}")
	if len(feedback) > 0 {
		b, _ := json.Marshal(feedback)
		fb = json.RawMessage(b)
	}
	_, err := r.q.CreateReviewRecord(ctx, db.CreateReviewRecordParams{
		TargetType:   targetType,
		TargetID:     tid,
		ProjectID:    pid,
		ReviewerID:   rid,
		ReviewerType: reviewerType,
		Action:       action,
		Comment:      pgtype.Text{String: comment, Valid: comment != ""},
		FeedbackJson: fb,
	})
	if err != nil {
		logger := r.logger
		if logger == nil {
			logger = zap.NewNop()
		}
		logger.Warn("review_record Record 失败", zap.String("targetType", targetType), zap.String("projectID", projectID), zap.Error(err))
	}
}
