package health

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Handler 健康检查
func Handler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "ok",
	})
}
