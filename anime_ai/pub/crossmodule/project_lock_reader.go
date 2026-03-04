package crossmodule

// ProjectLockInfo 项目锁定信息（供跨模块使用，避免直接依赖 project.Project）
type ProjectLockInfo struct {
	AssetsLocked bool
}

// ProjectLockReader 项目锁定读写接口（供 asset_version 等模块使用，不校验用户权限）
type ProjectLockReader interface {
	UpdateLockPhase(projectID, phase string, locked bool) error
	FindByIDOnly(projectID string) (*ProjectLockInfo, error)
}
