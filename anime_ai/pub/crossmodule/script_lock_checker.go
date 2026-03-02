package crossmodule

// ScriptLockChecker 检查项目脚本是否已锁定（README 2.2/2.4 阶段门禁）
// 镜图/镜头视频生成前必须锁定脚本，防止生成中途脚本变更导致不一致
type ScriptLockChecker interface {
	IsScriptLocked(projectID string) (bool, error)
}
