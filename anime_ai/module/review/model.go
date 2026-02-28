package review

// 审核阶段
const (
	PhaseScript    = "script"     // 脚本阶段
	PhaseShotImage = "shot_image" // 镜图阶段
	PhaseShotVideo = "shot_video" // 镜头阶段
)

// 审核方式
const (
	ModeHuman    = "human"     // 仅人工
	ModeAI       = "ai"        // 仅 AI（默认）
	ModeHumanAI  = "human_ai"  // 人工+AI（AI 初筛+人工终审）
)

// 审核状态（完整状态机）
const (
	StatusPending      = "pending"       // 待审核
	StatusAIReviewing  = "ai_reviewing"  // AI 审核中
	StatusAIApproved   = "ai_approved"   // AI 审核通过
	StatusAIRejected   = "ai_rejected"   // AI 审核不通过
	StatusHumanReview  = "human_review"  // 等待人工审核
	StatusApproved     = "approved"      // 审核通过
	StatusRejected     = "rejected"      // 审核不通过
)

// 审核者类型
const (
	ReviewerAI    = "ai"
	ReviewerHuman = "human"
)

// ReviewConfig 审核配置
type ReviewConfig struct {
	ID        string `json:"id"`
	ProjectID string `json:"project_id"`
	Phase     string `json:"phase"`
	Mode      string `json:"mode"`
	AIModel   string `json:"ai_model,omitempty"`
	AIPrompt  string `json:"ai_prompt,omitempty"`
}

// ReviewRecord 审核记录
type ReviewRecord struct {
	ID           string  `json:"id"`
	CreatedAt    string  `json:"created_at"`
	ProjectID    string  `json:"project_id"`
	Phase        string  `json:"phase"`
	TargetType   string  `json:"target_type"`
	TargetID     string  `json:"target_id"`
	ReviewerType string  `json:"reviewer_type"`
	ReviewerID   string  `json:"reviewer_id,omitempty"`
	Status       string  `json:"status"`
	AIScore      *int    `json:"ai_score,omitempty"`
	AIReason     string  `json:"ai_reason,omitempty"`
	HumanComment string  `json:"human_comment,omitempty"`
	Round        int     `json:"round"`
	DecidedAt    *string `json:"decided_at,omitempty"`
}

// SubmitReviewRequest 提交审核请求
type SubmitReviewRequest struct {
	TargetType string `json:"target_type" binding:"required"`
	TargetID   string `json:"target_id" binding:"required"`
	Phase      string `json:"phase" binding:"required"`
}

// DecideReviewRequest 审核决策请求（人工审核时使用）
type DecideReviewRequest struct {
	Status  string `json:"status" binding:"required"`
	Comment string `json:"comment"`
}

// UpdateConfigRequest 更新审核配置请求
type UpdateConfigRequest struct {
	Phase   string `json:"phase" binding:"required"`
	Mode    string `json:"mode" binding:"required"`
	AIModel string `json:"ai_model"`
	AIPrompt string `json:"ai_prompt"`
}
