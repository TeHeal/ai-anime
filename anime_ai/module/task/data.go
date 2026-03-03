package task

import (
	"context"
	"encoding/json"
	"time"

	"anime_ai/pub/pkg"
	"anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Data 任务数据访问接口
type Data interface {
	Create(ctx context.Context, arg CreateParams) (*TaskDTO, error)
	GetByID(ctx context.Context, id string) (*TaskDTO, error)
	ListByUser(ctx context.Context, userID string, limit, offset int32) ([]*TaskDTO, error)
	ListByProject(ctx context.Context, projectID string, limit, offset int32) ([]*TaskDTO, error)
	ListByProjectAndType(ctx context.Context, projectID, typ string, limit, offset int32) ([]*TaskDTO, error)
	ListByProjectAndStatus(ctx context.Context, projectID, status string, limit, offset int32) ([]*TaskDTO, error)
	ListByProjectTypeAndStatus(ctx context.Context, projectID, typ, status string, limit, offset int32) ([]*TaskDTO, error)
	ListByIDs(ctx context.Context, ids []string) ([]*TaskDTO, error)
	UpdateStatus(ctx context.Context, id, status string, errorMsg *string, startedAt, completedAt *time.Time) (*TaskDTO, error)
	UpdateProgress(ctx context.Context, id string, progress int32) (*TaskDTO, error)
	UpdateResult(ctx context.Context, id string, result json.RawMessage) (*TaskDTO, error)
	Cancel(ctx context.Context, id string) (*TaskDTO, error)
	BatchCancel(ctx context.Context, ids []string) error
}

// CreateParams 创建参数
type CreateParams struct {
	ProjectID   string
	UserID      string
	Type        string
	Status      string
	Title       string
	Description string
	Config      json.RawMessage
}

// TaskDTO 任务 DTO（供 Handler/Service 使用）
type TaskDTO struct {
	ID          string          `json:"id"`
	CreatedAt   time.Time       `json:"createdAt"`
	UpdatedAt   time.Time       `json:"updatedAt"`
	ProjectID   string          `json:"projectId"`
	UserID      string          `json:"userId"`
	Type        string          `json:"type"`
	Status      string          `json:"status"`
	Progress    int             `json:"progress"`
	Title       string          `json:"title"`
	Description string          `json:"description,omitempty"`
	ConfigJSON  json.RawMessage `json:"configJson,omitempty"`
	ResultJSON  json.RawMessage `json:"resultJson,omitempty"`
	ErrorMsg    string          `json:"error,omitempty"`
	StartedAt   *time.Time      `json:"startedAt,omitempty"`
	CompletedAt *time.Time      `json:"completedAt,omitempty"`
	LockedBy    string          `json:"lockedBy,omitempty"`
	LockedAt    *time.Time      `json:"lockedAt,omitempty"`
}

// IsFinished 任务是否已结束
func (t *TaskDTO) IsFinished() bool {
	return t.Status == "completed" || t.Status == "failed" || t.Status == "cancelled"
}

// DBData 基于 sqlc 的 PostgreSQL 实现
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData
func NewDBData(q *db.Queries) *DBData {
	return &DBData{q: q}
}

func (d *DBData) Create(ctx context.Context, arg CreateParams) (*TaskDTO, error) {
	pid := pkg.ParseUUID(arg.ProjectID)
	uid := pkg.ParseUUID(arg.UserID)
	if !pid.Valid || !uid.Valid {
		return nil, pkg.NewBizError("无效的 project_id 或 user_id")
	}
	status := arg.Status
	if status == "" {
		status = "pending"
	}
	cfg := arg.Config
	if cfg == nil {
		cfg = []byte("{}")
	}
	row, err := d.q.CreateTask(ctx, db.CreateTaskParams{
		ProjectID:   pid,
		UserID:      uid,
		Type:        arg.Type,
		Status:      status,
		Title:       arg.Title,
		Description: arg.Description,
		ConfigJson:  cfg,
	})
	if err != nil {
		return nil, err
	}
	return dbTaskToDTO(&row), nil
}

func (d *DBData) GetByID(ctx context.Context, id string) (*TaskDTO, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.GetTaskByID(ctx, uid)
	if err != nil {
		return nil, err
	}
	return dbTaskToDTO(&row), nil
}

func (d *DBData) ListByUser(ctx context.Context, userID string, limit, offset int32) ([]*TaskDTO, error) {
	uid := pkg.ParseUUID(userID)
	if !uid.Valid {
		return nil, nil
	}
	rows, err := d.q.ListTasksByUser(ctx, db.ListTasksByUserParams{
		UserID: uid, Limit: limit, Offset: offset,
	})
	if err != nil {
		return nil, err
	}
	return dbTasksToDTO(rows), nil
}

func (d *DBData) ListByProject(ctx context.Context, projectID string, limit, offset int32) ([]*TaskDTO, error) {
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, pkg.NewBizError("无效的 project_id")
	}
	rows, err := d.q.ListTasksByProject(ctx, db.ListTasksByProjectParams{
		ProjectID: pid, Limit: limit, Offset: offset,
	})
	if err != nil {
		return nil, err
	}
	return dbTasksToDTO(rows), nil
}

func (d *DBData) ListByProjectAndType(ctx context.Context, projectID, typ string, limit, offset int32) ([]*TaskDTO, error) {
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, pkg.NewBizError("无效的 project_id")
	}
	rows, err := d.q.ListTasksByProjectAndType(ctx, db.ListTasksByProjectAndTypeParams{
		ProjectID: pid, Type: typ, Limit: limit, Offset: offset,
	})
	if err != nil {
		return nil, err
	}
	return dbTasksToDTO(rows), nil
}

