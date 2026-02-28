package auth

import "github.com/gin-gonic/gin"

const (
	ctxUserID        = "user_id"
	ctxUsername      = "username"
	ctxSysRole       = "role"
	ctxProjectID     = "project_id"
	ctxEffectiveRole = "effective_role"
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
	OrgID         uint
	TeamID        uint
}

// FromContext 从 Gin 上下文提取身份（由 JWT/ProjectContext 中间件设置）
func FromContext(c *gin.Context) Identity {
	return Identity{
		UserID:        c.GetUint(ctxUserID),
		Username:      c.GetString(ctxUsername),
		SysRole:       c.GetString(ctxSysRole),
		ProjectID:     c.GetUint(ctxProjectID),
		EffectiveRole: c.GetString(ctxEffectiveRole),
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

// IsAdmin 是否为系统管理员
func (id Identity) IsAdmin() bool {
	return id.SysRole == "admin"
}

// Can 检查当前身份是否有权限执行指定操作
func (id Identity) Can(action Action) bool {
	if id.IsAdmin() {
		return true
	}
	return IsAllowed(id.EffectiveRole, action)
}
