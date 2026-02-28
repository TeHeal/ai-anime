package middleware

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// LockGuard 当指定阶段已锁定时，拒绝写操作。项目 ID 从 :id 参数解析。
func LockGuard(lockChecker LockChecker, phase string) gin.HandlerFunc {
	return func(c *gin.Context) {
		projectID, err := strconv.ParseUint(c.Param("id"), 10, 64)
		if err != nil {
			c.Next()
			return
		}

		locked, err := lockChecker.IsLocked(uint(projectID), phase)
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
