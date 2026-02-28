package middleware

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// AdminOnly 仅允许系统管理员访问
func AdminOnly() gin.HandlerFunc {
	return func(c *gin.Context) {
		role, exists := c.Get("role")
		if !exists || role.(string) != "admin" {
			pkg.Forbidden(c, "需要管理员权限")
			c.Abort()
			return
		}
		c.Next()
	}
}
