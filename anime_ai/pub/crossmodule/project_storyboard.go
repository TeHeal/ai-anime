package crossmodule

// ProjectStoryboardAccess 项目分镜 JSON 读写，供 storyboard 模块使用
// 由 project 模块实现，使用 string ID 以兼容 PostgreSQL UUID
type ProjectStoryboardAccess interface {
	GetStoryboardJSON(projectID, userID string) (string, error)
	UpdateStoryboardJSON(projectID, userID string, json string) error
}
