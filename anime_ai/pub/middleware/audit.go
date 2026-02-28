package middleware

import (
	"encoding/json"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/gin-gonic/gin"
)

// Audit 自动记录写操作（POST/PUT/DELETE）到审计日志
func Audit(auditWriter AuditWriter) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		method := c.Request.Method
		if method == "GET" || method == "OPTIONS" || method == "HEAD" {
			return
		}

		status := c.Writer.Status()
		if status >= 400 {
			return
		}

		id := auth.FromContext(c)
		action := resolveAction(method, c.FullPath())
		resType, resID := resolveResource(c)

		detail, _ := json.Marshal(map[string]any{
			"method":   method,
			"path":     c.Request.URL.Path,
			"status":   status,
			"res_type": resType,
			"res_id":   resID,
		})

		entry := &AuditLogEntry{
			OrgID:        nilIfZero(id.OrgID),
			ProjectID:    nilIfZero(id.ProjectID),
			UserID:       id.UserID,
			Action:       action,
			ResourceType: resType,
			ResourceID:   resID,
			DetailJSON:   string(detail),
			IP:           c.ClientIP(),
			UserAgent:    truncate(c.Request.UserAgent(), 256),
		}

		_ = auditWriter.Create(entry)
	}
}

func resolveAction(method, path string) string {
	switch method {
	case "POST":
		if strings.Contains(path, "generate") || strings.Contains(path, "parse") {
			return "ai.generate"
		}
		if strings.Contains(path, "confirm") {
			return "content.confirm"
		}
		if strings.Contains(path, "review") || strings.Contains(path, "batch-review") {
			return "review.decide"
		}
		return "content.create"
	case "PUT", "PATCH":
		return "content.update"
	case "DELETE":
		return "content.delete"
	default:
		return "unknown"
	}
}

func resolveResource(c *gin.Context) (string, uint) {
	path := c.FullPath()
	parts := strings.Split(strings.Trim(path, "/"), "/")

	for i := len(parts) - 1; i >= 0; i-- {
		if parts[i] == ":id" || parts[i] == ":shotId" || parts[i] == ":epId" ||
			parts[i] == ":sceneId" || parts[i] == ":locId" || parts[i] == ":propId" {
			paramName := strings.Trim(parts[i], ":")
			val := c.Param(paramName)
			if val == "" && parts[i] == ":id" {
				val = c.Param("id")
			}
			var id uint
			if v, ok := parseUint(val); ok {
				id = v
			}
			if i > 0 {
				return parts[i-1], id
			}
		}
	}
	if len(parts) >= 3 {
		return parts[len(parts)-1], 0
	}
	return "", 0
}

func parseUint(s string) (uint, bool) {
	for _, c := range s {
		if c < '0' || c > '9' {
			return 0, false
		}
	}
	if len(s) == 0 {
		return 0, false
	}
	var n uint
	for _, c := range s {
		n = n*10 + uint(c-'0')
	}
	return n, true
}

func nilIfZero(v uint) *uint {
	if v == 0 {
		return nil
	}
	return &v
}

func truncate(s string, max int) string {
	if len(s) <= max {
		return s
	}
	return s[:max]
}
