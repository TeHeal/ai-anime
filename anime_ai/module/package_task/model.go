package package_task

// 打包任务状态
const (
	StatusPending   = "pending"
	StatusPackaging = "packaging"
	StatusDone      = "done"
	StatusFailed    = "failed"
)

// Task 按集打包任务实体
type Task struct {
	ID         string
	ProjectID  string
	EpisodeID  string
	TaskID     string
	Status     string
	OutputURL  string
	ConfigJSON string
	ErrorMsg   string
}
