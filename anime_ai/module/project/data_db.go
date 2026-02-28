package project

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBData 基于 sqlc 的 PostgreSQL 实现，封装 projects、project_members
// pgtype.UUID 与 module 的 string ID 在边界处转换
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData 实例
func NewDBData(queries *db.Queries) *DBData {
	return &DBData{q: queries}
}

func (d *DBData) CreateProject(p *Project) error {
	ctx := context.Background()
	userID := pkg.StrToUUID(p.UserIDStr)
	if !userID.Valid {
		return errors.New("无效的 user_id")
	}
	arg := db.CreateProjectParams{
		UserID:     userID,
		Name:       p.Name,
		Story:      pgtype.Text{String: p.Story, Valid: true},
		StoryMode:  pgtype.Text{String: p.StoryMode, Valid: true},
		ConfigJson: json.RawMessage(p.ConfigJSON),
		PropsJson:  json.RawMessage(p.PropsJSON),
		StoryboardJson: json.RawMessage(p.StoryboardJSON),
		MirrorMode: true,
	}
	row, err := d.q.CreateProject(ctx, arg)
	if err != nil {
		return err
	}
	p.IDStr = pkg.UUIDToStr(row.ID)
	p.CreatedAt = row.CreatedAt.Time
	p.UpdatedAt = row.UpdatedAt.Time
	return nil
}

func (d *DBData) FindByID(id string, userID string) (*Project, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	userUUID := pkg.StrToUUID(userID)
	if !idUUID.Valid {
		return nil, ErrProjectNotFound
	}
	// 先尝试按所有者查询
	row, err := d.q.GetProjectByIDAndUser(ctx, db.GetProjectByIDAndUserParams{ID: idUUID, UserID: userUUID})
	if err == nil {
		return dbProjectToProject(&row), nil
	}
	// 再检查是否为项目成员
	member, err := d.q.GetProjectMemberByProjectAndUser(ctx, db.GetProjectMemberByProjectAndUserParams{
		ProjectID: idUUID, UserID: userUUID,
	})
	if err != nil {
		return nil, ErrProjectNotFound
	}
	_ = member // 成员存在，可访问
	row2, err := d.q.GetProjectByID(ctx, idUUID)
	if err != nil {
		return nil, ErrProjectNotFound
	}
	return dbProjectToProject(&row2), nil
}

func (d *DBData) FindByIDOnly(id string) (*Project, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return nil, ErrProjectNotFound
	}
	row, err := d.q.GetProjectByID(ctx, idUUID)
	if err != nil {
		return nil, ErrProjectNotFound
	}
	return dbProjectToProject(&row), nil
}

func (d *DBData) ListByUser(userID string) ([]Project, error) {
	ctx := context.Background()
	userUUID := pkg.StrToUUID(userID)
	if !userUUID.Valid {
		return nil, errors.New("无效的 user_id")
	}
	rows, err := d.q.ListProjectsByUserOrMember(ctx, userUUID)
	if err != nil {
		return nil, err
	}
	out := make([]Project, len(rows))
	for i := range rows {
		out[i] = *dbProjectToProject(&rows[i])
	}
	return out, nil
}

func (d *DBData) UpdateProject(p *Project) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(p.IDStr)
	if !idUUID.Valid {
		return ErrProjectNotFound
	}
	arg := db.UpdateProjectParams{
		ID:             idUUID,
		Name:           pgtype.Text{String: p.Name, Valid: true},
		Story:          pgtype.Text{String: p.Story, Valid: true},
		StoryMode:      pgtype.Text{String: p.StoryMode, Valid: true},
		ConfigJson:     []byte(p.ConfigJSON),
		PropsJson:      []byte(p.PropsJSON),
		StoryboardJson: []byte(p.StoryboardJSON),
		MirrorMode:     pgtype.Bool{Bool: p.MirrorMode, Valid: true},
	}
	_, err := d.q.UpdateProject(ctx, arg)
	return err
}

func (d *DBData) DeleteProject(id string, userID string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	userUUID := pkg.StrToUUID(userID)
	if !idUUID.Valid || !userUUID.Valid {
		return ErrProjectNotFound
	}
	return d.q.SoftDeleteProject(ctx, db.SoftDeleteProjectParams{ID: idUUID, UserID: userUUID})
}

