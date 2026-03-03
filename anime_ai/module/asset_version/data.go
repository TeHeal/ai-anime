package asset_version

import (
	"context"
	"encoding/json"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// StatsJSON 版本快照中的资产 ID 列表
type StatsJSON struct {
	CharacterIDs []string `json:"character_ids"`
	LocationIDs  []string `json:"location_ids"`
	PropIDs      []string `json:"prop_ids"`
}

// AssetVersion 资产版本实体
type AssetVersion struct {
	ID        string     `json:"id"`
	ProjectID string     `json:"projectId"`
	Version   int        `json:"version"`
	Action    string     `json:"action"`
	StatsJSON string     `json:"statsJson"`
	DeltaJSON string     `json:"deltaJson"`
	Note      string     `json:"note"`
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
}

// Data 数据访问层
type Data interface {
	Create(ctx context.Context, projectID string, version int, action, statsJSON, deltaJSON, note string) (*AssetVersion, error)
	ListByProject(ctx context.Context, projectID string, limit, offset int) ([]AssetVersion, error)
	GetLatestFreeze(ctx context.Context, projectID string) (*AssetVersion, error)
}

// DBData 基于 sqlc 的 PostgreSQL 实现
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData
func NewDBData(queries *db.Queries) *DBData {
	return &DBData{q: queries}
}

func (d *DBData) Create(ctx context.Context, projectID string, version int, action, statsJSON, deltaJSON, note string) (*AssetVersion, error) {
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	arg := db.CreateAssetVersionParams{
		ProjectID: projUUID,
		Version:   version,
		Action:    action,
		StatsJson: statsJSON,
		DeltaJson: deltaJSON,
		Note:      pgtype.Text{String: note, Valid: note != ""},
	}
	row, err := d.q.CreateAssetVersion(ctx, arg)
	if err != nil {
		return nil, err
	}
	return dbRowToAssetVersion(&row), nil
}

func (d *DBData) ListByProject(ctx context.Context, projectID string, limit, offset int) ([]AssetVersion, error) {
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	rows, err := d.q.ListAssetVersionsByProject(ctx, db.ListAssetVersionsByProjectParams{
		ProjectID: projUUID,
		Offset:    int32(offset),
		Limit:     int32(limit),
	})
	if err != nil {
		return nil, err
	}
	out := make([]AssetVersion, len(rows))
	for i := range rows {
		out[i] = *dbRowToAssetVersion(&rows[i])
	}
	return out, nil
}

func (d *DBData) GetLatestFreeze(ctx context.Context, projectID string) (*AssetVersion, error) {
	projUUID := pkg.StrToUUID(projectID)
	if !projUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := d.q.GetLatestFreezeByProject(ctx, projUUID)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return dbRowToAssetVersion(&row), nil
}

func dbRowToAssetVersion(row *db.AssetVersion) *AssetVersion {
	av := &AssetVersion{
		ProjectID: pkg.UUIDToStr(row.ProjectID),
		Version:   int(row.Version),
		Action:    row.Action,
		StatsJSON: row.StatsJson.String,
		DeltaJSON: row.DeltaJson.String,
		Note:      row.Note.String,
	}
	if row.ID.Valid {
		av.ID = pkg.UUIDToStr(row.ID)
	}
	if row.CreatedAt.Valid {
		av.CreatedAt = row.CreatedAt.Time
	}
	if row.UpdatedAt.Valid {
		av.UpdatedAt = row.UpdatedAt.Time
	}
	return av
}

// ParseStatsJSON 解析 stats_json 为 StatsJSON
func ParseStatsJSON(s string) (*StatsJSON, error) {
	if s == "" {
		return &StatsJSON{}, nil
	}
	var st StatsJSON
	if err := json.Unmarshal([]byte(s), &st); err != nil {
		return nil, err
	}
	return &st, nil
}
