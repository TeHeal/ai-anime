package crossmodule

// EpisodeReader 获取集所属项目，供 scene 模块验证场归属
// 由 episode 模块实现并注入，使用 string ID 以兼容 PostgreSQL UUID
type EpisodeReader interface {
	GetProjectIDByEpisode(episodeID string) (string, error)
}
