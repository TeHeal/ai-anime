package middleware

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

// OptimisticLock 读取 X-Resource-Version 头并存入上下文。
// Handler 和 Service 可用 RequireVersion 或 CompareVersion 做冲突检测。
func OptimisticLock() gin.HandlerFunc {
	return func(c *gin.Context) {
		if v := c.GetHeader("X-Resource-Version"); v != "" {
			if ver, err := strconv.Atoi(v); err == nil {
				c.Set("resource_version", ver)
			}
		}
		c.Next()
	}
}

// RequireVersion 从上下文提取 version，用于乐观锁校验；若格式错误则返回 400
func RequireVersion(c *gin.Context) (int, bool) {
	v, exists := c.Get("resource_version")
	if !exists {
		return 0, true
	}
	ver, ok := v.(int)
	if !ok {
		pkg.BadRequest(c, "X-Resource-Version 格式错误")
		return 0, false
	}
	return ver, true
}

// 注意：CASUpdate、StatusCAS 依赖 gorm.DB，用于版本化更新与状态转换。
// 新版使用 sqlc，此类逻辑应移至 module 的 service 层，由 data 层封装具体 SQL。
// 此处仅保留 OptimisticLock、RequireVersion 等与上下文相关的中间件能力。
