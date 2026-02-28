package notification

// 通知类型
const (
	TypeReviewCompleted = "review_completed"
	TypeTaskCompleted   = "task_completed"
	TypeTaskFailed      = "task_failed"
	TypeMemberAdded     = "member_added"
	TypeCompositeReady  = "composite_ready"
	TypeSystem          = "system"
)

// Notification 通知模型
type Notification struct {
	ID        string  `json:"id"`
	CreatedAt string  `json:"created_at"`
	UserID    string  `json:"user_id"`
	ProjectID string  `json:"project_id,omitempty"`
	Type      string  `json:"type"`
	Title     string  `json:"title"`
	Content   string  `json:"content,omitempty"`
	RefType   string  `json:"ref_type,omitempty"`
	RefID     string  `json:"ref_id,omitempty"`
	IsRead    bool    `json:"is_read"`
	ReadAt    *string `json:"read_at,omitempty"`
}

// UnreadCount 未读数
type UnreadCount struct {
	Count int64 `json:"count"`
}
