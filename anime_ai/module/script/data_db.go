package script

import (
	"context"
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBSegmentStore 基于 sch/db sqlc 的分段数据实现
type DBSegmentStore struct {
	q *db.Queries
}

// NewDBSegmentStore 创建基于 sqlc 的 SegmentStore 实例
func NewDBSegmentStore(queries *db.Queries) *DBSegmentStore {
	return &DBSegmentStore{q: queries}
}

// Create 创建分段
func (s *DBSegmentStore) Create(seg *Segment) error {
	ctx := context.Background()
	arg := db.CreateSegmentParams{
		ProjectID: pkg.UintToUUID(seg.ProjectID),
		SortIndex: int32(seg.SortIndex),
		Content:   pgtype.Text{String: seg.Content, Valid: true},
	}
	row, err := s.q.CreateSegment(ctx, arg)
	if err != nil {
		return err
	}
	dbToSegment(&row, seg)
	return nil
}

// BulkCreate 批量创建分段
func (s *DBSegmentStore) BulkCreate(segments []Segment) error {
	if len(segments) == 0 {
		return nil
	}
	ctx := context.Background()
	args := make([]db.BulkCreateSegmentsParams, len(segments))
	for i := range segments {
		args[i] = db.BulkCreateSegmentsParams{
			ProjectID: pkg.UintToUUID(segments[i].ProjectID),
			SortIndex: int32(segments[i].SortIndex),
			Content:   pgtype.Text{String: segments[i].Content, Valid: true},
		}
	}
	_, err := s.q.BulkCreateSegments(ctx, args)
	if err != nil {
		return err
	}
	// BulkCreate 不返回 ID，需重新 List 获取
	return nil
}

// FindByID 按 ID 查询分段
func (s *DBSegmentStore) FindByID(id string) (*Segment, error) {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := s.q.GetSegmentByID(ctx, uid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pkg.ErrNotFound
		}
		return nil, err
	}
	seg := &Segment{}
	dbToSegment(&row, seg)
	return seg, nil
}

// ListByProject 按项目列出分段
func (s *DBSegmentStore) ListByProject(projectID uint) ([]Segment, error) {
	ctx := context.Background()
	pid := pkg.UintToUUID(projectID)
	rows, err := s.q.ListSegmentsByProject(ctx, pid)
	if err != nil {
		return nil, err
	}
	out := make([]Segment, len(rows))
	for i := range rows {
		dbToSegment(&rows[i], &out[i])
	}
	return out, nil
}

// Update 更新分段
func (s *DBSegmentStore) Update(seg *Segment) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(seg.ID)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateSegmentParams{
		ID:        uid,
		SortIndex: pgtype.Int4{Int32: int32(seg.SortIndex), Valid: true},
		Content:   pgtype.Text{String: seg.Content, Valid: true},
	}
	_, err := s.q.UpdateSegment(ctx, arg)
	return err
}

// Delete 软删除分段
func (s *DBSegmentStore) Delete(id string) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteSegment(ctx, uid)
}

// DeleteByProject 按项目软删除所有分段
func (s *DBSegmentStore) DeleteByProject(projectID uint) error {
	ctx := context.Background()
	pid := pkg.UintToUUID(projectID)
	return s.q.SoftDeleteSegmentsByProject(ctx, pid)
}

// ReorderByProject 按指定顺序重排分段
func (s *DBSegmentStore) ReorderByProject(projectID uint, orderedIDs []string) error {
	ctx := context.Background()
	pid := pkg.UintToUUID(projectID)
	for i, id := range orderedIDs {
		uid := pkg.ParseUUID(id)
		if !uid.Valid {
			continue
		}
		if err := s.q.UpdateSegmentSortIndex(ctx, db.UpdateSegmentSortIndexParams{
			SortIndex: int32(i),
			ID:        uid,
			ProjectID: pid,
		}); err != nil {
			return err
		}
	}
	return nil
}

func dbToSegment(row *db.Segment, seg *Segment) {
	seg.ID = pkg.UUIDString(row.ID)
	seg.ProjectID = pkg.UUIDToUint(row.ProjectID)
	seg.SortIndex = int(row.SortIndex)
	seg.Content = textVal(row.Content)
	seg.CreatedAt = row.CreatedAt.Time
	seg.UpdatedAt = row.UpdatedAt.Time
}

func textVal(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}
