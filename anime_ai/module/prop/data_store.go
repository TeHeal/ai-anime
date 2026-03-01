package prop

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBPropStore 基于 sqlc 的 PostgreSQL 实现
type DBPropStore struct {
	q *db.Queries
}

// NewDBPropStore 创建 DBPropStore
func NewDBPropStore(queries *db.Queries) *DBPropStore {
	return &DBPropStore{q: queries}
}

func pgText(s string) pgtype.Text {
	if s == "" {
		return pgtype.Text{}
	}
	return pgtype.Text{String: s, Valid: true}
}

func dbPropToProp(row *db.Prop) *Prop {
	refJSON := "[]"
	if len(row.ReferenceImagesJson) > 0 {
		refJSON = string(row.ReferenceImagesJson)
	}
	usedBy := "[]"
	if len(row.UsedByJson) > 0 {
		usedBy = string(row.UsedByJson)
	}
	scenes := "[]"
	if len(row.ScenesJson) > 0 {
		scenes = string(row.ScenesJson)
	}
	return &Prop{
		ID:                  pkg.UUIDToStr(row.ID),
		ProjectID:           pkg.UUIDToStr(row.ProjectID),
		CreatedAt:           row.CreatedAt.Time,
		UpdatedAt:           row.UpdatedAt.Time,
		Name:                row.Name,
		Appearance:          row.Appearance.String,
		IsKeyProp:           row.IsKeyProp,
		Style:               row.Style.String,
		StyleOverride:       row.StyleOverride,
		ReferenceImagesJSON: refJSON,
		ImageURL:            row.ImageUrl.String,
		UsedByJSON:          usedBy,
		ScenesJSON:          scenes,
		Status:              row.Status.String,
		Source:               row.Source.String,
	}
}

func (s *DBPropStore) Create(p *Prop) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(p.ProjectID)
	if !projUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.CreatePropParams{
		ProjectID:  projUUID,
		Name:       p.Name,
		Appearance: pgText(p.Appearance),
		IsKeyProp:  p.IsKeyProp,
		Style:      pgText(p.Style),
		StyleOverride: p.StyleOverride,
		ImageUrl:   pgText(p.ImageURL),
	}
	row, err := s.q.CreateProp(ctx, arg)
	if err != nil {
		return err
	}
	p.ID = pkg.UUIDToStr(row.ID)
	p.ProjectID = pkg.UUIDToStr(row.ProjectID)
	p.CreatedAt = row.CreatedAt.Time
	p.UpdatedAt = row.UpdatedAt.Time
	p.Status = "draft"
	p.Source = "manual"
	return nil
}

func (s *DBPropStore) GetByID(id, projectID string) (*Prop, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	projUUID := pkg.StrToUUID(projectID)
	if !idUUID.Valid || !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := s.q.GetPropByID(ctx, idUUID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	prop := dbPropToProp(&row)
	if pkg.UUIDToStr(row.ProjectID) != projectID {
		return nil, pkg.ErrNotFound
	}
	return prop, nil
}

func (s *DBPropStore) ListByProject(projectID string) ([]Prop, error) {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	rows, err := s.q.ListPropsByProject(ctx, projUUID)
	if err != nil {
		return nil, err
	}
	out := make([]Prop, len(rows))
	for i := range rows {
		out[i] = *dbPropToProp(&rows[i])
	}
	return out, nil
}

func (s *DBPropStore) Update(p *Prop) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(p.ID)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	refJSON := []byte(p.ReferenceImagesJSON)
	if len(refJSON) == 0 {
		refJSON = []byte("[]")
	}
	usedBy := []byte(p.UsedByJSON)
	if len(usedBy) == 0 {
		usedBy = []byte("[]")
	}
	scenes := []byte(p.ScenesJSON)
	if len(scenes) == 0 {
		scenes = []byte("[]")
	}
	arg := db.UpdatePropParams{
		ID:                  idUUID,
		Name:                pgtype.Text{String: p.Name, Valid: true},
		Appearance:          pgtype.Text{String: p.Appearance, Valid: true},
		IsKeyProp:           pgtype.Bool{Bool: p.IsKeyProp, Valid: true},
		Style:               pgtype.Text{String: p.Style, Valid: true},
		StyleOverride:       pgtype.Bool{Bool: p.StyleOverride, Valid: true},
		ReferenceImagesJson: refJSON,
		ImageUrl:            pgtype.Text{String: p.ImageURL, Valid: true},
		UsedByJson:          usedBy,
		ScenesJson:          scenes,
		Status:              pgtype.Text{String: p.Status, Valid: true},
		Source:              pgtype.Text{String: p.Source, Valid: true},
	}
	row, err := s.q.UpdateProp(ctx, arg)
	if err != nil {
		return err
	}
	p.UpdatedAt = row.UpdatedAt.Time
	return nil
}

func (s *DBPropStore) Delete(id, projectID string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	_, err := s.GetByID(id, projectID)
	if err != nil {
		return err
	}
	return s.q.SoftDeleteProp(ctx, idUUID)
}
