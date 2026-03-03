package asset_version

import (
	"context"
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/module/project"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// Service 资产版本业务逻辑层
type Service struct {
	data      Data
	project   project.Data
	collector crossmodule.ConfirmedAssetCollector
}

// NewService 创建 Service
func NewService(data Data, projectData project.Data, collector crossmodule.ConfirmedAssetCollector) *Service {
	return &Service{
		data:      data,
		project:   projectData,
		collector: collector,
	}
}

// List 列出项目资产版本
func (s *Service) List(ctx context.Context, projectID string, limit, offset int) ([]AssetVersion, error) {
	return s.data.ListByProject(ctx, projectID, limit, offset)
}

// Freeze 冻结资产：只收集已确认的角色、场景、道具，写入版本，并锁定 assets
func (s *Service) Freeze(ctx context.Context, projectID string) (*AssetVersion, error) {
	ids, err := s.collector.Collect(projectID)
	if err != nil {
		return nil, err
	}
	stats := StatsJSON{
		CharacterIDs: ids.CharacterIDs,
		LocationIDs:  ids.LocationIDs,
		PropIDs:      ids.PropIDs,
	}
	statsBytes, err := json.Marshal(stats)
	if err != nil {
		return nil, err
	}
	statsJSON := string(statsBytes)

	// 获取当前最新版本号
	latest, _ := s.data.GetLatestFreeze(ctx, projectID)
	version := 1
	if latest != nil {
		version = latest.Version + 1
	}

	av, err := s.data.Create(ctx, projectID, version, "freeze", statsJSON, "", "")
	if err != nil {
		return nil, err
	}

	if err := s.project.UpdateLockPhase(projectID, "assets", true); err != nil {
		return nil, err
	}
	return av, nil
}

// Unfreeze 解冻资产
func (s *Service) Unfreeze(ctx context.Context, projectID string) error {
	return s.project.UpdateLockPhase(projectID, "assets", false)
}

// GetLatestFreeze 获取最新冻结版本（供 FrozenAssetChecker 使用）
func (s *Service) GetLatestFreeze(ctx context.Context, projectID string) (*AssetVersion, error) {
	return s.data.GetLatestFreeze(ctx, projectID)
}

// IsAssetInFrozenVersion 判断资产是否在最新冻结版本中（实现 FrozenAssetChecker 的核心逻辑）
func (s *Service) IsAssetInFrozenVersion(ctx context.Context, projectID, assetType, assetID string) (bool, error) {
	p, err := s.project.FindByIDOnly(projectID)
	if err != nil {
		return false, err
	}
	if !p.AssetsLocked {
		return false, nil
	}
	av, err := s.data.GetLatestFreeze(ctx, projectID)
	if err != nil || av == nil {
		return false, err
	}
	st, err := ParseStatsJSON(av.StatsJSON)
	if err != nil {
		return false, err
	}
	switch assetType {
	case "character":
		return contains(st.CharacterIDs, assetID), nil
	case "location":
		return contains(st.LocationIDs, assetID), nil
	case "prop":
		return contains(st.PropIDs, assetID), nil
	default:
		return false, nil
	}
}

func contains(ids []string, id string) bool {
	for _, x := range ids {
		if x == id {
			return true
		}
	}
	return false
}

// NoopCollector 空实现（无 DB 或未注入时使用）
type NoopCollector struct{}

func (NoopCollector) Collect(projectID string) (*crossmodule.ConfirmedAssetIDs, error) {
	return &crossmodule.ConfirmedAssetIDs{}, nil
}

// NoopData 空实现（无 DB 时使用，Freeze/List 不可用）
type NoopData struct{}

func (NoopData) Create(ctx context.Context, projectID string, version int, action, statsJSON, deltaJSON, note string) (*AssetVersion, error) {
	return nil, pkg.ErrNotFound
}

func (NoopData) ListByProject(ctx context.Context, projectID string, limit, offset int) ([]AssetVersion, error) {
	return nil, nil
}

func (NoopData) GetLatestFreeze(ctx context.Context, projectID string) (*AssetVersion, error) {
	return nil, nil
}

// FrozenCheckerAdapter 实现 crossmodule.FrozenAssetChecker
type FrozenCheckerAdapter struct {
	svc *Service
}

// NewFrozenCheckerAdapter 创建 FrozenAssetChecker 适配器
func NewFrozenCheckerAdapter(svc *Service) *FrozenCheckerAdapter {
	return &FrozenCheckerAdapter{svc: svc}
}

// IsAssetInFrozenVersion 检查资产是否在冻结版本中
func (a *FrozenCheckerAdapter) IsAssetInFrozenVersion(projectID, assetType, assetID string) (bool, error) {
	return a.svc.IsAssetInFrozenVersion(context.Background(), projectID, assetType, assetID)
}

var _ crossmodule.FrozenAssetChecker = (*FrozenCheckerAdapter)(nil)
