package event_recorder

import (
	"context"

	"anime_ai/sch/db"

	"github.com/jackc/pgx/v5/pgtype"
)

// Store 事件存储接口，由 sqlc 生成的 Queries 满足
type Store interface {
	InsertProjectEvent(ctx context.Context, arg db.InsertProjectEventParams) (db.ProjectEvent, error)
	ListProjectEventsAfter(ctx context.Context, arg db.ListProjectEventsAfterParams) ([]db.ProjectEvent, error)
	ListTaskEventsAfter(ctx context.Context, arg db.ListTaskEventsAfterParams) ([]db.ProjectEvent, error)
	ListRecentProjectEvents(ctx context.Context, arg db.ListRecentProjectEventsParams) ([]db.ProjectEvent, error)
	ListUserEventsAfter(ctx context.Context, arg db.ListUserEventsAfterParams) ([]db.ProjectEvent, error)
	GetLatestProjectEventID(ctx context.Context, projectID pgtype.UUID) (int64, error)
}
