package middleware

// 以下接口供 project_ctx、lock_guard、audit 等中间件使用，由 module 层或 pub 编排层注入实现。

// ProjectInfo 项目基本信息，用于解析项目上下文
type ProjectInfo struct {
	UserID uint
	TeamID uint
}

// ProjectReader 项目读取接口
type ProjectReader interface {
	FindByIDOnly(id uint) (*ProjectInfo, error)
}

// ProjectMemberInfo 项目成员信息
type ProjectMemberInfo struct {
	Role string
}

// ProjectMemberReader 项目成员读取接口
type ProjectMemberReader interface {
	FindByProjectAndUser(projectID, userID uint) (*ProjectMemberInfo, error)
}

// TeamMemberInfo 团队成员信息
type TeamMemberInfo struct {
	Role string
}

// TeamMemberReader 团队成员读取接口
type TeamMemberReader interface {
	FindByTeamAndUser(teamID, userID uint) (*TeamMemberInfo, error)
}

// LockChecker 阶段锁检查接口
type LockChecker interface {
	IsLocked(projectID uint, phase string) (bool, error)
}

// AuditLogEntry 审计日志条目
type AuditLogEntry struct {
	OrgID        *uint
	ProjectID    *uint
	UserID       uint
	Action       string
	ResourceType string
	ResourceID   uint
	DetailJSON   string
	IP           string
	UserAgent    string
}

// AuditWriter 审计日志写入接口
type AuditWriter interface {
	Create(entry *AuditLogEntry) error
}
