package crossmodule

import "context"

// CompositeExportUpdater 成片导出状态更新接口，供 pub/worker 调用
// 由 composite 模块实现并注入，实现编排层与业务模块解耦（README 跨模块调用规则）
type CompositeExportUpdater interface {
	UpdateStatus(ctx context.Context, id, status, outputURL, errorMsg string) error
}

// 成片任务状态常量（与 composite 模块一致，供 Worker 使用）
const (
	CompositeStatusPending   = "pending"
	CompositeStatusExporting = "exporting"
	CompositeStatusDone      = "done"
	CompositeStatusFailed    = "failed"
)
