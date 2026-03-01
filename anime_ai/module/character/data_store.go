package character

import (
	"context"
	"errors"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBData 基于 sch/db sqlc 的角色数据实现，仅实现 characters 表
// 角色快照仍委托给 MemData（character_snapshots 表若不存在）
type DBData struct {
	q         *db.Queries
	snapshots *MemData
}

// NewDBData 创建基于 sqlc 的 Data 实例
func NewDBData(queries *db.Queries) *DBData {
	return &DBData{
		q:         queries,
		snapshots: NewMemData(),
	}
}

// CreateCharacter 创建角色
// c.UserID、c.ProjectID 需为 UUID 字符串（可由 pkg.UUIDString(pkg.UintToUUID(id)) 生成）
func (d *DBData) CreateCharacter(c *Character) error {
	ctx := context.Background()
	projectID := pkg.UintToUUID(0)
	if c.ProjectID != nil && *c.ProjectID != "" {
		pid := pkg.ParseUUID(*c.ProjectID)
		if pid.Valid {
			projectID = pid
		}
	}
	userID := pkg.ParseUUID(c.UserID)
	if !userID.Valid {
		userID = pkg.UintToUUID(0)
	}
	arg := db.CreateCharacterParams{
		ProjectID:            projectID,
		UserID:               userID,
		Name:                 c.Name,
		AliasJson:            jsonRaw(c.AliasJSON),
		Appearance:           pgText(c.Appearance),
		Style:                pgText(c.Style),
		StyleOverride:        c.StyleOverride,
		Personality:          pgText(c.Personality),
		VoiceHint:            pgText(c.VoiceHint),
		Emotions:             pgText(c.Emotions),
		Scenes:               pgText(c.Scenes),
		Gender:               pgText(c.Gender),
		AgeGroup:             pgText(c.AgeGroup),
		VoiceID:              pgText(c.VoiceID),
		VoiceName:            pgText(c.VoiceName),
		ImageUrl:              pgText(c.ImageURL),
		ReferenceImagesJson:   jsonRaw(c.ReferenceImagesJSON),
		TaskID:                pgText(c.TaskID),
		ImageStatus:           c.ImageStatus,
		Shared:                c.Shared,
		Status:                c.Status,
		Source:                c.Source,
		VariantsJson:          jsonRaw(c.VariantsJSON),
		Importance:            pgText(c.Importance),
		Consistency:           pgText(c.Consistency),
		RoleType:              pgText(c.RoleType),
		TagsJson:              jsonRaw(c.TagsJSON),
		PropsJson:             jsonRaw(c.PropsJSON),
		Bio:                   pgText(c.Bio),
		BioFragmentsJson:      jsonRaw(c.BioFragmentsJSON),
		ImageGenOverrideJson:  jsonRaw(c.ImageGenOverrideJSON),
		Version:               c.Version,
	}
	if arg.ImageStatus == "" {
		arg.ImageStatus = "none"
	}
	if arg.Status == "" {
		arg.Status = CharacterStatusDraft
	}
	if arg.Source == "" {
		arg.Source = CharacterSourceManual
	}
	row, err := d.q.CreateCharacter(ctx, arg)
	if err != nil {
		return err
	}
	dbToCharacter(&row, c)
	return nil
}

// FindCharacterByID 按 ID 查询角色
func (d *DBData) FindCharacterByID(id string) (*Character, error) {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.GetCharacterByID(ctx, uid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pkg.ErrNotFound
		}
		return nil, err
	}
	c := &Character{}
	dbToCharacter(&row, c)
	return c, nil
}

// ListCharactersByProject 按项目列出角色
func (d *DBData) ListCharactersByProject(projectID uint) ([]Character, error) {
	ctx := context.Background()
	pid := pkg.UintToUUID(projectID)
	rows, err := d.q.ListCharactersByProject(ctx, pid)
	if err != nil {
		return nil, err
	}
	return dbCharsToModule(rows), nil
}

// ListCharactersByUser 按用户列出角色（含共享）
func (d *DBData) ListCharactersByUser(userID uint, includeShared bool) ([]Character, error) {
	ctx := context.Background()
	uid := pkg.UintToUUID(userID)
	var rows []db.Character
	var err error
	if includeShared {
		rows, err = d.q.ListCharactersByUserWithShared(ctx, uid)
	} else {
		rows, err = d.q.ListCharactersByUser(ctx, uid)
	}
	if err != nil {
		return nil, err
	}
	return dbCharsToModule(rows), nil
}

