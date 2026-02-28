package auth

import "github.com/gin-gonic/gin"

const (
	ctxUserID        = "user_id"
	ctxUsername       = "username"
	ctxSysRole       = "role"
	ctxProjectID     = "project_id"
	ctxEffectiveRole = "effective_role"
	ctxRoles         = "roles"
	ctxOrgID         = "org_id"
	ctxTeamID        = "team_id"
)

// Identity 用户身份与项目内角色，由中间件解析后写入上下文
type Identity struct {
	UserID        uint
	Username      string
	SysRole       string
	ProjectID     uint
	EffectiveRole string
	Roles         []string // 多角色列表
	OrgID         uint
	TeamID        uint
}

// FromContext 从 Gin 上下文提取身份（由 JWT/ProjectContext 中间件设置）
func FromContext(c *gin.Context) Identity {
	var roles []string
	if v, ok := c.Get(ctxRoles); ok {
		if r, ok := v.([]string); ok {
			roles = r
		}
	}
	return Identity{
		UserID:        c.GetUint(ctxUserID),
		Username:      c.GetString(ctxUsername),
		SysRole:       c.GetString(ctxSysRole),
		ProjectID:     c.GetUint(ctxProjectID),
		EffectiveRole: c.GetString(ctxEffectiveRole),
		Roles:         roles,
		OrgID:         c.GetUint(ctxOrgID),
		TeamID:        c.GetUint(ctxTeamID),
	}
}

// SetProjectContext 将项目级身份写入 Gin 上下文（ProjectContext 中间件调用）
func SetProjectContext(c *gin.Context, projectID uint, effectiveRole string, orgID, teamID uint) {
	c.Set(ctxProjectID, projectID)
	c.Set(ctxEffectiveRole, effectiveRole)
	c.Set(ctxOrgID, orgID)
	c.Set(ctxTeamID, teamID)
}

// SetRoles 将用户多角色写入上下文
func SetRoles(c *gin.Context, roles []string) {
	c.Set(ctxRoles, roles)
	if len(roles) > 0 {
		c.Set(ctxEffectiveRole, roles[0])
	}
}

// IsAdmin 是否为系统管理员
func (id Identity) IsAdmin() bool {
	return id.SysRole == RoleAdmin
}

// Can 检查当前身份是否有权限执行指定操作（多角色并集）
func (id Identity) Can(action Action) bool {
	if id.IsAdmin() {
		return true
	}
	if len(id.Roles) > 0 {
		return IsAllowedMultiRole(id.Roles, action)
	}
	return IsAllowed(id.EffectiveRole, action)
}
