package realtime

// Broadcaster 统一事件广播接口。
// Hub 直接满足此接口；EventRecorder 包装 Hub 实现持久化 + 广播。
type Broadcaster interface {
	BroadcastTaskProgress(userID string, projectID *string, taskID string, payload interface{})
	BroadcastTaskComplete(userID string, projectID *string, taskID string, payload interface{})
	BroadcastTaskError(userID string, projectID *string, taskID string, payload interface{})
	BroadcastResourceCreated(userID string, resourceID string, resourceType string)
}
