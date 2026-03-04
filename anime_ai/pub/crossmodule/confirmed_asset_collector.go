package crossmodule

import "context"

// ConfirmedAssetIDs 已确认资产的 ID 列表（冻结时只纳入 confirmed）
type ConfirmedAssetIDs struct {
	CharacterIDs []string
	LocationIDs  []string
	PropIDs      []string
}

// ConfirmedAssetCollector 收集项目内已确认的角色、场景、道具 ID（供 asset_version 冻结时使用）
type ConfirmedAssetCollector interface {
	Collect(ctx context.Context, projectID string) (*ConfirmedAssetIDs, error)
}

// ConfirmedCharacterLister 列出项目内已确认角色 ID（供 collector 依赖注入）
type ConfirmedCharacterLister interface {
	ListConfirmedCharacterIDs(ctx context.Context, projectID string) ([]string, error)
}

// ConfirmedLocationLister 列出项目内已确认场景 ID（供 collector 依赖注入）
type ConfirmedLocationLister interface {
	ListConfirmedLocationIDs(ctx context.Context, projectID string) ([]string, error)
}

// ConfirmedPropLister 列出项目内已确认道具 ID（供 collector 依赖注入）
type ConfirmedPropLister interface {
	ListConfirmedPropIDs(ctx context.Context, projectID string) ([]string, error)
}
