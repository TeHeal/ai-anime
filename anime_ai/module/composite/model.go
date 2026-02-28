package composite

// 成片任务状态（README 状态机 editing→exporting→done）
const (
	StatusPending   = "pending"
	StatusExporting = "exporting"
	StatusDone      = "done"
	StatusFailed    = "failed"
)

// Task 成片任务实体
type Task struct {
	ID        string
	ProjectID string
	EpisodeID string
	TaskID    string
	Status    string
	OutputURL string
	ConfigJSON string
	ErrorMsg  string
}
