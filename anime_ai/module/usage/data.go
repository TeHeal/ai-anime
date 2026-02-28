package usage

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Data 用量查询数据访问接口
type Data interface {
	List(ctx context.Context, arg db.ListProviderUsagesParams) ([]db.ProviderUsage, error)
}

// DBData 基于 sqlc 的实现
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData
func NewDBData(q *db.Queries) *DBData {
	return &DBData{q: q}
}

// List 查询用量记录
func (d *DBData) List(ctx context.Context, arg db.ListProviderUsagesParams) ([]db.ProviderUsage, error) {
	return d.q.ListProviderUsages(ctx, arg)
}

// ToUsageItem 将 db.ProviderUsage 转为 API 响应格式
func ToUsageItem(u db.ProviderUsage) map[string]interface{} {
	item := map[string]interface{}{
		"id":           pkg.UUIDString(u.ID),
		"created_at":   u.CreatedAt.Time.Format("2006-01-02T15:04:05Z07:00"),
		"provider":     u.Provider,
		"model":        u.Model,
		"service_type": u.ServiceType,
		"token_count":  int32Val(u.TokenCount),
		"image_count":  int32Val(u.ImageCount),
		"video_seconds": int32Val(u.VideoSeconds),
		"cost_cents":   int32Val(u.CostCents),
	}
	if u.ProjectID.Valid {
		item["project_id"] = pkg.UUIDString(u.ProjectID)
	}
	if u.UserID.Valid {
		item["user_id"] = pkg.UUIDString(u.UserID)
	}
	return item
}

func int32Val(t pgtype.Int4) int {
	if !t.Valid {
		return 0
	}
	return int(t.Int32)
}

var _ Data = (*DBData)(nil)
