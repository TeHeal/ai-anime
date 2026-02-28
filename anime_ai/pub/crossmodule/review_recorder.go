package crossmodule

import "context"

// ReviewRecorder 审核记录接口（README 2.2 审核闭环）
// 由 pub/review_record 实现并注入到 shot_image、shot 等模块
type ReviewRecorder interface {
	Record(ctx context.Context, targetType, targetID, projectID, reviewerID, reviewerType, action, comment string, feedback map[string]interface{})
}