func (d *DBData) ListByProjectAndStatus(ctx context.Context, projectID, status string, limit, offset int32) ([]*TaskDTO, error) {
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, pkg.NewBizError("无效的 project_id")
	}
	rows, err := d.q.ListTasksByProjectAndStatus(ctx, db.ListTasksByProjectAndStatusParams{
		ProjectID: pid, Status: status, Limit: limit, Offset: offset,
	})
	if err != nil {
		return nil, err
	}
	return dbTasksToDTO(rows), nil
}

func (d *DBData) ListByProjectTypeAndStatus(ctx context.Context, projectID, typ, status string, limit, offset int32) ([]*TaskDTO, error) {
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, pkg.NewBizError("无效的 project_id")
	}
	rows, err := d.q.ListTasksByProjectTypeAndStatus(ctx, db.ListTasksByProjectTypeAndStatusParams{
		ProjectID: pid, Type: typ, Status: status, Limit: limit, Offset: offset,
	})
	if err != nil {
		return nil, err
	}
	return dbTasksToDTO(rows), nil
}

func (d *DBData) ListByIDs(ctx context.Context, ids []string) ([]*TaskDTO, error) {
	uuids := make([]pgtype.UUID, 0, len(ids))
	for _, id := range ids {
		u := pkg.ParseUUID(id)
		if u.Valid {
			uuids = append(uuids, u)
		}
	}
	if len(uuids) == 0 {
		return nil, nil
	}
	rows, err := d.q.ListTasksByIDs(ctx, uuids)
	if err != nil {
		return nil, err
	}
	return dbTasksToDTO(rows), nil
}

func (d *DBData) UpdateStatus(ctx context.Context, id, status string, errorMsg *string, startedAt, completedAt *time.Time) (*TaskDTO, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	params := db.UpdateTaskStatusParams{
		ID:     uid,
		Status: status,
	}
	if errorMsg != nil {
		params.ErrorMsg = pgtype.Text{String: *errorMsg, Valid: true}
	}
	if startedAt != nil {
		params.StartedAt = pgtype.Timestamptz{Time: *startedAt, Valid: true}
	}
	if completedAt != nil {
		params.CompletedAt = pgtype.Timestamptz{Time: *completedAt, Valid: true}
	}
	row, err := d.q.UpdateTaskStatus(ctx, params)
	if err != nil {
		return nil, err
	}
	return dbTaskToDTO(&row), nil
}

func (d *DBData) UpdateProgress(ctx context.Context, id string, progress int32) (*TaskDTO, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.UpdateTaskProgress(ctx, db.UpdateTaskProgressParams{
		ID: uid, Progress: progress,
	})
	if err != nil {
		return nil, err
	}
	return dbTaskToDTO(&row), nil
}

func (d *DBData) UpdateResult(ctx context.Context, id string, result json.RawMessage) (*TaskDTO, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.UpdateTaskResult(ctx, db.UpdateTaskResultParams{
		ID: uid, ResultJson: result,
	})
	if err != nil {
		return nil, err
	}
	return dbTaskToDTO(&row), nil
}

func (d *DBData) Cancel(ctx context.Context, id string) (*TaskDTO, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.CancelTask(ctx, uid)
	if err != nil {
		return nil, err
	}
	return dbTaskToDTO(&row), nil
}

func (d *DBData) BatchCancel(ctx context.Context, ids []string) error {
	uuids := make([]pgtype.UUID, 0, len(ids))
	for _, id := range ids {
		u := pkg.ParseUUID(id)
		if u.Valid {
			uuids = append(uuids, u)
		}
	}
	if len(uuids) == 0 {
		return nil
	}
	return d.q.BatchCancelTasks(ctx, uuids)
}

// dbTaskToDTO 将 sqlc 模型转换为 DTO
func dbTaskToDTO(row *db.Task) *TaskDTO {
	t := &TaskDTO{
		ID:        pkg.UUIDString(row.ID),
		ProjectID: pkg.UUIDString(row.ProjectID),
		UserID:    pkg.UUIDString(row.UserID),
		Type:      row.Type,
		Status:    row.Status,
		Progress:  int(row.Progress),
		Title:     pgText(row.Title),
		ErrorMsg:  pgText(row.ErrorMsg),
		LockedBy:  pkg.UUIDString(row.LockedBy),
	}
	if row.Description.Valid {
		t.Description = row.Description.String
	}
	if row.CreatedAt.Valid {
		t.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		t.UpdatedAt = row.UpdatedAt.Time
	}
	if row.StartedAt.Valid {
		t.StartedAt = &row.StartedAt.Time
	}
	if row.CompletedAt.Valid {
		t.CompletedAt = &row.CompletedAt.Time
	}
	if row.LockedAt.Valid {
		t.LockedAt = &row.LockedAt.Time
	}
	if len(row.ConfigJson) > 0 {
		t.ConfigJSON = row.ConfigJson
	}
	if len(row.ResultJson) > 0 {
		t.ResultJSON = row.ResultJson
	}
	return t
}

func dbTasksToDTO(rows []db.Task) []*TaskDTO {
	out := make([]*TaskDTO, len(rows))
	for i := range rows {
		out[i] = dbTaskToDTO(&rows[i])
	}
	return out
}

func pgText(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

var _ Data = (*DBData)(nil)
