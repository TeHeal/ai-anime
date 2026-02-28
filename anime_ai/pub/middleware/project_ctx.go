package middleware

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// ProjectContext 从 :id 参数解析项目，确定用户有效角色（project_member > team_member > owner）。
// 将 project_id、effective_role、org_id、team_id 写入上下文。
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
		projectID, err := strconv.ParseUint(idStr, 10, 64)
		if err != nil {
			c.Next()
			return
		}

		userID := c.GetUint("user_id")
		sysRole := c.GetString("role")

		// 系统管理员拥有全部权限
		if sysRole == "admin" {
			auth.SetProjectContext(c, uint(projectID), auth.RoleDirector, 0, 0)
			auth.SetRoles(c, []string{auth.RoleDirector})
			c.Next()
			return
		}

		// 检查是否为项目所有者
		project, err := projectReader.FindByIDOnly(uint(projectID))
		if err != nil {
			pkg.NotFound(c, "项目不存在")
			c.Abort()
			return
		}

		if project.UserID == userID {
			auth.SetProjectContext(c, uint(projectID), auth.RoleDirector, 0, project.TeamID)
			auth.SetRoles(c, []string{auth.RoleDirector})
			c.Next()
			return
		}

		// 检查项目级成员（优先级最高）
		if pm, err := projectMemberReader.FindByProjectAndUser(uint(projectID), userID); err == nil {
			auth.SetProjectContext(c, uint(projectID), pm.Role, 0, project.TeamID)
			c.Next()
			return
		}

		// 检查团队级成员
		if project.TeamID > 0 {
			if tm, err := teamMemberReader.FindByTeamAndUser(project.TeamID, userID); err == nil {
				auth.SetProjectContext(c, uint(projectID), tm.Role, 0, project.TeamID)
				c.Next()
				return
			}
		}

		// 无权限
		pkg.Forbidden(c, "无权访问此项目")
		c.Abort()
	}
}
