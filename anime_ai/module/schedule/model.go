package schedule

// Schedule 定时任务模型
type Schedule struct {
	ID          string `json:"id"`
	CreatedAt   string `json:"created_at,omitempty"`
	ProjectID   string `json:"project_id"`
	Name        string `json:"name"`
	CronExpr    string `json:"cron_expr"`
	TaskType    string `json:"task_type"`
	TaskParams  string `json:"task_params,omitempty"`
	Enabled     bool   `json:"enabled"`
	LastRunAt   string `json:"last_run_at,omitempty"`
	NextRunAt   string `json:"next_run_at,omitempty"`
	CreatedBy   string `json:"created_by"`
}

// CreateRequest 创建调度请求
type CreateRequest struct {
	Name       string `json:"name" binding:"required"`
	CronExpr   string `json:"cron_expr" binding:"required"`
	TaskType   string `json:"task_type" binding:"required"`
	TaskParams string `json:"task_params"`
	Enabled    bool   `json:"enabled"`
}

// UpdateRequest 更新调度请求
type UpdateRequest struct {
	Name       string `json:"name"`
	CronExpr   string `json:"cron_expr"`
	TaskType   string `json:"task_type"`
	TaskParams string `json:"task_params"`
	Enabled    *bool  `json:"enabled"`
}
