package auth

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

const (
	ctxUserID        = "user_id"
	ctxUsername       = "username"
	ctxSysRole       = "role"
	ctxProjectID     = "project_id"
	ctxProjectIDStr  = "project_id_str" // 项目 ID 为 UUID 时使用
	ctxEffectiveRole = "effective_role"
	ctxJobRoles      = "job_roles" // 工种角色列表（RBAC 精细权限）
	ctxOrgID         = "org_id"
	ctxTeamID        = "team_id"
)

// Identity 用户身份与项目内角色，由中间件解析后写入上下文
type Identity struct {
	UserID        uint
	Username      string
	SysRole       string
	ProjectID     uint
	ProjectIDStr  string   // 项目 ID 字符串（UUID），优先使用
	EffectiveRole string   // 层级角色：owner/director/editor/viewer
	JobRoles      []string // 工种角色：director/storyboarder/designer 等，用于精细权限
	OrgID         uint
	TeamID        uint
}

// FromContext 从 Gin 上下文提取身份（由 JWT/ProjectContext 中间件设置）
func FromContext(c *gin.Context) Identity {
	var jobRoles []string
	if v, ok := c.Get(ctxJobRoles); ok {
		if roles, ok := v.([]string); ok {
			jobRoles = roles
		}
	}
	return Identity{
		UserID:        c.GetUint(ctxUserID),
		Username:      c.GetString(ctxUsername),
		SysRole:       c.GetString(ctxSysRole),
		ProjectID:     c.GetUint(ctxProjectID),
		ProjectIDStr:  c.GetString(ctxProjectIDStr),
		EffectiveRole: c.GetString(ctxEffectiveRole),
		JobRoles:      jobRoles,
		OrgID:         c.GetUint(ctxOrgID),
		TeamID:        c.GetUint(ctxTeamID),
	}
}

// SetProjectContext 将项目级身份写入 Gin 上下文（ProjectContext 中间件调用，兼容数字 id）
func SetProjectContext(c *gin.Context, projectID uint, effectiveRole string, jobRoles []string, orgID, teamID uint) {
	c.Set(ctxProjectID, projectID)
	c.Set(ctxEffectiveRole, effectiveRole)
	c.Set(ctxJobRoles, jobRoles)
	c.Set(ctxOrgID, orgID)
	c.Set(ctxTeamID, teamID)
}

// SetProjectContextString 当项目 ID 为 UUID 字符串时写入上下文
func SetProjectContextString(c *gin.Context, projectIDStr, effectiveRole string, jobRoles []string, teamID uint) {
	c.Set(ctxProjectIDStr, projectIDStr)
	c.Set(ctxEffectiveRole, effectiveRole)
	c.Set(ctxJobRoles, jobRoles)
	c.Set(ctxOrgID, 0)
	c.Set(ctxTeamID, teamID)
}

// GetProjectIDStr 从上下文取项目 ID 字符串（兼容数字 id 与 UUID）
func GetProjectIDStr(c *gin.Context) string {
	if s := c.GetString(ctxProjectIDStr); s != "" {
		return s
	}
	if id := c.GetUint(ctxProjectID); id != 0 {
		return strconv.FormatUint(uint64(id), 10)
	}
	return c.Param("id")
}

// IsAdmin 是否为系统管理员
func (id Identity) IsAdmin() bool {
	return id.SysRole == "admin"
}

// Can 检查当前身份是否有权限执行指定操作
// 双通道：层级角色 (owner/director/editor/viewer) 兼容旧逻辑 + 工种 (jobRoles) 精细权限
func (id Identity) Can(action Action) bool {
	if id.IsAdmin() {
		return true
	}
	if IsAllowed(id.EffectiveRole, action) {
		return true
	}
	return CanDo(id.JobRoles, action)
}
