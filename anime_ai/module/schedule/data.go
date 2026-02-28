package schedule

import (
	"context"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Data 定时任务数据访问接口
type Data interface {
	Create(ctx context.Context, arg CreateParams) (*Schedule, error)
	ListByProject(ctx context.Context, projectID string) ([]*Schedule, error)
	GetByID(ctx context.Context, id string) (*Schedule, error)
	Update(ctx context.Context, id string, arg UpdateParams) (*Schedule, error)
	Delete(ctx context.Context, id string) error
	ListDue(ctx context.Context) ([]*Schedule, error)
	UpdateRunTimes(ctx context.Context, id string, lastRun, nextRun time.Time) error
}

// CreateParams 创建参数
type CreateParams struct {
	ProjectID string
	UserID    string
	Name      string
	CronExpr  string
	Action    string
	Config    []byte
	Enabled   bool
	NextRunAt *time.Time
}

// UpdateParams 更新参数（可选字段）
type UpdateParams struct {
	Name     *string
	CronExpr *string
	Action   *string
	Config   []byte
	Enabled  *bool
}

// Schedule 定时任务模型
type Schedule struct {
	ID        string     `json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	ProjectID string     `json:"project_id"`
	UserID    string     `json:"user_id"`
	Name      string     `json:"name"`
	CronExpr  string     `json:"cron_expr"`
	Action    string     `json:"action"`
	Config    []byte     `json:"config,omitempty"`
	Enabled   bool       `json:"enabled"`
	LastRunAt *time.Time `json:"last_run_at,omitempty"`
	NextRunAt *time.Time `json:"next_run_at,omitempty"`
}

// DBData 基于 sqlc 的实现
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData
func NewDBData(q *db.Queries) *DBData {
	return &DBData{q: q}
}

func (d *DBData) Create(ctx context.Context, arg CreateParams) (*Schedule, error) {
	pid := pkg.StrToUUID(arg.ProjectID)
	uid := pkg.StrToUUID(arg.UserID)
	if !pid.Valid || !uid.Valid {
		return nil, pkg.NewBizError("无效的 project_id 或 user_id")
	}
	cfg := arg.Config
	if cfg == nil {
		cfg = []byte("{}")
	}
	var nextRun pgtype.Timestamptz
	if arg.NextRunAt != nil {
		nextRun = pgtype.Timestamptz{Time: *arg.NextRunAt, Valid: true}
	}
	row, err := d.q.CreateSchedule(ctx, db.CreateScheduleParams{
		ProjectID:  pid,
		UserID:     uid,
		Name:       arg.Name,
		CronExpr:   arg.CronExpr,
		Action:     arg.Action,
		ConfigJson: cfg,
		Enabled:    arg.Enabled,
		NextRunAt:  nextRun,
	})
	if err != nil {
		return nil, err
	}
	return dbScheduleToSchedule(&row), nil
}

func (d *DBData) ListByProject(ctx context.Context, projectID string) ([]*Schedule, error) {
	pid := pkg.StrToUUID(projectID)
	if !pid.Valid {
		return nil, pkg.NewBizError("无效的 project_id")
	}
	rows, err := d.q.ListSchedulesByProject(ctx, pid)
	if err != nil {
		return nil, err
	}
	out := make([]*Schedule, len(rows))
	for i := range rows {
		out[i] = dbScheduleToSchedule(&rows[i])
	}
	return out, nil
}

func (d *DBData) GetByID(ctx context.Context, id string) (*Schedule, error) {
	uid := pkg.StrToUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.GetScheduleByID(ctx, uid)
	if err != nil {
		return nil, err
	}
	return dbScheduleToSchedule(&row), nil
}

func (d *DBData) Update(ctx context.Context, id string, arg UpdateParams) (*Schedule, error) {
	uid := pkg.StrToUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	params := db.UpdateScheduleParams{ID: uid}
	if arg.Name != nil {
		params.Name = pgtype.Text{String: *arg.Name, Valid: true}
	}
	if arg.CronExpr != nil {
		params.CronExpr = pgtype.Text{String: *arg.CronExpr, Valid: true}
	}
	if arg.Action != nil {
		params.Action = pgtype.Text{String: *arg.Action, Valid: true}
	}
	if len(arg.Config) > 0 {
		params.ConfigJson = arg.Config
	}
	if arg.Enabled != nil {
		params.Enabled = pgtype.Bool{Bool: *arg.Enabled, Valid: true}
	}
	row, err := d.q.UpdateSchedule(ctx, params)
	if err != nil {
		return nil, err
	}
	return dbScheduleToSchedule(&row), nil
}

func (d *DBData) Delete(ctx context.Context, id string) error {
	uid := pkg.StrToUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return d.q.DeleteSchedule(ctx, uid)
}

func (d *DBData) ListDue(ctx context.Context) ([]*Schedule, error) {
	rows, err := d.q.ListDueSchedules(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]*Schedule, len(rows))
	for i := range rows {
		out[i] = dbScheduleToSchedule(&rows[i])
	}
	return out, nil
}

func (d *DBData) UpdateRunTimes(ctx context.Context, id string, lastRun, nextRun time.Time) error {
	uid := pkg.StrToUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return d.q.UpdateScheduleRunTimes(ctx, db.UpdateScheduleRunTimesParams{
		ID:         uid,
		LastRunAt:  pgtype.Timestamptz{Time: lastRun, Valid: true},
		NextRunAt:  pgtype.Timestamptz{Time: nextRun, Valid: true},
	})
}

func dbScheduleToSchedule(row *db.Schedule) *Schedule {
	s := &Schedule{
		ID:        pkg.UUIDString(row.ID),
		ProjectID: pkg.UUIDString(row.ProjectID),
		UserID:    pkg.UUIDString(row.UserID),
		Name:      row.Name,
		CronExpr:  row.CronExpr,
		Action:    row.Action,
		Config:    row.ConfigJson,
		Enabled:   row.Enabled,
	}
	if row.CreatedAt.Valid {
		s.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		s.UpdatedAt = row.UpdatedAt.Time
	}
	if row.LastRunAt.Valid {
		s.LastRunAt = &row.LastRunAt.Time
	}
	if row.NextRunAt.Valid {
		s.NextRunAt = &row.NextRunAt.Time
	}
	return s
}

var _ Data = (*DBData)(nil)
