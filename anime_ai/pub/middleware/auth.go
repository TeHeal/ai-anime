package middleware

import (
	"strconv"
	"strings"

	"anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// JWTAuth JWT 鉴权中间件，解析 Bearer Token 并将 user_id、username、role 写入上下文
// secret 应从配置加载，禁止硬编码
// user_id 同时存 string 与 uint，兼容 GetUserIDStr 与 GetUint 两种用法
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

		// user_id 存 uint 时 GetUserIDStr/GetUint 均可用；非数字则存 string
		if id, err := strconv.ParseUint(claims.UserID, 10, 64); err == nil {
			c.Set("user_id", uint(id))
		} else {
			c.Set("user_id", claims.UserID)
		}
		c.Set("username", claims.Username)
		c.Set("role", claims.Role)
		c.Next()
	}
}
