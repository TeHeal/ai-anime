package shot_image

import (
	"context"
	"errors"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBShotImageStore 基于 sqlc 的镜图存储，封装 shot_images 表
type DBShotImageStore struct {
	q *db.Queries
}

// NewDBShotImageStore 创建 DB 镜图存储
func NewDBShotImageStore(q *db.Queries) *DBShotImageStore {
	return &DBShotImageStore{q: q}
}

// Create 创建镜图
func (s *DBShotImageStore) Create(img *ShotImage) error {
	ctx := context.Background()
	arg := db.CreateShotImageParams{
		ShotID:         pkg.ParseUUID(img.ShotID),
		ProjectID:      pkg.ParseUUID(img.ProjectID),
		ImageUrl:       img.ImageURL,
		TaskID:         pgtype.Text{String: img.TaskID, Valid: true},
		Status:         img.Status,
		Provider:       pgtype.Text{Valid: false},
		Model:          pgtype.Text{Valid: false},
		Prompt:         pgtype.Text{Valid: false},
		NegativePrompt: pgtype.Text{Valid: false},
		ReviewStatus:   pgtype.Text{String: img.ReviewStatus, Valid: true},
		ReviewComment:  pgtype.Text{String: img.ReviewComment, Valid: true},
		ReviewedAt:     timeToPgtype(img.ReviewedAt),
		ReviewedBy:     uuidOrNull(img.ReviewedBy),
	}
	out, err := s.q.CreateShotImage(ctx, arg)
	if err != nil {
		return err
	}
	dbToShotImage(&out, img)
	return nil
}

// BulkCreate 批量创建镜图（逐条插入）
func (s *DBShotImageStore) BulkCreate(images []ShotImage) error {
	for i := range images {
		if err := s.Create(&images[i]); err != nil {
			return err
		}
	}
	return nil
}

// FindByID 按 ID 查询
func (s *DBShotImageStore) FindByID(id string) (*ShotImage, error) {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	out, err := s.q.GetShotImageByID(ctx, uid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pkg.ErrNotFound
		}
		return nil, err
	}
	img := dbShotImageToModule(&out)
	return &img, nil
}

// ListByShot 按镜头列出
func (s *DBShotImageStore) ListByShot(shotID string) ([]ShotImage, error) {
	ctx := context.Background()
	sid := pkg.ParseUUID(shotID)
	if !sid.Valid {
		return nil, nil
	}
	list, err := s.q.ListShotImagesByShot(ctx, sid)
	if err != nil {
		return nil, err
	}
	return dbShotImagesToModule(list), nil
}

// ListByProject 按项目列出
func (s *DBShotImageStore) ListByProject(projectID string) ([]ShotImage, error) {
	ctx := context.Background()
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, nil
	}
	list, err := s.q.ListShotImagesByProject(ctx, pid)
	if err != nil {
		return nil, err
	}
	return dbShotImagesToModule(list), nil
}

// Update 更新镜图
func (s *DBShotImageStore) Update(img *ShotImage) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(img.ID)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateShotImageParams{
		ID:             uid,
		ImageUrl:       pgtype.Text{String: img.ImageURL, Valid: true},
		TaskID:         pgtype.Text{String: img.TaskID, Valid: true},
		Status:         pgtype.Text{String: img.Status, Valid: true},
		ReviewStatus:   pgtype.Text{String: img.ReviewStatus, Valid: true},
		ReviewComment:  pgtype.Text{String: img.ReviewComment, Valid: true},
		ReviewedAt:     timeToPgtype(img.ReviewedAt),
		ReviewedBy:     uuidOrNull(img.ReviewedBy),
	}
	_, err := s.q.UpdateShotImage(ctx, arg)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return pkg.ErrNotFound
		}
		return err
	}
	return nil
}

// Delete 软删除
func (s *DBShotImageStore) Delete(id string) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteShotImage(ctx, uid)
}

// DeleteByShot 按镜头软删除
func (s *DBShotImageStore) DeleteByShot(shotID string) error {
	ctx := context.Background()
	sid := pkg.ParseUUID(shotID)
	if !sid.Valid {
		return nil
	}
	return s.q.SoftDeleteShotImagesByShot(ctx, sid)
}

// 辅助：db.ShotImage -> module.ShotImage
func dbShotImageToModule(d *db.ShotImage) ShotImage {
	img := ShotImage{
		ID:            pkg.UUIDString(d.ID),
		ShotID:        pkg.UUIDString(d.ShotID),
		ProjectID:     pkg.UUIDString(d.ProjectID),
		ImageURL:      d.ImageUrl,
		TaskID:        textStr(d.TaskID),
		Status:        d.Status,
		SortIndex:     int(d.Version),
		ReviewStatus:  textStr(d.ReviewStatus),
		ReviewComment: textStr(d.ReviewComment),
	}
	img.CreatedAt = d.CreatedAt.Time
	img.UpdatedAt = d.UpdatedAt.Time
	img.ReviewedAt = timePtr(d.ReviewedAt)
	img.ReviewedBy = uuidPtr(d.ReviewedBy)
	return img
}

func dbShotImagesToModule(list []db.ShotImage) []ShotImage {
	out := make([]ShotImage, len(list))
	for i := range list {
		out[i] = dbShotImageToModule(&list[i])
	}
	return out
}

func dbToShotImage(d *db.ShotImage, img *ShotImage) {
	img.ID = pkg.UUIDString(d.ID)
	img.ShotID = pkg.UUIDString(d.ShotID)
	img.ProjectID = pkg.UUIDString(d.ProjectID)
	img.CreatedAt = d.CreatedAt.Time
	img.UpdatedAt = d.UpdatedAt.Time
	img.ImageURL = d.ImageUrl
	img.TaskID = textStr(d.TaskID)
	img.Status = d.Status
	img.SortIndex = int(d.Version)
	img.ReviewStatus = textStr(d.ReviewStatus)
	img.ReviewComment = textStr(d.ReviewComment)
	img.ReviewedAt = timePtr(d.ReviewedAt)
	img.ReviewedBy = uuidPtr(d.ReviewedBy)
}

func textStr(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

func uuidOrNull(s *string) pgtype.UUID {
	if s == nil || *s == "" {
		return pgtype.UUID{Valid: false}
	}
	return pkg.ParseUUID(*s)
}

func uuidPtr(u pgtype.UUID) *string {
	if !u.Valid {
		return nil
	}
	s := pkg.UUIDString(u)
	return &s
}

func timeToPgtype(t *time.Time) pgtype.Timestamptz {
	if t == nil {
		return pgtype.Timestamptz{Valid: false}
	}
	return pgtype.Timestamptz{Time: *t, Valid: true}
}

func timePtr(t pgtype.Timestamptz) *time.Time {
	if !t.Valid {
		return nil
	}
	return &t.Time
}
