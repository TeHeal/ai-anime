// Package event_recorder 提供任务过程事件的持久化记录 + 实时广播。
// 满足 realtime.Broadcaster 接口，可无感替换 Hub 用于 Worker Handler。
package event_recorder

import (
	"context"
	"encoding/json"

	"anime_ai/pub/realtime"
	"anime_ai/sch/db"

	"github.com/jackc/pgx/v5/pgtype"
	"go.uber.org/zap"
)

// Recorder 将事件写入 project_events 表后再通过 Hub 实时推送。
type Recorder struct {
	hub   realtime.Broadcaster
	store Store
	log   *zap.Logger
}

// New 创建 EventRecorder
func New(hub realtime.Broadcaster, store Store, log *zap.Logger) *Recorder {
	return &Recorder{hub: hub, store: store, log: log.Named("event_recorder")}
}

// BroadcastTaskProgress 持久化 + 推送任务进度事件
func (r *Recorder) BroadcastTaskProgress(userID string, projectID *string, taskID string, payload interface{}) {
	r.persist(userID, projectID, taskID, "task_progress", payload)
	if r.hub != nil {
		r.hub.BroadcastTaskProgress(userID, projectID, taskID, payload)
	}
}

// BroadcastTaskComplete 持久化 + 推送任务完成事件
func (r *Recorder) BroadcastTaskComplete(userID string, projectID *string, taskID string, payload interface{}) {
	r.persist(userID, projectID, taskID, "task_complete", payload)
	if r.hub != nil {
		r.hub.BroadcastTaskComplete(userID, projectID, taskID, payload)
	}
}

// BroadcastTaskError 持久化 + 推送任务失败事件
func (r *Recorder) BroadcastTaskError(userID string, projectID *string, taskID string, payload interface{}) {
	r.persist(userID, projectID, taskID, "task_error", payload)
	if r.hub != nil {
		r.hub.BroadcastTaskError(userID, projectID, taskID, payload)
	}
}

// BroadcastResourceCreated 持久化 + 推送素材创建事件
func (r *Recorder) BroadcastResourceCreated(userID string, resourceID string, resourceType string) {
	p := map[string]any{"resource_id": resourceID, "resource_type": resourceType}
	r.persist(userID, nil, "", "resource_created", p)
	if r.hub != nil {
		r.hub.BroadcastResourceCreated(userID, resourceID, resourceType)
	}
}

// RecordReviewEvent 记录审核生命周期事件（不经过 Hub 的通用任务推送）
func (r *Recorder) RecordReviewEvent(userID string, projectID *string, taskID string, eventType string, payload interface{}) {
	r.persist(userID, projectID, taskID, eventType, payload)
}

func (r *Recorder) persist(userID string, projectID *string, taskID string, eventType string, payload interface{}) {
	if r.store == nil {
		return
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		r.log.Warn("序列化事件 payload 失败", zap.String("event_type", eventType), zap.Error(err))
		return
	}

	arg := db.InsertProjectEventParams{
		UserID:    uuidFromStr(userID),
		EventType: eventType,
		Payload:   payloadBytes,
	}
	if projectID != nil && *projectID != "" {
		arg.ProjectID = uuidFromStr(*projectID)
	}
	if taskID != "" {
		arg.TaskID = pgtype.Text{String: taskID, Valid: true}
	}

	// 从 payload 中提取 target_type / target_id 用于结构化查询
	var m map[string]interface{}
	if json.Unmarshal(payloadBytes, &m) == nil {
		if t, ok := m["type"].(string); ok {
			arg.TargetType = pgtype.Text{String: t, Valid: true}
		}
		if id, ok := m["shot_image_id"].(string); ok && id != "" {
			arg.TargetID = pgtype.Text{String: id, Valid: true}
		} else if id, ok := m["shot_video_id"].(string); ok && id != "" {
			arg.TargetID = pgtype.Text{String: id, Valid: true}
		} else if id, ok := m["resourceId"].(string); ok && id != "" {
			arg.TargetID = pgtype.Text{String: id, Valid: true}
		}
	}

	if _, err := r.store.InsertProjectEvent(context.Background(), arg); err != nil {
		r.log.Warn("持久化事件失败", zap.String("event_type", eventType), zap.Error(err))
	}
}

func uuidFromStr(s string) pgtype.UUID {
	var u pgtype.UUID
	if err := u.Scan(s); err != nil {
		return pgtype.UUID{}
	}
	return u
}
