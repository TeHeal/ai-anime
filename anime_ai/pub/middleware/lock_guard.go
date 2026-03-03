package middleware

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// LockGuard 当指定阶段已锁定时，拒绝写操作。项目 ID 从上下文或 :id 参数读取（支持 UUID）。
func LockGuard(lockChecker LockChecker, phase string) gin.HandlerFunc {
	return func(c *gin.Context) {
		projectIDStr := auth.GetProjectIDStr(c)
		if projectIDStr == "" {
			c.Next()
			return
		}
		locked, err := lockChecker.IsLocked(projectIDStr, phase)
		if err != nil {
			c.Next()
			return
		}
		if locked {
			pkg.Fail(c, 423, phase+" 阶段已锁定，无法执行此操作")
			c.Abort()
			return
		}
		c.Next()
	}
}