// UpdateCharacter 更新角色
func (d *DBData) UpdateCharacter(c *Character) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(c.ID)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateCharacterParams{
		ID:                   uid,
		Name:                 pgText(c.Name),
		AliasJson:            []byte(c.AliasJSON),
		Appearance:           pgText(c.Appearance),
		Style:                pgText(c.Style),
		StyleOverride:        pgtype.Bool{Bool: c.StyleOverride, Valid: true},
		Personality:          pgText(c.Personality),
		VoiceHint:            pgText(c.VoiceHint),
		Emotions:             pgText(c.Emotions),
		Scenes:               pgText(c.Scenes),
		Gender:               pgText(c.Gender),
		AgeGroup:             pgText(c.AgeGroup),
		VoiceID:              pgText(c.VoiceID),
		VoiceName:            pgText(c.VoiceName),
		ImageUrl:             pgText(c.ImageURL),
		ReferenceImagesJson:  []byte(c.ReferenceImagesJSON),
		TaskID:               pgText(c.TaskID),
		ImageStatus:          pgText(c.ImageStatus),
		Shared:               pgtype.Bool{Bool: c.Shared, Valid: true},
		Status:               pgText(c.Status),
		Source:               pgText(c.Source),
		VariantsJson:         []byte(c.VariantsJSON),
		Importance:           pgText(c.Importance),
		Consistency:          pgText(c.Consistency),
		RoleType:             pgText(c.RoleType),
		TagsJson:             []byte(c.TagsJSON),
		PropsJson:            []byte(c.PropsJSON),
		Bio:                  pgText(c.Bio),
		BioFragmentsJson:     []byte(c.BioFragmentsJSON),
		ImageGenOverrideJson: []byte(c.ImageGenOverrideJSON),
		Version:              pgtype.Int4{Int32: int32(c.Version), Valid: true},
	}
	_, err := d.q.UpdateCharacter(ctx, arg)
	return err
}

// DeleteCharacter 软删除角色
func (d *DBData) DeleteCharacter(id string) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	return d.q.SoftDeleteCharacter(ctx, uid)
}

// UpdateCharacterImage 更新角色形象
func (d *DBData) UpdateCharacterImage(id string, imageURL, taskID, status string) error {
	ctx := context.Background()
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateCharacterImageParams{
		ID:          uid,
		ImageUrl:    pgText(imageURL),
		TaskID:      pgText(taskID),
		ImageStatus: pgText(status),
	}
	_, err := d.q.UpdateCharacterImage(ctx, arg)
	return err
}

// 快照方法委托给 MemData
func (d *DBData) CreateSnapshot(s *CharacterSnapshot) error {
	return d.snapshots.CreateSnapshot(s)
}

func (d *DBData) FindSnapshotByID(id uint) (*CharacterSnapshot, error) {
	return d.snapshots.FindSnapshotByID(id)
}

func (d *DBData) ListSnapshotsByCharacter(characterID string) ([]CharacterSnapshot, error) {
	return d.snapshots.ListSnapshotsByCharacter(characterID)
}

func (d *DBData) ListSnapshotsByProject(projectID uint) ([]CharacterSnapshot, error) {
	return d.snapshots.ListSnapshotsByProject(projectID)
}

func (d *DBData) UpdateSnapshot(s *CharacterSnapshot) error {
	return d.snapshots.UpdateSnapshot(s)
}

func (d *DBData) DeleteSnapshot(id uint) error {
	return d.snapshots.DeleteSnapshot(id)
}

// 辅助函数
func pgText(s string) pgtype.Text {
	return pgtype.Text{String: s, Valid: true}
}

func jsonRaw(s string) interface{} {
	if s == "" {
		return []byte("[]")
	}
	return []byte(s)
}

func dbToCharacter(row *db.Character, c *Character) {
	c.ID = pkg.UUIDString(row.ID)
	c.CreatedAt = row.CreatedAt.Time
	c.UpdatedAt = row.UpdatedAt.Time
	c.UserID = pkg.UUIDString(row.UserID)
	c.ProjectID = ptrOrNil(pkg.UUIDString(row.ProjectID))
	c.Name = row.Name
	c.AliasJSON = stringVal(row.AliasJson)
	c.Appearance = textVal(row.Appearance)
	c.Style = textVal(row.Style)
	c.StyleOverride = row.StyleOverride
	c.Personality = textVal(row.Personality)
	c.VoiceHint = textVal(row.VoiceHint)
	c.Emotions = textVal(row.Emotions)
	c.Scenes = textVal(row.Scenes)
	c.Gender = textVal(row.Gender)
	c.AgeGroup = textVal(row.AgeGroup)
	c.VoiceID = textVal(row.VoiceID)
	c.VoiceName = textVal(row.VoiceName)
	c.ImageURL = textVal(row.ImageUrl)
	c.ReferenceImagesJSON = stringVal(row.ReferenceImagesJson)
	c.TaskID = textVal(row.TaskID)
	c.ImageStatus = textVal(row.ImageStatus)
	c.Shared = row.Shared
	c.Status = row.Status
	c.Source = row.Source
	c.VariantsJSON = stringVal(row.VariantsJson)
	c.Importance = textVal(row.Importance)
	c.Consistency = textVal(row.Consistency)
	c.RoleType = textVal(row.RoleType)
	c.TagsJSON = stringVal(row.TagsJson)
	c.PropsJSON = stringVal(row.PropsJson)
	c.Bio = textVal(row.Bio)
	c.BioFragmentsJSON = stringVal(row.BioFragmentsJson)
	c.ImageGenOverrideJSON = stringVal(row.ImageGenOverrideJson)
	c.Version = int(row.Version)
	if row.StyleID.Valid {
		s := pkg.UUIDString(row.StyleID)
		c.StyleID = &s
	}
}

func dbCharsToModule(rows []db.Character) []Character {
	out := make([]Character, len(rows))
	for i := range rows {
		dbToCharacter(&rows[i], &out[i])
	}
	return out
}

func textVal(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

func stringVal(b []byte) string {
	if len(b) == 0 {
		return ""
	}
	return string(b)
}

func ptrOrNil(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
