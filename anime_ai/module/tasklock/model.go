package tasklock

// 任务锁状态
const (
	StatusPending   = "pending"
	StatusRunning   = "running"
	StatusCompleted = "completed"
	StatusCancelled = "cancelled"
)

// TaskLock 任务锁模型
type TaskLock struct {
	ID           string `json:"id"`
	CreatedAt    string `json:"created_at,omitempty"`
	ProjectID    string `json:"project_id"`
	ResourceType string `json:"resource_type"`
	ResourceID   string `json:"resource_id"`
	Action       string `json:"action"`
	Status       string `json:"status"`
	LockedBy     string `json:"locked_by"`
	ExpiresAt    string `json:"expires_at,omitempty"`
}
