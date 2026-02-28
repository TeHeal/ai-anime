package script

import "time"

// Segment 脚本分段实体，属于 Project，包含镜头指令内容
// ID 为 string（UUID 格式），与 sch/db pgtype.UUID 兼容
type Segment struct {
	ID        string    `json:"id"`
	ProjectID uint      `json:"project_id"` // 仍为 uint，与 ProjectVerifier 兼容
	SortIndex int       `json:"sort_index"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// SegmentResponse 分段 API 响应
type SegmentResponse struct {
	ID        string    `json:"id"`
	ProjectID uint      `json:"project_id"`
	SortIndex int       `json:"sort_index"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// ToResponse 转为 API 响应
func (s *Segment) ToResponse() SegmentResponse {
	return SegmentResponse{
		ID:        s.ID,
		ProjectID: s.ProjectID,
		SortIndex: s.SortIndex,
		Content:   s.Content,
		CreatedAt: s.CreatedAt,
		UpdatedAt: s.UpdatedAt,
	}
}
