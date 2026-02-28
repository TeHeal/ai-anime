package realtime

import "time"

// Event WebSocket 推送事件结构，ID 使用 string 兼容 UUID
type Event struct {
	Type         string      `json:"type"`
	Version      uint64      `json:"version"`
	UserIDStr    string      `json:"user_id,omitempty"`
	ProjectIDStr string      `json:"project_id,omitempty"`
	TaskID       string      `json:"task_id,omitempty"`
	Timestamp    time.Time   `json:"timestamp"`
	Payload      interface{} `json:"payload,omitempty"`
}
