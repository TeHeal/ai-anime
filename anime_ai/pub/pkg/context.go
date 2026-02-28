package pkg

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

// UintToStr 将 uint 转为字符串
func UintToStr(u uint) string {
	return strconv.FormatUint(uint64(u), 10)
}

// GetUserIDStr 从 Gin 上下文获取 user_id 字符串（兼容 uint 与 string）
func GetUserIDStr(c *gin.Context) string {
	v, ok := c.Get("user_id")
	if !ok {
		return ""
	}
	if s, ok := v.(string); ok {
		return s
	}
	if u, ok := v.(uint); ok {
		return strconv.FormatUint(uint64(u), 10)
	}
	if u, ok := v.(uint64); ok {
		return strconv.FormatUint(u, 10)
	}
	return ""
}
