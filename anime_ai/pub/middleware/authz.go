package middleware

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// RequireAction 返回鉴权中间件，检查当前用户是否有权执行指定操作
// 必须在 ProjectContext 中间件之后使用
func RequireAction(action auth.Action) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := auth.FromContext(c)
		if !id.Can(action) {
			pkg.Forbidden(c, "权限不足：当前角色无权执行此操作")
			c.Abort()
			return
		}
		c.Next()
	}
}
