package shot

import (
	"context"
	"errors"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBShotStore 基于 sqlc 的镜头存储，封装 shots 表
type DBShotStore struct {
	q *db.Queries
}

// NewDBShotStore 创建 DB 镜头存储
func NewDBShotStore(q *db.Queries) *DBShotStore {
	return &DBShotStore{q: q}
}

// Create 创建镜头
func (s *DBShotStore) Create(sh *Shot) error {
	ctx := context.Background()
	arg := db.CreateShotParams{
		ProjectID:      pkg.ParseUUID(sh.ProjectID),
		SegmentID:      uuidOrNull(sh.SegmentID),
		SceneID:        uuidOrNull(sh.SceneID),
		SortIndex:      int32(sh.SortIndex),
		Prompt:         pgtype.Text{String: sh.Prompt, Valid: true},
		StylePrompt:    pgtype.Text{String: sh.StylePrompt, Valid: true},
		ImageUrl:       pgtype.Text{String: sh.ImageURL, Valid: true},
		VideoUrl:       pgtype.Text{String: sh.VideoURL, Valid: true},
		TaskID:         pgtype.Text{String: sh.TaskID, Valid: true},
		Status:         sh.Status,
		Duration:       int32(sh.Duration),
		CameraType:     pgtype.Text{String: sh.CameraType, Valid: true},
		CameraAngle:    pgtype.Text{String: sh.CameraAngle, Valid: true},
		Dialogue:       pgtype.Text{String: sh.Dialogue, Valid: true},
		CharacterName:  pgtype.Text{String: sh.CharacterName, Valid: true},
		CharacterID:    uuidOrNull(sh.CharacterID),
		Emotion:        pgtype.Text{String: sh.Emotion, Valid: true},
		Voice:          pgtype.Text{String: sh.Voice, Valid: true},
		VoiceName:      pgtype.Text{String: sh.VoiceName, Valid: true},
		LipSync:        sh.LipSync,
		Transition:     pgtype.Text{String: sh.Transition, Valid: true},
		AudioDesign:    pgtype.Text{String: sh.AudioDesign, Valid: true},
		Priority:       pgtype.Text{String: sh.Priority, Valid: true},
		NegativePrompt: pgtype.Text{String: sh.NegativePrompt, Valid: true},
		LockedBy:       pgtype.UUID{Valid: false},
		LockedAt:       pgtype.Timestamptz{Valid: false},
		ReviewStatus:   pgtype.Text{String: sh.ReviewStatus, Valid: true},
		ReviewComment:  pgtype.Text{String: sh.ReviewComment, Valid: true},
		ReviewedAt:     timeToPgtype(sh.ReviewedAt),
		ReviewedBy:     uuidOrNull(sh.ReviewedBy),
	}
	out, err := s.q.CreateShot(ctx, arg)
	if err != nil {
		return err
	}
	dbToShot(&out, sh)
	return nil
}

// BulkCreate 批量创建镜头（逐条插入，sch 无 copyfrom）
func (s *DBShotStore) BulkCreate(shots []Shot) error {
	for i := range shots {
		if err := s.Create(&shots[i]); err != nil {
			return err
		}
	}
	return nil
}

// FindByID 按 ID 查询
func (s *DBShotStore) FindByID(id string) (*Shot, error) {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	out, err := s.q.GetShotByID(ctx, uid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pkg.ErrNotFound
		}
		return nil, err
	}
	sh := dbShotToModule(&out)
	return &sh, nil
}

// ListByProject 按项目列出
func (s *DBShotStore) ListByProject(projectID string) ([]Shot, error) {
	ctx := context.Background()
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil, nil
	}
	list, err := s.q.ListShotsByProject(ctx, pid)
	if err != nil {
		return nil, err
	}
	return dbShotsToModule(list), nil
}

// ListByProjectFiltered 按项目与审核状态列出
func (s *DBShotStore) ListByProjectFiltered(projectID string, reviewStatus string) ([]Shot, error) {
	all, err := s.ListByProject(projectID)
	if err != nil {
		return nil, err
	}
	if reviewStatus == "" {
		return all, nil
	}
	out := make([]Shot, 0, len(all))
	for _, sh := range all {
		if sh.ReviewStatus == reviewStatus {
			out = append(out, sh)
		}
	}
	return out, nil
}

