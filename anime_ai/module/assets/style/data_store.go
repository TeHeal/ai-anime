package style

import (
	"context"
	"fmt"

	"anime_ai/pub/pkg"
	"anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBData 基于 sqlc 的 PostgreSQL 实现
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData
func NewDBData(queries *db.Queries) *DBData {
	return &DBData{q: queries}
}

func dbStyleToStyle(row *db.Style) *Style {
	refJSON := "[]"
	if len(row.ReferenceImagesJson) > 0 {
		refJSON = string(row.ReferenceImagesJson)
	}
	return &Style{
		ID:                  pkg.UUIDToStr(row.ID),
		ProjectID:           pkg.UUIDToStr(row.ProjectID),
		CreatedAt:           row.CreatedAt.Time,
		UpdatedAt:           row.UpdatedAt.Time,
		Name:                row.Name,
		Description:         row.Description.String,
		NegativePrompt:      row.NegativePrompt.String,
		ReferenceImagesJSON: refJSON,
		ThumbnailURL:        row.ThumbnailUrl.String,
		IsPreset:            row.IsPreset,
		IsProjectDefault:    row.IsProjectDefault,
	}
}

func (d *DBData) ListByProject(projectID string) ([]*Style, error) {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	rows, err := d.q.ListStylesByProject(ctx, projUUID)
	if err != nil {
		return nil, err
	}
	out := make([]*Style, len(rows))
	for i := range rows {
		out[i] = dbStyleToStyle(&rows[i])
	}
	return out, nil
}

func (d *DBData) GetByID(id, projectID string) (*Style, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.GetStyleByID(ctx, idUUID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	s := dbStyleToStyle(&row)
	if s.ProjectID != projectID {
		return nil, pkg.ErrNotFound
	}
	return s, nil
}

func (d *DBData) Create(s *Style) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(s.ProjectID)
	if !projUUID.Valid {
		return pkg.ErrNotFound
	}
	refJSON := []byte(s.ReferenceImagesJSON)
	if len(refJSON) == 0 {
		refJSON = []byte("[]")
	}
	arg := db.CreateStyleParams{
		ProjectID:           projUUID,
		Name:                s.Name,
		Description:         pgtype.Text{String: s.Description, Valid: s.Description != ""},
		NegativePrompt:      pgtype.Text{String: s.NegativePrompt, Valid: s.NegativePrompt != ""},
		ReferenceImagesJson: refJSON,
		ThumbnailUrl:        pgtype.Text{String: s.ThumbnailURL, Valid: s.ThumbnailURL != ""},
		IsPreset:            s.IsPreset,
		IsProjectDefault:    s.IsProjectDefault,
	}
	row, err := d.q.CreateStyle(ctx, arg)
	if err != nil {
		return err
	}
	s.ID = pkg.UUIDToStr(row.ID)
	s.CreatedAt = row.CreatedAt.Time
	s.UpdatedAt = row.UpdatedAt.Time
	return nil
}

func (d *DBData) Update(s *Style) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(s.ID)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateStyleParams{
		ID:               idUUID,
		Name:             pgtype.Text{String: s.Name, Valid: true},
		Description:      pgtype.Text{String: s.Description, Valid: true},
		NegativePrompt:   pgtype.Text{String: s.NegativePrompt, Valid: true},
		ThumbnailUrl:     pgtype.Text{String: s.ThumbnailURL, Valid: true},
		IsProjectDefault: pgtype.Bool{Bool: s.IsProjectDefault, Valid: true},
	}
	refJSON := []byte(s.ReferenceImagesJSON)
	if len(refJSON) == 0 {
		refJSON = []byte("[]")
	}
	arg.ReferenceImagesJson = refJSON
	row, err := d.q.UpdateStyle(ctx, arg)
	if err != nil {
		return err
	}
	s.UpdatedAt = row.UpdatedAt.Time
	return nil
}

func (d *DBData) Delete(id, projectID string) error {
	ctx := context.Background()
	_, err := d.GetByID(id, projectID)
	if err != nil {
		return err
	}
	idUUID := pkg.StrToUUID(id)
	return d.q.SoftDeleteStyle(ctx, idUUID)
}

func (d *DBData) ClearProjectDefault(projectID string) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return pkg.ErrNotFound
	}
	return d.q.ClearProjectDefault(ctx, projUUID)
}

func (d *DBData) SetProjectDefault(id, projectID string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	projUUID := pkg.StrToUUID(projectID)
	if !idUUID.Valid || !projUUID.Valid {
		return pkg.ErrNotFound
	}
	return d.q.SetProjectDefault(ctx, db.SetProjectDefaultParams{ID: idUUID, ProjectID: projUUID})
}

func (d *DBData) ApplyAll(styleID, projectID, styleName string) (int, error) {
	ctx := context.Background()
	styleUUID := pkg.StrToUUID(styleID)
	projUUID := pkg.StrToUUID(projectID)
	if !styleUUID.Valid || !projUUID.Valid {
		return 0, pkg.ErrNotFound
	}
	arg := db.ApplyStyleToCharactersParams{
		StyleID:   styleUUID,
		StyleName: pgtype.Text{String: styleName, Valid: true},
		ProjectID: projUUID,
	}
	chars, err := d.q.ApplyStyleToCharacters(ctx, arg)
	if err != nil {
		return 0, fmt.Errorf("应用风格到角色失败: %w", err)
	}
	argLoc := db.ApplyStyleToLocationsParams{StyleID: styleUUID, StyleName: pgtype.Text{String: styleName, Valid: true}, ProjectID: projUUID}
	locs, err := d.q.ApplyStyleToLocations(ctx, argLoc)
	if err != nil {
		return 0, fmt.Errorf("应用风格到场景失败: %w", err)
	}
	argProp := db.ApplyStyleToPropsParams{StyleID: styleUUID, StyleName: pgtype.Text{String: styleName, Valid: true}, ProjectID: projUUID}
	props, err := d.q.ApplyStyleToProps(ctx, argProp)
	if err != nil {
		return 0, fmt.Errorf("应用风格到道具失败: %w", err)
	}
	return len(chars) + len(locs) + len(props), nil
}
