package crossmodule

// ReviewConfigReader 审核配置读取接口，供 shot_image 等模块获取项目的审核模式
// 由 project 模块实现并注入
type ReviewConfigReader interface {
	GetStageReviewMode(projectID, stage string) (mode string, err error)
}

// StageNames 可配置审核的阶段名
const (
	StageScript    = "script"
	StageShotImage = "shotImage"
	StageShotVideo = "shotVideo"
)
