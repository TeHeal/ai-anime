package crossmodule

// ProjectVerifier 验证项目归属，供 episode、scene 等模块注入
// 由 project 模块实现，使用 string ID 以兼容 PostgreSQL UUID
type ProjectVerifier interface {
	Verify(projectID, userID string) error
}
