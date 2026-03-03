package asset_version

import (
	"anime_ai/module/assets/character"
	"anime_ai/module/assets/location"
	"anime_ai/module/assets/prop"
	"anime_ai/pub/crossmodule"
)

// NewConfirmedAssetCollector 创建已确认资产收集器（供 Freeze 时使用）
func NewConfirmedAssetCollector(
	charData character.Data,
	locStore location.Store,
	propStore prop.Store,
) crossmodule.ConfirmedAssetCollector {
	return &confirmedAssetCollector{
		charData: charData,
		locStore: locStore,
		propStore: propStore,
	}
}

// confirmedAssetCollector 收集项目内已确认的角色、场景、道具 ID
type confirmedAssetCollector struct {
	charData character.Data
	locStore location.Store
	propStore prop.Store
}

func (c *confirmedAssetCollector) Collect(projectID string) (*crossmodule.ConfirmedAssetIDs, error) {
	out := &crossmodule.ConfirmedAssetIDs{}
	if c.charData != nil {
		chars, err := c.charData.ListCharactersByProject(projectID)
		if err == nil {
			for _, ch := range chars {
				if ch.ProjectID != nil && *ch.ProjectID == projectID && ch.Status == character.CharacterStatusConfirmed && ch.ID != "" {
					out.CharacterIDs = append(out.CharacterIDs, ch.ID)
				}
			}
		}
	}
	if c.locStore != nil {
		locs, err := c.locStore.ListByProject(projectID)
		if err == nil {
			for _, loc := range locs {
				if loc.Status == "confirmed" && loc.ID != "" {
					out.LocationIDs = append(out.LocationIDs, loc.ID)
				}
			}
		}
	}
	if c.propStore != nil {
		props, err := c.propStore.ListByProject(projectID)
		if err == nil {
			for _, p := range props {
				if p.Status == "confirmed" && p.ID != "" {
					out.PropIDs = append(out.PropIDs, p.ID)
				}
			}
		}
	}
	return out, nil
}
