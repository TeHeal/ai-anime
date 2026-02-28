package scene

import (
	"context"
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBSceneStore 基于 sqlc 的 PostgreSQL 场存储
type DBSceneStore struct {
	q *db.Queries
}

// NewDBSceneStore 创建 DBSceneStore
func NewDBSceneStore(queries *db.Queries) *DBSceneStore {
	return &DBSceneStore{q: queries}
}

func (s *DBSceneStore) Create(sc *Scene) error {
	ctx := context.Background()
	epUUID := pkg.StrToUUID(sc.EpisodeID)
	if !epUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.CreateSceneParams{
		EpisodeID:        epUUID,
		SceneID:          pgtype.Text{String: sc.SceneID, Valid: true},
		Location:         pgtype.Text{String: sc.Location, Valid: true},
		Time:             pgtype.Text{String: sc.Time, Valid: true},
		InteriorExterior: pgtype.Text{String: sc.InteriorExterior, Valid: true},
		SortIndex:        int32(sc.SortIndex),
	}
	if sc.CharactersJSON != "" {
		arg.CharactersJson = []byte(sc.CharactersJSON)
	}
	row, err := s.q.CreateScene(ctx, arg)
	if err != nil {
		return err
	}
	sc.ID = pkg.UUIDToStr(row.ID)
	sc.EpisodeID = pkg.UUIDToStr(row.EpisodeID)
	if row.CreatedAt.Valid {
		sc.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		sc.UpdatedAt = row.UpdatedAt.Time
	}
	return nil
}

func (s *DBSceneStore) FindByID(id string) (*Scene, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := s.q.GetSceneByID(ctx, idUUID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return dbSceneToScene(&row), nil
}

func (s *DBSceneStore) ListByEpisode(episodeID string) ([]Scene, error) {
	ctx := context.Background()
	epUUID := pkg.StrToUUID(episodeID)
	if !epUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	rows, err := s.q.ListScenesByEpisode(ctx, epUUID)
	if err != nil {
		return nil, err
	}
	out := make([]Scene, len(rows))
	for i := range rows {
		out[i] = *dbSceneToScene(&rows[i])
	}
	return out, nil
}

func (s *DBSceneStore) Update(sc *Scene) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(sc.ID)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateSceneParams{
		ID:               idUUID,
		SceneID:          pgtype.Text{String: sc.SceneID, Valid: true},
		Location:         pgtype.Text{String: sc.Location, Valid: true},
		Time:             pgtype.Text{String: sc.Time, Valid: true},
		InteriorExterior: pgtype.Text{String: sc.InteriorExterior, Valid: true},
		SortIndex:        pgtype.Int4{Int32: int32(sc.SortIndex), Valid: true},
	}
	if sc.CharactersJSON != "" {
		arg.CharactersJson = []byte(sc.CharactersJSON)
	}
	_, err := s.q.UpdateScene(ctx, arg)
	return err
}

func (s *DBSceneStore) Delete(id string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteScene(ctx, idUUID)
}

func (s *DBSceneStore) CountByEpisode(episodeID string) (int64, error) {
	ctx := context.Background()
	epUUID := pkg.StrToUUID(episodeID)
	if !epUUID.Valid {
		return 0, pkg.ErrNotFound
	}
	n, err := s.q.CountScenesByEpisode(ctx, epUUID)
	return int64(n), err
}

func (s *DBSceneStore) ReorderByEpisode(episodeID string, orderedIDs []string) error {
	ctx := context.Background()
	epUUID := pkg.StrToUUID(episodeID)
	if !epUUID.Valid {
		return pkg.ErrNotFound
	}
	for i, id := range orderedIDs {
		idUUID := pkg.StrToUUID(id)
		if !idUUID.Valid {
			continue
		}
		if err := s.q.UpdateSceneSortIndex(ctx, db.UpdateSceneSortIndexParams{
			SortIndex: int32(i),
			ID:        idUUID,
			EpisodeID: epUUID,
		}); err != nil {
			return err
		}
	}
	return nil
}

func dbSceneToScene(row *db.Scene) *Scene {
	sc := &Scene{
		ID:               pkg.UUIDToStr(row.ID),
		EpisodeID:        pkg.UUIDToStr(row.EpisodeID),
		SceneID:          row.SceneID.String,
		Location:         row.Location.String,
		Time:             row.Time.String,
		InteriorExterior: row.InteriorExterior.String,
		SortIndex:        int(row.SortIndex),
	}
	if len(row.CharactersJson) > 0 {
		var chars []string
		if json.Unmarshal(row.CharactersJson, &chars) == nil {
			data, _ := json.Marshal(chars)
			sc.CharactersJSON = string(data)
		}
	}
	if row.CreatedAt.Valid {
		sc.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		sc.UpdatedAt = row.UpdatedAt.Time
	}
	return sc
}

// DBSceneBlockStore 基于 sqlc 的 PostgreSQL 块存储
type DBSceneBlockStore struct {
	q *db.Queries
}

// NewDBSceneBlockStore 创建 DBSceneBlockStore
func NewDBSceneBlockStore(queries *db.Queries) *DBSceneBlockStore {
	return &DBSceneBlockStore{q: queries}
}

func (s *DBSceneBlockStore) Create(b *SceneBlock) error {
	ctx := context.Background()
	sceneUUID := pkg.StrToUUID(b.SceneID)
	if !sceneUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.CreateSceneBlockParams{
		SceneID:   sceneUUID,
		Type:      b.Type,
		Character: pgtype.Text{String: b.Character, Valid: true},
		Emotion:   pgtype.Text{String: b.Emotion, Valid: true},
		Content:   b.Content,
		SortIndex: int32(b.SortIndex),
	}
	row, err := s.q.CreateSceneBlock(ctx, arg)
	if err != nil {
		return err
	}
	b.ID = pkg.UUIDToStr(row.ID)
	b.SceneID = pkg.UUIDToStr(row.SceneID)
	if row.CreatedAt.Valid {
		b.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		b.UpdatedAt = row.UpdatedAt.Time
	}
	return nil
}

func (s *DBSceneBlockStore) BulkCreate(blocks []SceneBlock) error {
	for i := range blocks {
		if err := s.Create(&blocks[i]); err != nil {
			return err
		}
	}
	return nil
}

func (s *DBSceneBlockStore) FindByID(id string) (*SceneBlock, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := s.q.GetSceneBlockByID(ctx, idUUID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return dbSceneBlockToSceneBlock(&row), nil
}

func (s *DBSceneBlockStore) ListByScene(sceneID string) ([]SceneBlock, error) {
	ctx := context.Background()
	sceneUUID := pkg.StrToUUID(sceneID)
	if !sceneUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	rows, err := s.q.ListSceneBlocksByScene(ctx, sceneUUID)
	if err != nil {
		return nil, err
	}
	out := make([]SceneBlock, len(rows))
	for i := range rows {
		out[i] = *dbSceneBlockToSceneBlock(&rows[i])
	}
	return out, nil
}

func (s *DBSceneBlockStore) Update(b *SceneBlock) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(b.ID)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateSceneBlockParams{
		ID:        idUUID,
		Type:      pgtype.Text{String: b.Type, Valid: true},
		Character: pgtype.Text{String: b.Character, Valid: true},
		Emotion:   pgtype.Text{String: b.Emotion, Valid: true},
		Content:   pgtype.Text{String: b.Content, Valid: true},
		SortIndex: pgtype.Int4{Int32: int32(b.SortIndex), Valid: true},
	}
	_, err := s.q.UpdateSceneBlock(ctx, arg)
	return err
}

func (s *DBSceneBlockStore) Delete(id string) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteSceneBlock(ctx, idUUID)
}

