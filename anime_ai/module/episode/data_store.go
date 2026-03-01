package episode

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBEpisodeStore 基于 sqlc 的 PostgreSQL 实现
type DBEpisodeStore struct {
	q *db.Queries
}

// NewDBEpisodeStore 创建 DBEpisodeStore
func NewDBEpisodeStore(queries *db.Queries) *DBEpisodeStore {
	return &DBEpisodeStore{q: queries}
}

func (s *DBEpisodeStore) Create(ep *Episode) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(ep.ProjectIDStr)
	if !projUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.CreateEpisodeParams{
		ProjectID: projUUID,
		Title:     pgtype.Text{String: ep.Title, Valid: true},
		SortIndex: int32(ep.SortIndex),
		Summary:   pgtype.Text{String: ep.Summary, Valid: true},
		Status:    ep.Status,
		CurrentStep: int32(ep.CurrentStep),
		CurrentPhase: ep.CurrentPhase,
	}
	if ep.LastActiveAt != nil {
		arg.LastActiveAt = pgtype.Timestamptz{Time: *ep.LastActiveAt, Valid: true}
	}
	row, err := s.q.CreateEpisode(ctx, arg)
	if err != nil {
		return err
	}
	ep.IDStr = pkg.UUIDToStr(row.ID)
	ep.ProjectIDStr = pkg.UUIDToStr(row.ProjectID)
	if row.CreatedAt.Valid {
		ep.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		ep.UpdatedAt = row.UpdatedAt.Time
	}
	return nil
}

func (s *DBEpisodeStore) FindByID(id string) (*Episode, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := s.q.GetEpisodeByID(ctx, idUUID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return dbEpisodeToEpisode(&row), nil
}

func (s *DBEpisodeStore) ListByProject(projectID string) ([]Episode, error) {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	rows, err := s.q.ListEpisodesByProject(ctx, projUUID)
	if err != nil {
		return nil, err
	}
	out := make([]Episode, len(rows))
	for i := range rows {
		out[i] = *dbEpisodeToEpisode(&rows[i])
	}
	return out, nil
}

func (s *DBEpisodeStore) Update(ep *Episode) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(ep.IDStr)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateEpisodeParams{
		ID:           idUUID,
		Title:        pgtype.Text{String: ep.Title, Valid: true},
		SortIndex:    pgtype.Int4{Int32: int32(ep.SortIndex), Valid: true},
		Summary:      pgtype.Text{String: ep.Summary, Valid: true},
		Status:       pgtype.Text{String: ep.Status, Valid: true},
		CurrentStep:  pgtype.Int4{Int32: int32(ep.CurrentStep), Valid: true},
		CurrentPhase: pgtype.Text{String: ep.CurrentPhase, Valid: true},
	}
	if ep.LastActiveAt != nil {
		arg.LastActiveAt = pgtype.Timestamptz{Time: *ep.LastActiveAt, Valid: true}
	}
	_, err := s.q.UpdateEpisode(ctx, arg)
	return err
}

func (s *DBEpisodeStore) Delete(id string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteEpisode(ctx, idUUID)
}

func (s *DBEpisodeStore) CountByProject(projectID string) (int64, error) {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return 0, pkg.ErrNotFound
	}
	n, err := s.q.CountEpisodesByProject(ctx, projUUID)
	return int64(n), err
}

func (s *DBEpisodeStore) ReorderByProject(projectID string, orderedIDs []string) error {
	ctx := context.Background()
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return pkg.ErrNotFound
	}
	for i, id := range orderedIDs {
		idUUID := pkg.StrToUUID(id)
		if !idUUID.Valid {
			continue
		}
		if err := s.q.UpdateEpisodeSortIndex(ctx, db.UpdateEpisodeSortIndexParams{
			SortIndex: int32(i), ID: idUUID, ProjectID: projUUID,
		}); err != nil {
			return err
		}
	}
	return nil
}

func dbEpisodeToEpisode(row *db.Episode) *Episode {
	ep := &Episode{
		IDStr:        pkg.UUIDToStr(row.ID),
		ProjectIDStr: pkg.UUIDToStr(row.ProjectID),
		Title:        row.Title.String,
		SortIndex:    int(row.SortIndex),
		Summary:      row.Summary.String,
		Status:       row.Status,
		CurrentStep:  int(row.CurrentStep),
		CurrentPhase: row.CurrentPhase,
	}
	if row.CreatedAt.Valid {
		ep.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		ep.UpdatedAt = row.UpdatedAt.Time
	}
	if row.LastActiveAt.Valid {
		ep.LastActiveAt = &row.LastActiveAt.Time
	}
	// ep.ID 仅用于兼容，DB 模式以 IDStr 为准
	return ep
}
