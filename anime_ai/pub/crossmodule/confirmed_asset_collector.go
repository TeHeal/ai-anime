package crossmodule

// ConfirmedAssetIDs 已确认资产的 ID 列表（冻结时只纳入 confirmed）
type ConfirmedAssetIDs struct {
	CharacterIDs []string
	LocationIDs  []string
	PropIDs      []string
}

// ConfirmedAssetCollector 收集项目内已确认的角色、场景、道具 ID（供 asset_version 冻结时使用）
type ConfirmedAssetCollector interface {
	Collect(projectID string) (*ConfirmedAssetIDs, error)
}
