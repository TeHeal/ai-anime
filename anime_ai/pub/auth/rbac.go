package auth

// 项目内角色常量（用户可拥有多个角色，权限取并集）
const (
	RoleDirector       = "director"       // 导演：创意方向、分镜审定、最终审核
	RoleStoryboarder   = "storyboarder"   // 分镜师：分镜脚本、镜头指令
	RoleDesigner       = "designer"       // 设计师：角色、场景、道具、风格资产
	RoleArtist         = "artist"         // 原画师：镜图生成
	RoleCinematographer = "cinematographer" // 镜头师：镜头视频生成
	RolePostProducer   = "post_producer"  // 后期：成片剪辑、音频、字幕、导出
	RoleReviewer       = "reviewer"       // 审核：各环节 QA
	RoleAdmin          = "admin"          // 平台管理员

	// 向后兼容：旧角色映射
	RoleViewer = "viewer" // 仅查看
)

// AllProjectRoles 所有可分配的项目角色
var AllProjectRoles = []string{
	RoleDirector, RoleStoryboarder, RoleDesigner, RoleArtist,
	RoleCinematographer, RolePostProducer, RoleReviewer,
}

// Action 需要鉴权的操作
type Action string

const (
	ActionProjectCreate Action = "project.create"
	ActionProjectDelete Action = "project.delete"
	ActionProjectView   Action = "project.view"

	ActionStoryEdit   Action = "story.edit"
	ActionAssetManage Action = "asset.manage"
	ActionScriptEdit  Action = "script.edit"

	ActionShotImageGenerate Action = "shot_image.generate"
	ActionShotVideoGenerate Action = "shot_video.generate"
	ActionCompositeEdit     Action = "composite.edit"

	ActionReviewDecide  Action = "review.decide"
	ActionManageMembers Action = "members.manage"
	ActionScheduleManage Action = "schedule.manage"
	ActionViewAuditLog  Action = "audit.view"
)

// rolePermissions 每种角色可执行的操作集合
var rolePermissions = map[string]map[Action]bool{
	RoleDirector: {
		ActionProjectCreate: true, ActionProjectDelete: true, ActionProjectView: true,
		ActionStoryEdit: true, ActionAssetManage: true, ActionScriptEdit: true,
		ActionShotImageGenerate: true, ActionShotVideoGenerate: true, ActionCompositeEdit: true,
		ActionReviewDecide: true, ActionManageMembers: true, ActionScheduleManage: true,
		ActionViewAuditLog: true,
	},
	RoleStoryboarder: {
		ActionProjectView: true, ActionStoryEdit: true, ActionScriptEdit: true,
		ActionReviewDecide: true,
	},
	RoleDesigner: {
		ActionProjectView: true, ActionAssetManage: true,
	},
	RoleArtist: {
		ActionProjectView: true, ActionShotImageGenerate: true,
	},
	RoleCinematographer: {
		ActionProjectView: true, ActionShotVideoGenerate: true,
	},
	RolePostProducer: {
		ActionProjectView: true, ActionCompositeEdit: true,
	},
	RoleReviewer: {
		ActionProjectView: true, ActionReviewDecide: true, ActionViewAuditLog: true,
	},
	RoleViewer: {
		ActionProjectView: true,
	},
}

// IsRoleAllowed 检查单个角色是否有权限执行操作
func IsRoleAllowed(role string, action Action) bool {
	perms, ok := rolePermissions[role]
	if !ok {
		return false
	}
	return perms[action]
}

// IsAllowedMultiRole 检查多角色并集是否有权限（用户可拥有多角色）
func IsAllowedMultiRole(roles []string, action Action) bool {
	for _, r := range roles {
		if IsRoleAllowed(r, action) {
			return true
		}
	}
	return false
}

// IsAllowed 向后兼容：单角色检查
func IsAllowed(effectiveRole string, action Action) bool {
	return IsRoleAllowed(effectiveRole, action)
}

// IsValidRole 检查角色名称是否合法
func IsValidRole(role string) bool {
	for _, r := range AllProjectRoles {
		if r == role {
			return true
		}
	}
	return role == RoleViewer || role == RoleAdmin
}
