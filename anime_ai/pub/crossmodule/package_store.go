package crossmodule

import "context"

// PackageStoreUpdater 打包任务状态更新接口，供 pub/worker 调用
// 由 package_task 模块实现并注入
type PackageStoreUpdater interface {
	UpdateStatus(ctx context.Context, id, status, outputURL, errorMsg string) error
}

// 打包任务状态常量（与 package_task 模块一致）
const (
	PackageStatusPackaging = "packaging"
	PackageStatusDone      = "done"
	PackageStatusFailed    = "failed"
)