func (d *DBData) CreateMember(m *ProjectMember) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(m.ProjectIDStr)
	userUUID := pkg.StrToUUID(m.UserIDStr)
	if !projUUID.Valid || !userUUID.Valid {
		return ErrProjectNotFound
	}
	arg := db.CreateProjectMemberParams{
		ProjectID: projUUID,
		UserID:    userUUID,
		Role:      m.Role,
	}
	row, err := d.q.CreateProjectMember(ctx, arg)
	if err != nil {
		return err
	}
	m.IDStr = pkg.UUIDToStr(row.ID)
	m.CreatedAt = row.CreatedAt.Time
	m.UpdatedAt = row.UpdatedAt.Time
	return nil
}

func (d *DBData) FindMemberByProjectAndUser(projectID, userID string) (*ProjectMember, error) {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	userUUID := pkg.StrToUUID(userID)
	if !projUUID.Valid || !userUUID.Valid {
		return nil, ErrMemberNotFound
	}
	row, err := d.q.GetProjectMemberByProjectAndUser(ctx, db.GetProjectMemberByProjectAndUserParams{
		ProjectID: projUUID, UserID: userUUID,
	})
	if err != nil {
		return nil, ErrMemberNotFound
	}
	return dbMemberToMember(&row), nil
}

func (d *DBData) ListMembersByProject(projectID string) ([]ProjectMember, error) {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, ErrProjectNotFound
	}
	rows, err := d.q.ListProjectMembersByProject(ctx, projUUID)
	if err != nil {
		return nil, err
	}
	out := make([]ProjectMember, len(rows))
	for i := range rows {
		out[i] = *dbMemberToMember(&rows[i])
	}
	return out, nil
}

func (d *DBData) UpdateMemberRole(projectID, userID string, role string) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	userUUID := pkg.StrToUUID(userID)
	if !projUUID.Valid || !userUUID.Valid {
		return ErrMemberNotFound
	}
	_, err := d.q.UpdateProjectMemberRole(ctx, db.UpdateProjectMemberRoleParams{
		Role: pgtype.Text{String: role, Valid: true}, ProjectID: projUUID, UserID: userUUID,
	})
	return err
}

func (d *DBData) DeleteMember(projectID, userID string) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	userUUID := pkg.StrToUUID(userID)
	if !projUUID.Valid || !userUUID.Valid {
		return ErrMemberNotFound
	}
	return d.q.SoftDeleteProjectMember(ctx, db.SoftDeleteProjectMemberParams{
		ProjectID: projUUID, UserID: userUUID,
	})
}

func dbProjectToProject(row *db.Project) *Project {
	p := &Project{
		IDStr:         pkg.UUIDToStr(row.ID),
		UserIDStr:     pkg.UUIDToStr(row.UserID),
		Name:          row.Name,
		Story:         row.Story.String,
		StoryMode:     row.StoryMode.String,
		ConfigJSON:    string(row.ConfigJson),
		PropsJSON:     string(row.PropsJson),
		StoryboardJSON: string(row.StoryboardJson),
		MirrorMode:    row.MirrorMode,
		Version:       int(row.Version),
		StoryLocked:   row.StoryLocked,
		AssetsLocked:  row.AssetsLocked,
		ScriptLocked:  row.ScriptLocked,
	}
	if row.CreatedAt.Valid {
		p.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		p.UpdatedAt = row.UpdatedAt.Time
	}
	if row.StoryLockedAt.Valid {
		p.StoryLockedAt = &row.StoryLockedAt.Time
	}
	if row.AssetsLockedAt.Valid {
		p.AssetsLockedAt = &row.AssetsLockedAt.Time
	}
	if row.ScriptLockedAt.Valid {
		p.ScriptLockedAt = &row.ScriptLockedAt.Time
	}
	if row.Visibility.Valid {
		p.Visibility = row.Visibility.String
	}
	return p
}

func dbMemberToMember(row *db.ProjectMember) *ProjectMember {
	m := &ProjectMember{
		IDStr:        pkg.UUIDToStr(row.ID),
		ProjectIDStr: pkg.UUIDToStr(row.ProjectID),
		UserIDStr:    pkg.UUIDToStr(row.UserID),
		Role:         row.Role,
	}
	if row.CreatedAt.Valid {
		m.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		m.UpdatedAt = row.UpdatedAt.Time
	}
	if row.JoinedAt.Valid {
		m.JoinedAt = &row.JoinedAt.Time
	}
	return m
}
