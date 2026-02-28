package composite

import (
	"context"
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// Store 成片任务数据访问接口
type Store interface {
	Create(ctx context.Context, projectID, episodeID, taskID, status string, configJSON []byte) (*Task, error)
	FindByID(ctx context.Context, id string) (*Task, error)
	FindByTaskID(ctx context.Context, taskID string) (*Task, error)
	ListByProject(ctx context.Context, projectID string) ([]Task, error)
	ListByEpisode(ctx context.Context, episodeID string) ([]Task, error)
	UpdateStatus(ctx context.Context, id, status, outputURL, errorMsg string) error
	UpdateTaskID(ctx context.Context, id, taskID string) error
}

// DBStore 基于 sqlc 的实现
type DBStore struct {
	q *db.Queries
}

// NewDBStore 创建 DBStore
func NewDBStore(q *db.Queries) *DBStore {
	return &DBStore{q: q}
}

func dbToTask(d db.CompositeTask) Task {
	t := Task{
		ID:        pkg.UUIDString(d.ID),
		ProjectID: pkg.UUIDString(d.ProjectID),
		TaskID:    textStr(d.TaskID),
		Status:    d.Status,
		OutputURL:  textStr(d.OutputUrl),
		ErrorMsg:   textStr(d.ErrorMsg),
	}
	if d.EpisodeID.Valid {
		t.EpisodeID = pkg.UUIDString(d.EpisodeID)
	}
	if len(d.ConfigJson) > 0 {
		t.ConfigJSON = string(d.ConfigJson)
	}
	return t
}

func textStr(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

// Create 创建成片任务
func (s *DBStore) Create(ctx context.Context, projectID, episodeID, taskID, status string, configJSON []byte) (*Task, error) {
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, pkg.ErrBadRequest
	}
	arg := db.CreateCompositeTaskParams{
		ProjectID:  pid,
		TaskID:     pgtype.Text{String: taskID, Valid: taskID != ""},
		Status:     status,
		ConfigJson: configJSON,
	}
	if episodeID != "" {
		eid := pkg.ParseUUID(episodeID)
		if eid.Valid {
			arg.EpisodeID = eid
		}
	}
	out, err := s.q.CreateCompositeTask(ctx, arg)
	if err != nil {
		return nil, err
	}
	t := dbToTask(out)
	return &t, nil
}

// FindByID 按 ID 查询
func (s *DBStore) FindByID(ctx context.Context, id string) (*Task, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	out, err := s.q.GetCompositeTaskByID(ctx, uid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pkg.ErrNotFound
		}
		return nil, err
	}
	t := dbToTask(out)
	return &t, nil
}

// FindByTaskID 按 Asynq task_id 查询
func (s *DBStore) FindByTaskID(ctx context.Context, taskID string) (*Task, error) {
	tid := pgtype.Text{String: taskID, Valid: taskID != ""}
	out, err := s.q.GetCompositeTaskByTaskID(ctx, tid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pkg.ErrNotFound
		}
		return nil, err
	}
	t := dbToTask(out)
	return &t, nil
}

// ListByProject 按项目列出
func (s *DBStore) ListByProject(ctx context.Context, projectID string) ([]Task, error) {
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, nil
	}
	list, err := s.q.ListCompositeTasksByProject(ctx, pid)
	if err != nil {
		return nil, err
	}
	out := make([]Task, len(list))
	for i := range list {
		out[i] = dbToTask(list[i])
	}
	return out, nil
}

// ListByEpisode 按集列出
func (s *DBStore) ListByEpisode(ctx context.Context, episodeID string) ([]Task, error) {
	eid := pkg.ParseUUID(episodeID)
	if !eid.Valid {
		return nil, nil
	}
	list, err := s.q.ListCompositeTasksByEpisode(ctx, eid)
	if err != nil {
		return nil, err
	}
	out := make([]Task, len(list))
	for i := range list {
		out[i] = dbToTask(list[i])
	}
	return out, nil
}

// UpdateStatus 更新状态
func (s *DBStore) UpdateStatus(ctx context.Context, id, status, outputURL, errorMsg string) error {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateCompositeTaskStatusParams{
		ID:        uid,
		Status:    pgtype.Text{String: status, Valid: status != ""},
		OutputUrl: pgtype.Text{String: outputURL, Valid: outputURL != ""},
		ErrorMsg:  pgtype.Text{String: errorMsg, Valid: errorMsg != ""},
	}
	_, err := s.q.UpdateCompositeTaskStatus(ctx, arg)
	return err
}

// UpdateTaskID 更新 Asynq task_id
func (s *DBStore) UpdateTaskID(ctx context.Context, id, taskID string) error {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return s.q.UpdateCompositeTaskID(ctx, db.UpdateCompositeTaskIDParams{
		ID:     uid,
		TaskID: pgtype.Text{String: taskID, Valid: taskID != ""},
	})
}
