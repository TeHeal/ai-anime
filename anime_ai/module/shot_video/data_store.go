package shot_video

import (
	"context"
	"errors"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBShotVideoStore 基于 sqlc 的镜头视频存储
type DBShotVideoStore struct {
	q *db.Queries
}

// NewDBShotVideoStore 创建 DB 镜头视频存储
func NewDBShotVideoStore(q *db.Queries) *DBShotVideoStore {
	return &DBShotVideoStore{q: q}
}

func (s *DBShotVideoStore) Create(ctx context.Context, v *ShotVideo) error {
	arg := db.CreateShotVideoParams{
		ShotID:        pkg.ParseUUID(v.ShotID),
		ProjectID:     pkg.ParseUUID(v.ProjectID),
		VideoUrl:      v.VideoURL,
		TaskID:        pgtype.Text{String: v.TaskID, Valid: v.TaskID != ""},
		Status:        v.Status,
		Duration:      int32(v.Duration),
		Provider:      pgtype.Text{String: v.Provider, Valid: v.Provider != ""},
		Model:         pgtype.Text{String: v.Model, Valid: v.Model != ""},
		ReviewStatus:  pgtype.Text{String: v.ReviewStatus, Valid: true},
		ReviewComment: pgtype.Text{String: v.ReviewComment, Valid: true},
	}
	if v.ShotImageID != nil && *v.ShotImageID != "" {
		arg.ShotImageID = pkg.ParseUUID(*v.ShotImageID)
	}
	out, err := s.q.CreateShotVideo(ctx, arg)
	if err != nil {
		return err
	}
	dbToShotVideo(&out, v)
	return nil
}

func (s *DBShotVideoStore) FindByID(ctx context.Context, id string) (*ShotVideo, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	out, err := s.q.GetShotVideoByID(ctx, uid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pkg.ErrNotFound
		}
		return nil, err
	}
	v := &ShotVideo{}
	dbToShotVideo(&out, v)
	return v, nil
}

func (s *DBShotVideoStore) ListByShot(ctx context.Context, shotID string) ([]ShotVideo, error) {
	sid := pkg.ParseUUID(shotID)
	if !sid.Valid {
		return nil, nil
	}
	list, err := s.q.ListShotVideosByShot(ctx, sid)
	if err != nil {
		return nil, err
	}
	return dbListToShotVideos(list), nil
}

func (s *DBShotVideoStore) ListByProject(ctx context.Context, projectID string) ([]ShotVideo, error) {
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, nil
	}
	list, err := s.q.ListShotVideosByProject(ctx, pid)
	if err != nil {
		return nil, err
	}
	return dbListToShotVideos(list), nil
}

func (s *DBShotVideoStore) Update(ctx context.Context, v *ShotVideo) error {
	uid := pkg.ParseUUID(v.ID)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	var shotImageID pgtype.UUID
	if v.ShotImageID != nil && *v.ShotImageID != "" {
		shotImageID = pkg.ParseUUID(*v.ShotImageID)
	}
	arg := db.UpdateShotVideoParams{
		ID:            uid,
		ShotImageID:   shotImageID,
		VideoUrl:      pgtype.Text{String: v.VideoURL, Valid: true},
		TaskID:        pgtype.Text{String: v.TaskID, Valid: true},
		Status:        pgtype.Text{String: v.Status, Valid: true},
		Duration:      pgtype.Int4{Int32: int32(v.Duration), Valid: true},
		ReviewStatus:  pgtype.Text{String: v.ReviewStatus, Valid: true},
		ReviewComment: pgtype.Text{String: v.ReviewComment, Valid: true},
	}
	if v.ReviewedAt != nil {
		arg.ReviewedAt = pgtype.Timestamptz{Time: *v.ReviewedAt, Valid: true}
	}
	if v.ReviewedBy != nil && *v.ReviewedBy != "" {
		arg.ReviewedBy = pkg.ParseUUID(*v.ReviewedBy)
	}
	_, err := s.q.UpdateShotVideo(ctx, arg)
	return err
}

