package project

import "anime_ai/pub/crossmodule"

// scriptLockChecker 基于 project.Data 实现脚本锁定检查（README 2.2/2.4 阶段门禁）
type scriptLockChecker struct {
	data Data
}

// NewScriptLockChecker 创建脚本锁定检查器
func NewScriptLockChecker(data Data) crossmodule.ScriptLockChecker {
	return &scriptLockChecker{data: data}
}

func (c *scriptLockChecker) IsScriptLocked(projectID string) (bool, error) {
	proj, err := c.data.FindByIDOnly(projectID)
	if err != nil {
		return false, err
	}
	return proj.ScriptLocked, nil
}