// Update 更新镜头
func (s *DBShotStore) Update(sh *Shot) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(sh.ID)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateShotParams{
		ID:             uid,
		SegmentID:      uuidOrNull(sh.SegmentID),
		SceneID:        uuidOrNull(sh.SceneID),
		SortIndex:      pgtype.Int4{Int32: int32(sh.SortIndex), Valid: true},
		Prompt:         pgtype.Text{String: sh.Prompt, Valid: true},
		StylePrompt:    pgtype.Text{String: sh.StylePrompt, Valid: true},
		ImageUrl:       pgtype.Text{String: sh.ImageURL, Valid: true},
		VideoUrl:       pgtype.Text{String: sh.VideoURL, Valid: true},
		TaskID:         pgtype.Text{String: sh.TaskID, Valid: true},
		Status:         pgtype.Text{String: sh.Status, Valid: true},
		Duration:       pgtype.Int4{Int32: int32(sh.Duration), Valid: true},
		CameraType:     pgtype.Text{String: sh.CameraType, Valid: true},
		CameraAngle:    pgtype.Text{String: sh.CameraAngle, Valid: true},
		Dialogue:       pgtype.Text{String: sh.Dialogue, Valid: true},
		CharacterName:  pgtype.Text{String: sh.CharacterName, Valid: true},
		CharacterID:    uuidOrNull(sh.CharacterID),
		Emotion:        pgtype.Text{String: sh.Emotion, Valid: true},
		Voice:          pgtype.Text{String: sh.Voice, Valid: true},
		VoiceName:      pgtype.Text{String: sh.VoiceName, Valid: true},
		LipSync:        pgtype.Text{String: sh.LipSync, Valid: true},
		Transition:     pgtype.Text{String: sh.Transition, Valid: true},
		AudioDesign:    pgtype.Text{String: sh.AudioDesign, Valid: true},
		Priority:       pgtype.Text{String: sh.Priority, Valid: true},
		NegativePrompt: pgtype.Text{String: sh.NegativePrompt, Valid: true},
		ReviewStatus:   pgtype.Text{String: sh.ReviewStatus, Valid: true},
		ReviewComment:  pgtype.Text{String: sh.ReviewComment, Valid: true},
		ReviewedAt:     timeToPgtype(sh.ReviewedAt),
		ReviewedBy:     uuidOrNull(sh.ReviewedBy),
	}
	out, err := s.q.UpdateShot(ctx, arg)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return pkg.ErrNotFound
		}
		return err
	}
	dbToShot(&out, sh)
	return nil
}

// Delete 软删除
func (s *DBShotStore) Delete(id string) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return s.q.SoftDeleteShot(ctx, uid)
}

// CountByProject 统计项目镜头数
func (s *DBShotStore) CountByProject(projectID string) (int64, error) {
	ctx := context.Background()
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return 0, nil
	}
	n, err := s.q.CountShotsByProject(ctx, pid)
	if err != nil {
		return 0, err
	}
	return int64(n), nil
}

// ReorderByProject 按顺序更新 sort_index
func (s *DBShotStore) ReorderByProject(projectID string, orderedIDs []string) error {
	ctx := context.Background()
	pid := pkg.ParseUUID(projectID)
	if !pid.Valid {
		return nil
	}
	for i, id := range orderedIDs {
		uid := pkg.ParseUUID(id)
		if !uid.Valid {
			continue
		}
		if err := s.q.UpdateShotSortIndex(ctx, db.UpdateShotSortIndexParams{
			SortIndex: int32(i),
			ID:        uid,
			ProjectID: pid,
		}); err != nil {
			return err
		}
	}
	return nil
}

// BatchFindByIDs 批量按 ID 查询
func (s *DBShotStore) BatchFindByIDs(ids []string) ([]Shot, error) {
	out := make([]Shot, 0, len(ids))
	for _, id := range ids {
		sh, err := s.FindByID(id)
		if err != nil {
			continue
		}
		out = append(out, *sh)
	}
	return out, nil
}

// UpdateImageURL 更新镜头图片 URL
func (s *DBShotStore) UpdateImageURL(id string, imageURL string) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	_, err := s.q.UpdateShotImageResult(ctx, db.UpdateShotImageResultParams{
		ID:       uid,
		ImageUrl: pgtype.Text{String: imageURL, Valid: true},
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return pkg.ErrNotFound
		}
		return err
	}
	return nil
}