func (s *DBShotVideoStore) UpdateStatus(ctx context.Context, id, status, videoURL, taskID string) error {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateShotVideoStatusParams{
		ID:       uid,
		VideoUrl: pgtype.Text{String: videoURL, Valid: videoURL != ""},
		TaskID:   pgtype.Text{String: taskID, Valid: taskID != ""},
		Status:   pgtype.Text{String: status, Valid: status != ""},
	}
	_, err := s.q.UpdateShotVideoStatus(ctx, arg)
	return err
}

func (s *DBShotVideoStore) UpdateReview(ctx context.Context, id, status, comment string, reviewedBy *string) error {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateShotVideoReviewParams{
		ID:            uid,
		ReviewStatus:  pgtype.Text{String: status, Valid: true},
		ReviewComment: pgtype.Text{String: comment, Valid: true},
		ReviewedAt:    pgtype.Timestamptz{Time: time.Now(), Valid: true},
	}
	if reviewedBy != nil && *reviewedBy != "" {
		arg.ReviewedBy = pkg.ParseUUID(*reviewedBy)
	}
	_, err := s.q.UpdateShotVideoReview(ctx, arg)
	return err
}

func (s *DBShotVideoStore) Delete(ctx context.Context, id string) error {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteShotVideo(ctx, uid)
}

func dbToShotVideo(d *db.ShotVideo, v *ShotVideo) *ShotVideo {
	v.ID = pkg.UUIDString(d.ID)
	v.ShotID = pkg.UUIDString(d.ShotID)
	v.ProjectID = pkg.UUIDString(d.ProjectID)
	v.VideoURL = d.VideoUrl
	v.TaskID = textStr(d.TaskID)
	v.Status = d.Status
	v.Duration = int(d.Duration)
	v.Provider = textStr(d.Provider)
	v.Model = textStr(d.Model)
	v.Version = int(d.Version)
	v.ReviewStatus = textStr(d.ReviewStatus)
	v.ReviewComment = textStr(d.ReviewComment)
	if d.CreatedAt.Valid {
		v.CreatedAt = d.CreatedAt.Time
	}
	if d.UpdatedAt.Valid {
		v.UpdatedAt = d.UpdatedAt.Time
	}
	if d.ShotImageID.Valid {
		s := pkg.UUIDString(d.ShotImageID)
		v.ShotImageID = &s
	}
	if d.ReviewedAt.Valid {
		v.ReviewedAt = &d.ReviewedAt.Time
	}
	if d.ReviewedBy.Valid {
		s := pkg.UUIDString(d.ReviewedBy)
		v.ReviewedBy = &s
	}
	return v
}

func dbListToShotVideos(list []db.ShotVideo) []ShotVideo {
	out := make([]ShotVideo, len(list))
	for i := range list {
		dbToShotVideo(&list[i], &out[i])
	}
	return out
}

func textStr(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

var _ Store = (*DBShotVideoStore)(nil)

// ExportShotVideoReaderAdapter 实现 crossmodule.ExportShotVideoReader，供成片导出 Worker 注入
func ExportShotVideoReaderAdapter(store Store) crossmodule.ExportShotVideoReader {
	return &exportShotVideoReaderAdapter{store: store}
}

type exportShotVideoReaderAdapter struct {
	store Store
}

// GetLatestApprovedVideo 获取镜头最新的已完成视频（优先 approved，其次 completed）
func (a *exportShotVideoReaderAdapter) GetLatestApprovedVideo(ctx context.Context, shotID string) (*crossmodule.ExportShotVideoInfo, error) {
	videos, err := a.store.ListByShot(ctx, shotID)
	if err != nil {
		return nil, err
	}
	// 优先选择 approved 状态，其次 completed 状态，取最新的
	var best *ShotVideo
	for i := range videos {
		v := &videos[i]
		if v.VideoURL == "" {
			continue
		}
		if v.ReviewStatus == "approved" {
			if best == nil || best.ReviewStatus != "approved" || v.CreatedAt.After(best.CreatedAt) {
				best = v
			}
		} else if v.Status == "completed" && (best == nil || best.ReviewStatus != "approved") {
			if best == nil || v.CreatedAt.After(best.CreatedAt) {
				best = v
			}
		}
	}
	if best == nil {
		return nil, nil
	}
	return &crossmodule.ExportShotVideoInfo{
		ID:       best.ID,
		ShotID:   best.ShotID,
		VideoURL: best.VideoURL,
		Status:   best.Status,
		Duration: best.Duration,
	}, nil
}
