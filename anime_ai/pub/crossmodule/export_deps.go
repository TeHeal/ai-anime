package crossmodule

import "context"

// ExportShotInfo 成片导出所需的镜头信息
type ExportShotInfo struct {
	ID            string
	SortIndex     int
	Dialogue      string
	CharacterName string
	Duration      int // 秒
}

// ExportShotVideoInfo 成片导出所需的镜头视频信息
type ExportShotVideoInfo struct {
	ID       string
	ShotID   string
	VideoURL string
	Status   string
	Duration int
}

// ExportShotReader 成片导出所需的镜头查询接口
// 由 shot 模块实现并注入
type ExportShotReader interface {
	// ListShotsByProject 按项目列出所有镜头（按 sort_index 排序）
	ListShotsByProject(ctx context.Context, projectID string) ([]ExportShotInfo, error)
}

// ExportShotVideoReader 成片导出所需的镜头视频查询接口
// 由 shot_video 模块实现并注入
type ExportShotVideoReader interface {
	// GetLatestApprovedVideo 获取镜头最新的已完成视频 URL
	GetLatestApprovedVideo(ctx context.Context, shotID string) (*ExportShotVideoInfo, error)
}