// UpdateReviewStatus 更新审核状态
func (s *DBShotStore) UpdateReviewStatus(id string, status, comment string) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	_, err := s.q.UpdateShotReview(ctx, db.UpdateShotReviewParams{
		ID:            uid,
		ReviewStatus:  pgtype.Text{String: status, Valid: true},
		ReviewComment: pgtype.Text{String: comment, Valid: true},
		ReviewedAt:    pgtype.Timestamptz{Time: time.Now(), Valid: true},
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return pkg.ErrNotFound
		}
		return err
	}
	return nil
}

// BatchUpdateReviewStatus 批量更新审核状态
func (s *DBShotStore) BatchUpdateReviewStatus(ids []string, status string) error {
	for _, id := range ids {
		if err := s.UpdateReviewStatus(id, status, ""); err != nil {
			return err
		}
	}
	return nil
}

// 辅助：db.Shot -> module.Shot
func dbShotToModule(d *db.Shot) Shot {
	sh := Shot{
		ID:           pkg.UUIDString(d.ID),
		ProjectID:    pkg.UUIDString(d.ProjectID),
		SortIndex:    int(d.SortIndex),
		Prompt:       textStr(d.Prompt),
		StylePrompt:  textStr(d.StylePrompt),
		ImageURL:     textStr(d.ImageUrl),
		VideoURL:     textStr(d.VideoUrl),
		TaskID:       textStr(d.TaskID),
		Status:       d.Status,
		Duration:     int(d.Duration),
		CameraType:   textStr(d.CameraType),
		CameraAngle:  textStr(d.CameraAngle),
		Dialogue:     textStr(d.Dialogue),
		CharacterName: textStr(d.CharacterName),
		Emotion:      textStr(d.Emotion),
		Voice:        textStr(d.Voice),
		VoiceName:    textStr(d.VoiceName),
		LipSync:      textStr(d.LipSync),
		Transition:   textStr(d.Transition),
		AudioDesign:  textStr(d.AudioDesign),
		Priority:     textStr(d.Priority),
		NegativePrompt: textStr(d.NegativePrompt),
		ReviewStatus:  textStr(d.ReviewStatus),
		ReviewComment: textStr(d.ReviewComment),
	}
	sh.CreatedAt = d.CreatedAt.Time
	sh.UpdatedAt = d.UpdatedAt.Time
	sh.SegmentID = uuidPtr(d.SegmentID)
	sh.SceneID = uuidPtr(d.SceneID)
	sh.CharacterID = uuidPtr(d.CharacterID)
	sh.ReviewedAt = timePtr(d.ReviewedAt)
	sh.ReviewedBy = uuidPtr(d.ReviewedBy)
	return sh
}

func dbShotsToModule(list []db.Shot) []Shot {
	out := make([]Shot, len(list))
	for i := range list {
		out[i] = dbShotToModule(&list[i])
	}
	return out
}

func dbToShot(d *db.Shot, sh *Shot) {
	sh.ID = pkg.UUIDString(d.ID)
	sh.ProjectID = pkg.UUIDString(d.ProjectID)
	sh.CreatedAt = d.CreatedAt.Time
	sh.UpdatedAt = d.UpdatedAt.Time
	sh.SegmentID = uuidPtr(d.SegmentID)
	sh.SceneID = uuidPtr(d.SceneID)
	sh.SortIndex = int(d.SortIndex)
	sh.Prompt = textStr(d.Prompt)
	sh.StylePrompt = textStr(d.StylePrompt)
	sh.ImageURL = textStr(d.ImageUrl)
	sh.VideoURL = textStr(d.VideoUrl)
	sh.TaskID = textStr(d.TaskID)
	sh.Status = d.Status
	sh.Duration = int(d.Duration)
	sh.CameraType = textStr(d.CameraType)
	sh.CameraAngle = textStr(d.CameraAngle)
	sh.Dialogue = textStr(d.Dialogue)
	sh.CharacterName = textStr(d.CharacterName)
	sh.CharacterID = uuidPtr(d.CharacterID)
	sh.Emotion = textStr(d.Emotion)
	sh.Voice = textStr(d.Voice)
	sh.VoiceName = textStr(d.VoiceName)
	sh.LipSync = textStr(d.LipSync)
	sh.Transition = textStr(d.Transition)
	sh.AudioDesign = textStr(d.AudioDesign)
	sh.Priority = textStr(d.Priority)
	sh.NegativePrompt = textStr(d.NegativePrompt)
	sh.ReviewStatus = textStr(d.ReviewStatus)
	sh.ReviewComment = textStr(d.ReviewComment)
	sh.ReviewedAt = timePtr(d.ReviewedAt)
	sh.ReviewedBy = uuidPtr(d.ReviewedBy)
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
