package crossmodule

// MemberInfo 项目成员信息，供权限校验使用
type MemberInfo struct {
	IsOwner  bool     // 是否为项目创建者（拥有导演权限）
	Role     string   // 层级角色：owner/editor/viewer
	JobRoles []string // 工种角色：director, storyboarder, designer 等，权限取并集
}

// ProjectMemberResolver 解析项目成员信息，供权限校验使用
// 与 ProjectVerifier 配合：Verify 通过后可用 Resolve 获取工种做细粒度校验
type ProjectMemberResolver interface {
	Resolve(projectID, userID string) (*MemberInfo, error)
}
