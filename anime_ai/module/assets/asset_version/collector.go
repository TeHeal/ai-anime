package asset_version

import (
	"context"
	"fmt"

	"anime_ai/pub/crossmodule"
	"go.uber.org/zap"
)

// NewConfirmedAssetCollector 创建已确认资产收集器（供 Freeze 时使用）
// 依赖 character/location/prop 的 Service 接口，遵循「模块间禁止直接引用 Data」
func NewConfirmedAssetCollector(
	charLister crossmodule.ConfirmedCharacterLister,
	locLister crossmodule.ConfirmedLocationLister,
	propLister crossmodule.ConfirmedPropLister,
	logger *zap.Logger,
) crossmodule.ConfirmedAssetCollector {
	return &confirmedAssetCollector{
		charLister: charLister,
		locLister:  locLister,
		propLister: propLister,
		logger:     logger,
	}
}

// confirmedAssetCollector 收集项目内已确认的角色、场景、道具 ID
type confirmedAssetCollector struct {
	charLister crossmodule.ConfirmedCharacterLister
	locLister  crossmodule.ConfirmedLocationLister
	propLister crossmodule.ConfirmedPropLister
	logger     *zap.Logger
}

func (c *confirmedAssetCollector) Collect(ctx context.Context, projectID string) (*crossmodule.ConfirmedAssetIDs, error) {
	out := &crossmodule.ConfirmedAssetIDs{}

	charIDs, err := c.charLister.ListConfirmedCharacterIDs(ctx, projectID)
	if err != nil {
		if c.logger != nil {
			c.logger.Warn("收集已确认角色失败", zap.String("projectID", projectID), zap.Error(err))
		}
		return nil, fmt.Errorf("收集已确认角色失败: %w", err)
	}
	out.CharacterIDs = charIDs

	locIDs, err := c.locLister.ListConfirmedLocationIDs(ctx, projectID)
	if err != nil {
		if c.logger != nil {
			c.logger.Warn("收集已确认场景失败", zap.String("projectID", projectID), zap.Error(err))
		}
		return nil, fmt.Errorf("收集已确认场景失败: %w", err)
	}
	out.LocationIDs = locIDs

	propIDs, err := c.propLister.ListConfirmedPropIDs(ctx, projectID)
	if err != nil {
		if c.logger != nil {
			c.logger.Warn("收集已确认道具失败", zap.String("projectID", projectID), zap.Error(err))
		}
		return nil, fmt.Errorf("收集已确认道具失败: %w", err)
	}
	out.PropIDs = propIDs

	return out, nil
}
