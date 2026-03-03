package project

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/middleware"
)

// LockCheckerAdapter 实现 middleware.LockChecker，供 LockGuard 使用
type LockCheckerAdapter struct {
	svc *Service
}

// NewLockCheckerAdapter 创建 LockChecker 适配器
func NewLockCheckerAdapter(svc *Service) *LockCheckerAdapter {
	return &LockCheckerAdapter{svc: svc}
}

// IsLocked 检查指定阶段是否已锁定
func (a *LockCheckerAdapter) IsLocked(projectIDStr, phase string) (bool, error) {
	return a.svc.IsLocked(projectIDStr, phase)
}

// 编译时断言：LockCheckerAdapter 实现 middleware.LockChecker
var _ middleware.LockChecker = (*LockCheckerAdapter)(nil)
