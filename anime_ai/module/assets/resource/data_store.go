package resource

import (
	"context"
	"encoding/json"

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

func dbResourceToResource(row db.Resource) Resource {
	tagsJSON := "[]"
	if len(row.TagsJson) > 0 {
		tagsJSON = string(row.TagsJson)
	}
	metadataJSON := "{}"
	if len(row.MetadataJson) > 0 {
		metadataJSON = string(row.MetadataJson)
	}
	bindingIDsJSON := "[]"
	if len(row.BindingIdsJson) > 0 {
		bindingIDsJSON = string(row.BindingIdsJson)
	}
	return Resource{
		ID:             pkg.UUIDToStr(row.ID),
		CreatedAt:      row.CreatedAt.Time,
		UpdatedAt:     row.UpdatedAt.Time,
		UserID:        pkg.UUIDToStr(row.UserID),
		Name:          row.Name,
		LibraryType:   row.LibraryType,
		Modality:      row.Modality,
		ThumbnailURL:  row.ThumbnailUrl.String,
		TagsJSON:      tagsJSON,
		Version:       row.Version.String,
		MetadataJSON:  metadataJSON,
		BindingIdsJSON: bindingIDsJSON,
		Description:   row.Description.String,
	}
}

func toPgText(s string) pgtype.Text {
	// 用于 Update 时始终传值，空字符串表示清空
	if s == "" {
		return pgtype.Text{String: "", Valid: true}
	}
	return pgtype.Text{String: s, Valid: true}
}

func toJsonBytes(s string) []byte {
	if s == "" {
		return nil
	}
	return []byte(s)
}

func (d *DBData) Create(ctx context.Context, r *Resource) error {
	userUUID := pkg.StrToUUID(r.UserID)
	if !userUUID.Valid {
		return pkg.ErrNotFound
	}

	var thumb, tags, ver, meta, binding, desc interface{}
	if r.ThumbnailURL != "" {
		thumb = r.ThumbnailURL
	}
	if r.TagsJSON != "" {
		tags = []byte(r.TagsJSON)
	}
	if r.Version != "" {
		ver = r.Version
	}
	if r.MetadataJSON != "" {
		meta = []byte(r.MetadataJSON)
	}
	if r.BindingIdsJSON != "" {
		binding = []byte(r.BindingIdsJSON)
	}
	if r.Description != "" {
		desc = r.Description
	}
	arg := db.CreateResourceParams{
		UserID:         userUUID,
		Name:           r.Name,
		LibraryType:    r.LibraryType,
		Modality:       r.Modality,
		ThumbnailUrl:   thumb,
		TagsJson:       tags,
		Version:        ver,
		MetadataJson:   meta,
		BindingIdsJson: binding,
		Description:    desc,
	}
	row, err := d.q.CreateResource(ctx, arg)
	if err != nil {
		return err
	}
	*r = dbResourceToResource(row)
	return nil
}

func (d *DBData) GetByIDAndUser(ctx context.Context, id, userID string) (*Resource, error) {
	idUUID := pkg.StrToUUID(id)
	userUUID := pkg.StrToUUID(userID)
	if !idUUID.Valid || !userUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.GetResourceByIDAndUser(ctx, db.GetResourceByIDAndUserParams{ID: idUUID, UserID: userUUID})
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	r := dbResourceToResource(row)
	return &r, nil
}

func (d *DBData) List(ctx context.Context, userID string, opts ListDataOpts) ([]Resource, int64, error) {
	userUUID := pkg.StrToUUID(userID)
	if !userUUID.Valid {
		return nil, 0, pkg.ErrNotFound
	}
	var mod, lib, search pgtype.Text
	if opts.Modality != "" {
		mod = pgtype.Text{String: opts.Modality, Valid: true}
	}
	if opts.LibraryType != "" {
		lib = pgtype.Text{String: opts.LibraryType, Valid: true}
	}
	if opts.Search != "" {
		search = pgtype.Text{String: opts.Search, Valid: true}
	}
	sortBy := interface{}(opts.SortBy)
	if sortBy == "" {
		sortBy = "newest"
	}
	listArg := db.ListResourcesByUserParams{
		UserID:      userUUID,
		Modality:    mod,
		LibraryType: lib,
		TagsOverlap: opts.TagsOverlap,
		Search:      search,
		SortBy:      sortBy,
		Offset:      opts.Offset,
		Limit:       opts.Limit,
	}
	rows, err := d.q.ListResourcesByUser(ctx, listArg)
	if err != nil {
		return nil, 0, err
	}
	countArg := db.CountResourcesByUserParams{
		UserID:      userUUID,
		Modality:    mod,
		LibraryType: lib,
		TagsOverlap: opts.TagsOverlap,
		Search:      search,
	}
	total, err := d.q.CountResourcesByUser(ctx, countArg)
	if err != nil {
		return nil, 0, err
	}
	out := make([]Resource, len(rows))
	for i := range rows {
		out[i] = dbResourceToResource(rows[i])
	}
	return out, total, nil
}

func (d *DBData) Update(ctx context.Context, r *Resource) error {
	idUUID := pkg.StrToUUID(r.ID)
	userUUID := pkg.StrToUUID(r.UserID)
	if !idUUID.Valid || !userUUID.Valid {
		return pkg.ErrNotFound
	}
	tags := []byte(r.TagsJSON)
	if len(tags) == 0 {
		tags = []byte("[]")
	}
	meta := []byte(r.MetadataJSON)
	if len(meta) == 0 {
		meta = []byte("{}")
	}
	binding := []byte(r.BindingIdsJSON)
	if len(binding) == 0 {
		binding = []byte("[]")
	}
	arg := db.UpdateResourceParams{
		ID:             idUUID,
		UserID:         userUUID,
		Name:           toPgText(r.Name),
		LibraryType:   toPgText(r.LibraryType),
		Modality:      toPgText(r.Modality),
		ThumbnailUrl:   toPgText(r.ThumbnailURL),
		TagsJson:       tags,
		Version:        toPgText(r.Version),
		MetadataJson:   meta,
		BindingIdsJson: binding,
		Description:    toPgText(r.Description),
	}
	row, err := d.q.UpdateResource(ctx, arg)
	if err != nil {
		return err
	}
	*r = dbResourceToResource(row)
	return nil
}

func (d *DBData) SoftDelete(ctx context.Context, id, userID string) error {
	idUUID := pkg.StrToUUID(id)
	userUUID := pkg.StrToUUID(userID)
	if !idUUID.Valid || !userUUID.Valid {
		return pkg.ErrNotFound
	}
	return d.q.SoftDeleteResource(ctx, db.SoftDeleteResourceParams{ID: idUUID, UserID: userUUID})
}

func (d *DBData) CountByLibraryType(ctx context.Context, userID, modality string) (map[string]int64, error) {
	userUUID := pkg.StrToUUID(userID)
	if !userUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	var mod pgtype.Text
	if modality != "" {
		mod = pgtype.Text{String: modality, Valid: true}
	}
	rows, err := d.q.CountResourcesByLibraryType(ctx, db.CountResourcesByLibraryTypeParams{UserID: userUUID, Modality: mod})
	if err != nil {
		return nil, err
	}
	out := make(map[string]int64)
	for _, row := range rows {
		out[row.LibraryType] = row.Count
	}
	return out, nil
}

// TagsToOverlapJSON 将 []string 转为 JSON 数组字节，用于 tags && 筛选
func TagsToOverlapJSON(tags []string) []byte {
	if len(tags) == 0 {
		return nil
	}
	b, _ := json.Marshal(tags)
	return b
}