func (s *DBSceneBlockStore) DeleteByScene(sceneID string) error {
	ctx := context.Background()
	sceneUUID := pkg.StrToUUID(sceneID)
	if !sceneUUID.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteSceneBlocksByScene(ctx, sceneUUID)
}

func (s *DBSceneBlockStore) CountByScene(sceneID string) (int64, error) {
	ctx := context.Background()
	sceneUUID := pkg.StrToUUID(sceneID)
	if !sceneUUID.Valid {
		return 0, pkg.ErrNotFound
	}
	n, err := s.q.CountSceneBlocksByScene(ctx, sceneUUID)
	return int64(n), err
}

func (s *DBSceneBlockStore) ReorderByScene(sceneID string, orderedIDs []string) error {
	ctx := context.Background()
	sceneUUID := pkg.StrToUUID(sceneID)
	if !sceneUUID.Valid {
		return pkg.ErrNotFound
	}
	for i, id := range orderedIDs {
		idUUID := pkg.StrToUUID(id)
		if !idUUID.Valid {
			continue
		}
		if err := s.q.UpdateSceneBlockSortIndex(ctx, db.UpdateSceneBlockSortIndexParams{
			SortIndex: int32(i),
			ID:        idUUID,
			SceneID:   sceneUUID,
		}); err != nil {
			return err
		}
	}
	return nil
}

func dbSceneBlockToSceneBlock(row *db.SceneBlock) *SceneBlock {
	b := &SceneBlock{
		ID:        pkg.UUIDToStr(row.ID),
		SceneID:   pkg.UUIDToStr(row.SceneID),
		Type:      row.Type,
		Character: row.Character.String,
		Emotion:   row.Emotion.String,
		Content:   row.Content,
		SortIndex: int(row.SortIndex),
	}
	if row.CreatedAt.Valid {
		b.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		b.UpdatedAt = row.UpdatedAt.Time
	}
	return b
}
