package auth

// 项目/团队内层级角色（用于访问级别）
const (
	TeamRoleOwner    = "owner"
	TeamRoleDirector = "director"
	TeamRoleEditor   = "editor"
	TeamRoleViewer   = "viewer"
)

// JobRole 工种角色（README §4），用户可拥有多个，权限取并集
const (
	JobDirector     = "director"     // 导演：创意方向、全环节审核
	JobStoryboarder = "storyboarder" // 分镜师：分镜脚本、脚本阶段审定
	JobDesigner     = "designer"     // 设计师：角色、场景、道具、风格资产
	JobKeyAnimator  = "key_animator" // 原画师：镜图生成、镜图
	JobShotArtist   = "shot_artist"  // 镜头师：镜头视频生成
	JobPost         = "post"         // 后期：成片剪辑、导出
	JobReviewer     = "reviewer"     // 审核：各环节 QA、批量审核、退回
	JobAdmin        = "admin"        // 平台管理员：用户、组织、AI 配置
)

// Action 需要鉴权的操作
type Action string

const (
	ActionProjectCreate Action = "project.create"
	ActionProjectDelete Action = "project.delete"
	ActionProjectView   Action = "project.view"
	ActionEdit          Action = "content.edit"
	ActionGenerate      Action = "ai.generate"
	ActionReview        Action = "review.decide"
	ActionManageMembers Action = "members.manage"
	ActionViewAuditLog  Action = "audit.view"
	// 资源级 Action（用于状态+权限校验）
	ActionScriptEdit      Action = "script.edit"
	ActionScriptReview    Action = "script.review"
	ActionShotImageEdit   Action = "shot_image.edit"
	ActionShotImageGen    Action = "shot_image.generate"
	ActionShotImageReview Action = "shot_image.review"
	ActionShotVideoEdit   Action = "shot_video.edit"
	ActionShotVideoGen    Action = "shot_video.generate"
	ActionShotVideoReview Action = "shot_video.review"
	ActionCompositeEdit   Action = "composite.edit"
	ActionCompositeExport Action = "composite.export"
	ActionAssetEdit       Action = "asset.edit"
)

// ResourceType 资源类型
const (
	ResourceScript    = "script"
	ResourceShotImage = "shot_image"
	ResourceShotVideo = "shot_video"
	ResourceComposite = "composite"
	ResourceAsset     = "asset"
)

// jobRoleToActions 工种 → 可执行 Action 映射
var jobRoleToActions = map[string][]Action{
	JobDirector: {
		ActionProjectCreate, ActionProjectDelete, ActionProjectView,
		ActionEdit, ActionGenerate, ActionReview, ActionManageMembers, ActionViewAuditLog,
		ActionScriptEdit, ActionScriptReview,
		ActionShotImageEdit, ActionShotImageGen, ActionShotImageReview,
		ActionShotVideoEdit, ActionShotVideoGen, ActionShotVideoReview,
		ActionCompositeEdit, ActionCompositeExport, ActionAssetEdit,
	},
	JobStoryboarder: {
		ActionProjectView, ActionEdit, ActionGenerate,
		ActionScriptEdit, ActionScriptReview,
		ActionShotImageEdit, ActionShotImageGen,
		ActionAssetEdit,
	},
	JobDesigner: {
		ActionProjectView, ActionEdit, ActionGenerate,
		ActionShotImageEdit, ActionShotImageGen,
		ActionAssetEdit,
	},
	JobKeyAnimator: {
		ActionProjectView, ActionEdit, ActionGenerate,
		ActionShotImageEdit, ActionShotImageGen, ActionShotImageReview,
	},
	JobShotArtist: {
		ActionProjectView, ActionEdit, ActionGenerate,
		ActionShotVideoEdit, ActionShotVideoGen, ActionShotVideoReview,
	},
	JobPost: {
		ActionProjectView, ActionEdit,
		ActionCompositeEdit, ActionCompositeExport,
	},
	JobReviewer: {
		ActionProjectView,
		ActionScriptReview, ActionShotImageReview, ActionShotVideoReview,
	},
	JobAdmin: {}, // 平台级，在 IsAdmin 中单独处理
}

