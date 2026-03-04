package team

import (
	"context"
	"encoding/json"
	"fmt"

	"anime_ai/pub/pkg"
	"anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Data 团队数据访问层接口
type Data interface {
	CreateTeam(ctx context.Context, orgID, name, description string) (*Team, error)
	GetTeamByID(ctx context.Context, id string) (*Team, error)
	ListTeamsByOrg(ctx context.Context, orgID string) ([]Team, error)
	UpdateTeam(ctx context.Context, id string, name, description *string) (*Team, error)
	DeleteTeam(ctx context.Context, id string) error
	AddMember(ctx context.Context, teamID, userID, role string, jobRoles []string) (*TeamMember, error)
	GetMember(ctx context.Context, teamID, userID string) (*TeamMember, error)
	ListMembers(ctx context.Context, teamID string) ([]TeamMember, error)
	UpdateMember(ctx context.Context, teamID, userID string, role *string, jobRoles []string) (*TeamMember, error)
	RemoveMember(ctx context.Context, teamID, userID string) error
}

// Team 团队 DTO
type Team struct {
	ID          string `json:"id"`
	CreatedAt   string `json:"createdAt"`
	UpdatedAt   string `json:"updatedAt"`
	OrgID       string `json:"orgId"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// TeamMember 团队成员 DTO
type TeamMember struct {
	ID          string   `json:"id"`
	CreatedAt   string   `json:"createdAt"`
	TeamID      string   `json:"teamId"`
	UserID      string   `json:"userId"`
	Role        string   `json:"role"`
	JobRoles    []string `json:"jobRoles"`
	JoinedAt    string   `json:"joinedAt"`
	Username    string   `json:"username"`
	DisplayName string   `json:"displayName"`
}

// DBData 基于 sqlc 的 PostgreSQL 实现
type DBData struct {
	q *db.Queries
}

func NewDBData(q *db.Queries) *DBData {
	return &DBData{q: q}
}

func toTeam(t db.Team) *Team {
	return &Team{
		ID:          pkg.UUIDString(t.ID),
		CreatedAt:   pgTimeStr(t.CreatedAt),
		UpdatedAt:   pgTimeStr(t.UpdatedAt),
		OrgID:       pkg.UUIDString(t.OrgID),
		Name:        t.Name,
		Description: textStr(t.Description),
	}
}

func parseJobRoles(raw []byte) []string {
	var roles []string
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &roles)
	}
	if roles == nil {
		roles = []string{}
	}
	return roles
}

func jobRolesToJSON(roles []string) []byte {
	if roles == nil {
		roles = []string{}
	}
	b, _ := json.Marshal(roles)
	return b
}

func textStr(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

func pgTimeStr(t pgtype.Timestamptz) string {
	if !t.Valid {
		return ""
	}
	return t.Time.Format("2006-01-02T15:04:05Z07:00")
}

func nilIfEmpty(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}

func (d *DBData) CreateTeam(ctx context.Context, orgID, name, description string) (*Team, error) {
	oid := pkg.ParseUUID(orgID)
	if !oid.Valid {
		return nil, fmt.Errorf("%w: 无效的组织 ID", pkg.ErrBadRequest)
	}
	t, err := d.q.CreateTeam(ctx, db.CreateTeamParams{
		OrgID:       oid,
		Name:        name,
		Description: nilIfEmpty(description),
	})
	if err != nil {
		return nil, fmt.Errorf("创建团队失败: %w", err)
	}
	return toTeam(t), nil
}

func (d *DBData) GetTeamByID(ctx context.Context, id string) (*Team, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的团队 ID", pkg.ErrBadRequest)
	}
	t, err := d.q.GetTeamByID(ctx, uid)
	if err != nil {
		return nil, fmt.Errorf("%w: 团队不存在", pkg.ErrNotFound)
	}
	return toTeam(t), nil
}

func (d *DBData) ListTeamsByOrg(ctx context.Context, orgID string) ([]Team, error) {
	oid := pkg.ParseUUID(orgID)
	if !oid.Valid {
		return nil, nil
	}
	rows, err := d.q.ListTeamsByOrg(ctx, oid)
	if err != nil {
		return nil, fmt.Errorf("查询团队列表失败: %w", err)
	}
	out := make([]Team, len(rows))
	for i, r := range rows {
		out[i] = *toTeam(r)
	}
	return out, nil
}

func (d *DBData) UpdateTeam(ctx context.Context, id string, name, description *string) (*Team, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的团队 ID", pkg.ErrBadRequest)
	}
	params := db.UpdateTeamParams{ID: uid}
	if name != nil {
		params.Name = pgtype.Text{String: *name, Valid: true}
	}
	if description != nil {
		params.Description = pgtype.Text{String: *description, Valid: true}
	}
	t, err := d.q.UpdateTeam(ctx, params)
	if err != nil {
		return nil, fmt.Errorf("%w: 团队不存在或更新失败", pkg.ErrNotFound)
	}
	return toTeam(t), nil
}

func (d *DBData) DeleteTeam(ctx context.Context, id string) error {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return fmt.Errorf("%w: 无效的团队 ID", pkg.ErrBadRequest)
	}
	return d.q.SoftDeleteTeam(ctx, uid)
}

func (d *DBData) AddMember(ctx context.Context, teamID, userID, role string, jobRoles []string) (*TeamMember, error) {
	tid := pkg.ParseUUID(teamID)
	uid := pkg.ParseUUID(userID)
	if !tid.Valid || !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的 ID", pkg.ErrBadRequest)
	}
	m, err := d.q.AddTeamMember(ctx, db.AddTeamMemberParams{
		TeamID:   tid,
		UserID:   uid,
		Role:     nilIfEmpty(role),
		JobRoles: jobRolesToJSON(jobRoles),
	})
	if err != nil {
		return nil, fmt.Errorf("添加团队成员失败: %w", err)
	}
	return &TeamMember{
		ID:       pkg.UUIDString(m.ID),
		TeamID:   pkg.UUIDString(m.TeamID),
		UserID:   pkg.UUIDString(m.UserID),
		Role:     m.Role,
		JobRoles: parseJobRoles(m.JobRoles),
		JoinedAt: pgTimeStr(m.JoinedAt),
	}, nil
}

func (d *DBData) GetMember(ctx context.Context, teamID, userID string) (*TeamMember, error) {
	tid := pkg.ParseUUID(teamID)
	uid := pkg.ParseUUID(userID)
	if !tid.Valid || !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的 ID", pkg.ErrBadRequest)
	}
	m, err := d.q.GetTeamMember(ctx, db.GetTeamMemberParams{TeamID: tid, UserID: uid})
	if err != nil {
		return nil, fmt.Errorf("%w: 成员不存在", pkg.ErrNotFound)
	}
	return &TeamMember{
		ID:       pkg.UUIDString(m.ID),
		TeamID:   pkg.UUIDString(m.TeamID),
		UserID:   pkg.UUIDString(m.UserID),
		Role:     m.Role,
		JobRoles: parseJobRoles(m.JobRoles),
		JoinedAt: pgTimeStr(m.JoinedAt),
	}, nil
}

func (d *DBData) ListMembers(ctx context.Context, teamID string) ([]TeamMember, error) {
	tid := pkg.ParseUUID(teamID)
	if !tid.Valid {
		return nil, fmt.Errorf("%w: 无效的团队 ID", pkg.ErrBadRequest)
	}
	rows, err := d.q.ListTeamMembers(ctx, tid)
	if err != nil {
		return nil, fmt.Errorf("查询团队成员列表失败: %w", err)
	}
	out := make([]TeamMember, len(rows))
	for i, r := range rows {
		out[i] = TeamMember{
			ID:          pkg.UUIDString(r.ID),
			CreatedAt:   pgTimeStr(r.CreatedAt),
			TeamID:      pkg.UUIDString(r.TeamID),
			UserID:      pkg.UUIDString(r.UserID),
			Role:        r.Role,
			JobRoles:    parseJobRoles(r.JobRoles),
			JoinedAt:    pgTimeStr(r.JoinedAt),
			Username:    r.Username,
			DisplayName: textStr(r.DisplayName),
		}
	}
	return out, nil
}

func (d *DBData) UpdateMember(ctx context.Context, teamID, userID string, role *string, jobRoles []string) (*TeamMember, error) {
	tid := pkg.ParseUUID(teamID)
	uid := pkg.ParseUUID(userID)
	if !tid.Valid || !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的 ID", pkg.ErrBadRequest)
	}
	params := db.UpdateTeamMemberParams{TeamID: tid, UserID: uid}
	if role != nil {
		params.Role = pgtype.Text{String: *role, Valid: true}
	}
	if jobRoles != nil {
		params.JobRoles = jobRolesToJSON(jobRoles)
	}
	m, err := d.q.UpdateTeamMember(ctx, params)
	if err != nil {
		return nil, fmt.Errorf("%w: 成员不存在或更新失败", pkg.ErrNotFound)
	}
	return &TeamMember{
		ID:       pkg.UUIDString(m.ID),
		TeamID:   pkg.UUIDString(m.TeamID),
		UserID:   pkg.UUIDString(m.UserID),
		Role:     m.Role,
		JobRoles: parseJobRoles(m.JobRoles),
		JoinedAt: pgTimeStr(m.JoinedAt),
	}, nil
}

func (d *DBData) RemoveMember(ctx context.Context, teamID, userID string) error {
	tid := pkg.ParseUUID(teamID)
	uid := pkg.ParseUUID(userID)
	if !tid.Valid || !uid.Valid {
		return fmt.Errorf("%w: 无效的 ID", pkg.ErrBadRequest)
	}
	return d.q.RemoveTeamMember(ctx, db.RemoveTeamMemberParams{TeamID: tid, UserID: uid})
}
