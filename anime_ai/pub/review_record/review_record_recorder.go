// Package review_record 审核记录写入（README 2.2 审核闭环、状态机、反馈给生产 AI）
package review_record

import (
	"context"
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Recorder 审核记录接口，由调用方注入
type Recorder interface {
	Record(ctx context.Context, targetType, targetID, projectID, reviewerID, reviewerType, action, comment string, feedback map[string]interface{})
}

// DBRecorder 基于 PostgreSQL 的实现
type DBRecorder struct {
	q *db.Queries
}

// NewDBRecorder 创建 DB 审核记录器
func NewDBRecorder(q *db.Queries) *DBRecorder {
	return &DBRecorder{q: q}
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
		_ = err
	}
}