// EffectivePermissions 多角色并集：合并各工种的权限
func EffectivePermissions(jobRoles []string) map[Action]bool {
	m := make(map[Action]bool)
	for _, r := range jobRoles {
		for _, a := range jobRoleToActions[r] {
			m[a] = true
		}
	}
	return m
}

// CanDo 检查用户工种列表是否有权执行某操作
func CanDo(jobRoles []string, action Action) bool {
	perms := EffectivePermissions(jobRoles)
	return perms[action]
}

// MinRole 返回执行某操作所需的最低层级角色（兼容旧逻辑）
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

// roleWeight 层级角色权重，用于比较
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

// IsAllowed 检查层级角色是否满足操作所需（兼容旧逻辑）
func IsAllowed(effectiveRole string, action Action) bool {
	return roleWeight(effectiveRole) >= roleWeight(MinRole(action))
}

// ResourceStateRule 资源状态下的操作规则：(资源类型, 状态) -> 允许的 Action
// 用于 CheckResourceAction
var resourceStateRules = map[string]map[string][]Action{
	ResourceScript: {
		"editing":   {ActionScriptEdit, ActionScriptReview},
		"generated": {ActionScriptEdit, ActionScriptReview},
		"frozen":    {ActionScriptReview}, // 仅审核可操作
	},
	ResourceShotImage: {
		"draft":      {ActionShotImageEdit, ActionShotImageGen},
		"pending":    {ActionShotImageEdit, ActionShotImageGen, ActionShotImageReview},
		"generating": {},
		"review":     {ActionShotImageReview},
		"approved":   {},
		"rejected":   {ActionShotImageEdit, ActionShotImageGen},
		"locked":     {},
	},
	ResourceShotVideo: {
		"draft":      {ActionShotVideoEdit, ActionShotVideoGen},
		"pending":    {ActionShotVideoEdit, ActionShotVideoGen, ActionShotVideoReview},
		"generating": {},
		"review":     {ActionShotVideoReview},
		"approved":   {},
		"rejected":   {ActionShotVideoEdit, ActionShotVideoGen},
		"locked":     {},
	},
	ResourceComposite: {
		"editing":   {ActionCompositeEdit, ActionCompositeExport},
		"exporting": {ActionCompositeExport},
		"done":      {ActionCompositeExport},
	},
}

// CheckResourceAction 检查用户在给定资源类型、状态下是否有权执行某操作
// jobRoles: 用户工种列表；isOwner: 是否为项目创建者（拥有导演权限）
func CheckResourceAction(resourceType, status string, action Action, jobRoles []string, isOwner bool) bool {
	if isOwner {
		return CanDo([]string{JobDirector}, action)
	}
	stateRules, ok := resourceStateRules[resourceType]
	if !ok {
		return CanDo(jobRoles, action)
	}
	allowedForState, ok := stateRules[status]
	if !ok {
		// 未知状态，仅按工种判断
		return CanDo(jobRoles, action)
	}
	for _, a := range allowedForState {
		if a == action {
			return CanDo(jobRoles, action)
		}
	}
	return false
}

// AllowedActionsForResource 返回用户在给定资源类型、状态下可执行的操作列表
func AllowedActionsForResource(resourceType, status string, jobRoles []string, isOwner bool) []Action {
	roles := jobRoles
	if isOwner {
		roles = []string{JobDirector}
	}
	perms := EffectivePermissions(roles)
	stateRules, ok := resourceStateRules[resourceType]
	if !ok {
		var out []Action
		for a := range perms {
			out = append(out, a)
		}
		return out
	}
	allowedForState, ok := stateRules[status]
	if !ok {
		var out []Action
		for a := range perms {
			out = append(out, a)
		}
		return out
	}
	var out []Action
	for _, a := range allowedForState {
		if perms[a] {
			out = append(out, a)
		}
	}
	return out
}
