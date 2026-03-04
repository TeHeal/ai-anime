package middleware

import (
	"anime_ai/pub/auth"
	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// ProjectContext 从 :id 参数解析项目（支持 UUID 与数字串），确定用户有效角色和工种并写入上下文。
func ProjectContext(
	projectReader ProjectReader,
	projectMemberReader ProjectMemberReader,
	teamMemberReader TeamMemberReader,
) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		if idStr == "" {
			c.Next()
			return
		}
		project, err := projectReader.FindByIDOnly(idStr)
		if err != nil {
			pkg.NotFound(c, "项目不存在")
			c.Abort()
			return
		}
		userIDStr := pkg.GetUserIDStr(c)
		sysRole := c.GetString("role")
		// 系统管理员：拥有 owner 角色 + 导演全部工种
		if sysRole == "admin" {
			auth.SetProjectContextString(c, idStr, auth.TeamRoleOwner, []string{auth.JobDirector}, project.TeamID)
			c.Next()
			return
		}
		isOwner := project.UserIDStr != "" && project.UserIDStr == userIDStr
		if !isOwner && project.UserID != 0 {
			isOwner = c.GetUint("user_id") == project.UserID
		}
		// 项目创建者：自动拥有导演工种
		if isOwner {
			auth.SetProjectContextString(c, idStr, auth.TeamRoleOwner, []string{auth.JobDirector}, project.TeamID)
			c.Next()
			return
		}
		// 项目成员：使用 project_members 中的 role + job_roles
		if pm, err := projectMemberReader.FindByProjectAndUser(idStr, userIDStr); err == nil {
			auth.SetProjectContextString(c, idStr, pm.Role, pm.JobRoles, project.TeamID)
			c.Next()
			return
		}
		// 团队成员：使用 team_members 中的 role + job_roles 作为默认
		if project.TeamID > 0 {
			if tm, err := teamMemberReader.FindByTeamAndUser(project.TeamID, c.GetUint("user_id")); err == nil {
				auth.SetProjectContextString(c, idStr, tm.Role, tm.JobRoles, project.TeamID)
				c.Next()
				return
			}
		}
		pkg.Forbidden(c, "无权访问此项目")
		c.Abort()
	}
}
