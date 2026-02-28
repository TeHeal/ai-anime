package auth

// 项目/团队内角色常量，与 RBAC 配合使用
const (
	TeamRoleOwner    = "owner"
	TeamRoleDirector = "director"
	TeamRoleEditor   = "editor"
	TeamRoleViewer   = "viewer"
)

// Action 需要鉴权的操作
type Action string

const (
	ActionProjectCreate  Action = "project.create"
	ActionProjectDelete  Action = "project.delete"
	ActionProjectView    Action = "project.view"
	ActionEdit           Action = "content.edit"
	ActionGenerate       Action = "ai.generate"
	ActionReview         Action = "review.decide"
	ActionManageMembers  Action = "members.manage"
	ActionViewAuditLog   Action = "audit.view"
)

// MinRole 返回执行某操作所需的最低角色
func MinRole(action Action) string {
	switch action {
	case ActionProjectCreate:
		return TeamRoleDirector
	case ActionProjectDelete, ActionManageMembers:
		return TeamRoleOwner
	case ActionEdit, ActionGenerate:
		return TeamRoleEditor
	case ActionReview, ActionViewAuditLog:
		return TeamRoleDirector
	case ActionProjectView:
		return TeamRoleViewer
	default:
		return TeamRoleOwner
	}
}

// roleWeight 角色权重，用于比较权限高低
func roleWeight(role string) int {
	switch role {
	case TeamRoleOwner:
		return 40
	case TeamRoleDirector:
		return 30
	case TeamRoleEditor:
		return 20
	case TeamRoleViewer:
		return 10
	default:
		return 0
	}
}

// IsAllowed 检查用户有效角色是否满足操作所需权限
func IsAllowed(effectiveRole string, action Action) bool {
	return roleWeight(effectiveRole) >= roleWeight(MinRole(action))
}
