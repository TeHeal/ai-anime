package middleware

import (
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// JWTAuth JWT 鉴权中间件，解析 Bearer Token 并将 user_id、username、role 写入上下文
// secret 应从配置加载，禁止硬编码
func JWTAuth(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")
		if header == "" {
			pkg.Unauthorized(c, "缺少 Authorization 头")
			c.Abort()
			return
		}

		parts := strings.SplitN(header, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			pkg.Unauthorized(c, "Authorization 格式错误，应为 Bearer <token>")
			c.Abort()
			return
		}

		claims, err := pkg.ParseToken(secret, parts[1])
		if err != nil {
			pkg.Unauthorized(c, "Token 无效或已过期")
			c.Abort()
			return
		}

		c.Set("user_id", claims.UserID) // string，兼容 UUID
		c.Set("username", claims.Username)
		c.Set("role", claims.Role)
		c.Next()
	}
}
