package crossmodule

// FrozenAssetChecker 检查资产是否已纳入冻结版本（assets 锁定后，已纳入的禁止 Update/Delete/Confirm）
type FrozenAssetChecker interface {
	// IsAssetInFrozenVersion 判断资产是否在项目最新冻结版本的 ID 列表中
	// assetType: "character" | "location" | "prop"
	// 若项目未锁定 assets 或资产未纳入，返回 false
	IsAssetInFrozenVersion(projectID, assetType, assetID string) (bool, error)
}
