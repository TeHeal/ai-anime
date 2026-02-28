package usage

import (
	"context"
	"errors"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Service 用量查询业务逻辑层
type Service struct {
	data   Data
	verifier crossmodule.ProjectVerifier
}

// NewService 创建 Service 实例
func NewService(data Data, verifier crossmodule.ProjectVerifier) *Service {
	return &Service{data: data, verifier: verifier}
}

// List 按项目/用户/时间范围查询用量（需项目权限验证）
func (s *Service) List(ctx context.Context, projectID, userID string, startAt, endAt *time.Time, limit, offset int32) ([]map[string]interface{}, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	projectUUID := pkg.StrToUUID(projectID)
	if !projectUUID.Valid {
		return nil, errors.New("无效的项目 ID")
	}
	arg := db.ListProviderUsagesParams{
		ProjectID: projectUUID,
		UserID:    pgtype.UUID{Valid: false},
		StartAt:   pgtype.Timestamptz{Valid: false},
		EndAt:     pgtype.Timestamptz{Valid: false},
		Offset:    offset,
		Limit:     limit,
	}
	if startAt != nil {
		arg.StartAt = pgtype.Timestamptz{Time: *startAt, Valid: true}
	}
	if endAt != nil {
		arg.EndAt = pgtype.Timestamptz{Time: *endAt, Valid: true}
	}
	rows, err := s.data.List(ctx, arg)
	if err != nil {
		return nil, err
	}
	out := make([]map[string]interface{}, len(rows))
	for i, u := range rows {
		out[i] = ToUsageItem(u)
	}
	return out, nil
}
