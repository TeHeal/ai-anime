package main

import (
	"github.com/TeHeal/ai-anime/anime_ai/module/health"
	"github.com/gin-gonic/gin"
)

func registerRoutes(r *gin.Engine) {
	api := r.Group("/api/v1")
	{
		api.GET("/health", health.Handler)
	}
}
