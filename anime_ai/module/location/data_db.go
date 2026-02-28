package location

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBLocationStore 基于 sqlc 的 PostgreSQL 实现
type DBLocationStore struct {
	q *db.Queries
}

// NewDBLocationStore 创建 DBLocationStore
func NewDBLocationStore(queries *db.Queries) *DBLocationStore {
	return &DBLocationStore{q: queries}
}

func pgText(s string) pgtype.Text {
	if s == "" {
		return pgtype.Text{}
	}
	return pgtype.Text{String: s, Valid: true}
}

func dbLocationToLocation(row *db.Location) *Location {
	refJSON := "[]"
	if len(row.ReferenceImagesJson) > 0 {
		refJSON = string(row.ReferenceImagesJson)
	}
	return &Location{
		ID:                  pkg.UUIDToStr(row.ID),
		ProjectID:           pkg.UUIDToStr(row.ProjectID),
		CreatedAt:           row.CreatedAt.Time,
		UpdatedAt:           row.UpdatedAt.Time,
		Name:                row.Name,
		Time:                row.Time.String,
		InteriorExterior:    row.InteriorExterior.String,
		Atmosphere:          row.Atmosphere.String,
		ColorTone:           row.ColorTone.String,
		Layout:              row.Layout.String,
		Style:               row.Style.String,
		StyleOverride:       row.StyleOverride,
		StyleNote:           row.StyleNote.String,
		ImageURL:            row.ImageUrl.String,
		ReferenceImagesJSON: refJSON,
		TaskID:              row.TaskID.String,
		ImageStatus:         row.ImageStatus.String,
		Status:               row.Status.String,
		Source:               row.Source.String,
	}
}

func (s *DBLocationStore) Create(loc *Location) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(loc.ProjectID)
	if !projUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.CreateLocationParams{
		ProjectID:      projUUID,
		Name:           loc.Name,
		Time:           pgText(loc.Time),
		InteriorExterior: pgText(loc.InteriorExterior),
		Atmosphere:     pgText(loc.Atmosphere),
		ColorTone:      pgText(loc.ColorTone),
		Layout:         pgText(loc.Layout),
		Style:          pgText(loc.Style),
		StyleOverride:  loc.StyleOverride,
		StyleNote:      pgText(loc.StyleNote),
	}
	row, err := s.q.CreateLocation(ctx, arg)
	if err != nil {
		return err
	}
	loc.ID = pkg.UUIDToStr(row.ID)
	loc.ProjectID = pkg.UUIDToStr(row.ProjectID)
	loc.CreatedAt = row.CreatedAt.Time
	loc.UpdatedAt = row.UpdatedAt.Time
	loc.ImageStatus = "none"
	loc.Status = "draft"
	loc.Source = "manual"
	return nil
}

func (s *DBLocationStore) GetByID(id, projectID string) (*Location, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	projUUID := pkg.StrToUUID(projectID)
	if !idUUID.Valid || !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := s.q.GetLocationByID(ctx, idUUID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	loc := dbLocationToLocation(&row)
	if pkg.UUIDToStr(row.ProjectID) != projectID {
		return nil, pkg.ErrNotFound
	}
	return loc, nil
}

func (s *DBLocationStore) ListByProject(projectID string) ([]Location, error) {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	rows, err := s.q.ListLocationsByProject(ctx, projUUID)
	if err != nil {
		return nil, err
	}
	out := make([]Location, len(rows))
	for i := range rows {
		out[i] = *dbLocationToLocation(&rows[i])
	}
	return out, nil
}

func (s *DBLocationStore) Update(loc *Location) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(loc.ID)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	refJSON := []byte(loc.ReferenceImagesJSON)
	if len(refJSON) == 0 {
		refJSON = []byte("[]")
	}
	arg := db.UpdateLocationParams{
		ID:                  idUUID,
		Name:                pgtype.Text{String: loc.Name, Valid: true},
		Time:                pgtype.Text{String: loc.Time, Valid: true},
		InteriorExterior:    pgtype.Text{String: loc.InteriorExterior, Valid: true},
		Atmosphere:          pgtype.Text{String: loc.Atmosphere, Valid: true},
		ColorTone:           pgtype.Text{String: loc.ColorTone, Valid: true},
		Layout:              pgtype.Text{String: loc.Layout, Valid: true},
		Style:               pgtype.Text{String: loc.Style, Valid: true},
		StyleOverride:       pgtype.Bool{Bool: loc.StyleOverride, Valid: true},
		StyleNote:           pgtype.Text{String: loc.StyleNote, Valid: true},
		ImageUrl:            pgtype.Text{String: loc.ImageURL, Valid: true},
		ReferenceImagesJson: refJSON,
		Status:              pgtype.Text{String: loc.Status, Valid: true},
	}
	row, err := s.q.UpdateLocation(ctx, arg)
	if err != nil {
		return err
	}
	loc.UpdatedAt = row.UpdatedAt.Time
	return nil
}

func (s *DBLocationStore) UpdateImage(id, projectID, imageURL, taskID, imageStatus string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateLocationImageParams{
		ID:          idUUID,
		ImageUrl:    pgtype.Text{String: imageURL, Valid: imageURL != ""},
		TaskID:      pgtype.Text{String: taskID, Valid: taskID != ""},
		ImageStatus: pgtype.Text{String: imageStatus, Valid: true},
	}
	_, err := s.q.UpdateLocationImage(ctx, arg)
	return err
}

func (s *DBLocationStore) Delete(id, projectID string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	// 校验 projectID 归属
	_, err := s.GetByID(id, projectID)
	if err != nil {
		return err
	}
	return s.q.SoftDeleteLocation(ctx, idUUID)
}
