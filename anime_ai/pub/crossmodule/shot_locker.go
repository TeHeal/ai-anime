package crossmodule

// ShotLocker 镜头任务锁（README 2.3），供 shot_image、shot 模块使用
// 执行镜图/镜头生成时加锁，完成/取消/超时(1h)后释放
type ShotLocker interface {
	// TryLockShot 尝试加锁，被他人锁定时返回 ErrLocked
	TryLockShot(shotID, userID string) error
	// UnlockShot 释放锁（仅本人可释放）
	UnlockShot(shotID, userID string) error
}
