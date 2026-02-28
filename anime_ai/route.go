package main

import (
	"github.com/TeHeal/ai-anime/anime_ai/module/auth"
	"github.com/TeHeal/ai-anime/anime_ai/module/character"
	"github.com/TeHeal/ai-anime/anime_ai/module/episode"
	"github.com/TeHeal/ai-anime/anime_ai/module/health"
	"github.com/TeHeal/ai-anime/anime_ai/module/location"
	"github.com/TeHeal/ai-anime/anime_ai/module/project"
	"github.com/TeHeal/ai-anime/anime_ai/module/prop"
	"github.com/TeHeal/ai-anime/anime_ai/module/composite"
	"github.com/TeHeal/ai-anime/anime_ai/module/notification"
	"github.com/TeHeal/ai-anime/anime_ai/module/review"
	"github.com/TeHeal/ai-anime/anime_ai/module/schedule"
	"github.com/TeHeal/ai-anime/anime_ai/module/style"
	"github.com/TeHeal/ai-anime/anime_ai/module/tasklock"
	"github.com/TeHeal/ai-anime/anime_ai/module/scene"
	"github.com/TeHeal/ai-anime/anime_ai/module/script"
	"github.com/TeHeal/ai-anime/anime_ai/module/shot"
	"github.com/TeHeal/ai-anime/anime_ai/module/shot_image"
	"github.com/TeHeal/ai-anime/anime_ai/module/storyboard"
	"github.com/TeHeal/ai-anime/anime_ai/pub/middleware"
	"github.com/TeHeal/ai-anime/anime_ai/pub/realtime"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func registerRoutes(r *gin.Engine, cfg *RouteConfig) {
	api := r.Group("/api/v1")
	{
		api.GET("/metrics", gin.WrapH(promhttp.Handler()))
		api.GET("/health", health.Handler)
	}

	// WebSocket（需 JWT，通过 query token 或 Authorization: Bearer）
	if cfg.WSHandler != nil {
		api.GET("/ws", cfg.WSHandler.Connect)
	}

	// 认证相关（公开）
	authGroup := api.Group("/auth")
	{
		authGroup.POST("/login", cfg.AuthHandler.Login)
	}

	// 需 JWT 鉴权的接口
	protected := api.Group("")
	protected.Use(middleware.JWTAuth(cfg.JWTSecret))
	{
		protected.GET("/auth/me", cfg.AuthHandler.Me)
		protected.PUT("/auth/password", cfg.AuthHandler.ChangePassword)

		// 用户管理（需管理员权限）
		users := protected.Group("/users")
		users.Use(middleware.AdminOnly())
		{
			users.POST("", cfg.AuthHandler.CreateUser)
			users.GET("", cfg.AuthHandler.ListUsers)
			users.DELETE("/:userId", cfg.AuthHandler.DeleteUser)
		}

		// 通知接口（用户级别）
		if cfg.NotifHandler != nil {
			notifs := protected.Group("/notifications")
			{
				notifs.GET("", cfg.NotifHandler.List)
				notifs.GET("/unread-count", cfg.NotifHandler.UnreadCount)
				notifs.PUT("/:notifId/read", cfg.NotifHandler.MarkRead)
				notifs.PUT("/read-all", cfg.NotifHandler.MarkAllRead)
			}
		}

		// 项目管理
		if cfg.ProjectHandler != nil {
			projects := protected.Group("/projects")
			{
				projects.POST("", cfg.ProjectHandler.Create)
				projects.GET("", cfg.ProjectHandler.List)
				projects.GET("/:id", cfg.ProjectHandler.Get)
				projects.PUT("/:id", cfg.ProjectHandler.Update)
				projects.DELETE("/:id", cfg.ProjectHandler.Delete)
				projects.GET("/:id/props", cfg.ProjectHandler.GetProps)
				projects.PUT("/:id/props", cfg.ProjectHandler.UpdateProps)
				// 项目成员
				projects.GET("/:id/members", cfg.ProjectHandler.ListMembers)
				projects.POST("/:id/members", cfg.ProjectHandler.AddMember)
				projects.PUT("/:id/members/:userId", cfg.ProjectHandler.UpdateMemberRole)
				projects.DELETE("/:id/members/:userId", cfg.ProjectHandler.RemoveMember)

				// 集 CRUD
				if cfg.EpisodeHandler != nil {
					projects.POST("/:id/episodes", cfg.EpisodeHandler.Create)
					projects.GET("/:id/episodes", cfg.EpisodeHandler.List)
					projects.GET("/:id/episodes/:epId", cfg.EpisodeHandler.Get)
					projects.PUT("/:id/episodes/:epId", cfg.EpisodeHandler.Update)
					projects.DELETE("/:id/episodes/:epId", cfg.EpisodeHandler.Delete)
					projects.PUT("/:id/episodes/reorder", cfg.EpisodeHandler.Reorder)
				}

				// 场 CRUD（嵌套在集下）
				if cfg.SceneHandler != nil {
					projects.POST("/:id/episodes/:epId/scenes", cfg.SceneHandler.Create)
					projects.GET("/:id/episodes/:epId/scenes", cfg.SceneHandler.List)
					projects.GET("/:id/episodes/:epId/scenes/:sceneId", cfg.SceneHandler.Get)
					projects.PUT("/:id/episodes/:epId/scenes/:sceneId", cfg.SceneHandler.Update)
					projects.DELETE("/:id/episodes/:epId/scenes/:sceneId", cfg.SceneHandler.Delete)
					projects.PUT("/:id/episodes/:epId/scenes/reorder", cfg.SceneHandler.Reorder)
					projects.PUT("/:id/episodes/:epId/scenes/:sceneId/blocks", cfg.SceneHandler.SaveBlocks)
				}

				// 块 CRUD（project-scoped sceneId）
				if cfg.SceneHandler != nil {
					projects.POST("/:id/scenes/:sceneId/blocks", cfg.SceneHandler.CreateBlock)
					projects.PUT("/:id/scenes/:sceneId/blocks/:blockId", cfg.SceneHandler.UpdateBlock)
					projects.DELETE("/:id/scenes/:sceneId/blocks/:blockId", cfg.SceneHandler.DeleteBlock)
					projects.PUT("/:id/scenes/:sceneId/blocks/reorder", cfg.SceneHandler.ReorderBlocks)
				}

				// 角色（项目内）
				if cfg.CharacterHandler != nil {
					projects.GET("/:id/characters", cfg.CharacterHandler.ListByProject)
					projects.POST("/:id/characters/analyze-preview", cfg.CharacterHandler.AnalyzePreview)
					projects.POST("/:id/characters/analyze", cfg.CharacterHandler.AnalyzeConfirm)
					projects.POST("/:id/characters/:charId/extract-bio", cfg.CharacterHandler.ExtractBio)
					projects.GET("/:id/character-snapshots", cfg.CharacterHandler.ListSnapshotsByProject)
				}

				// 场景资产（Location）
				if cfg.LocationHandler != nil {
					projects.POST("/:id/locations", cfg.LocationHandler.Create)
					projects.GET("/:id/locations", cfg.LocationHandler.List)
					projects.GET("/:id/locations/:locId", cfg.LocationHandler.Get)
					projects.PUT("/:id/locations/:locId", cfg.LocationHandler.Update)
					projects.DELETE("/:id/locations/:locId", cfg.LocationHandler.Delete)
					projects.POST("/:id/locations/:locId/confirm", cfg.LocationHandler.Confirm)
					projects.POST("/:id/locations/:locId/generate-image", cfg.LocationHandler.GenerateImage)
				}

				// 道具资产（Prop，props-v2）
				if cfg.PropHandler != nil {
					projects.POST("/:id/props-v2", cfg.PropHandler.Create)
					projects.GET("/:id/props-v2", cfg.PropHandler.List)
					projects.GET("/:id/props-v2/:propId", cfg.PropHandler.Get)
					projects.PUT("/:id/props-v2/:propId", cfg.PropHandler.Update)
					projects.DELETE("/:id/props-v2/:propId", cfg.PropHandler.Delete)
					projects.POST("/:id/props-v2/:propId/confirm", cfg.PropHandler.Confirm)
				}

				// 分镜
				if cfg.StoryboardHandler != nil {
					projects.GET("/:id/storyboard", cfg.StoryboardHandler.List)
					projects.POST("/:id/storyboard/preview", cfg.StoryboardHandler.Preview)
					projects.POST("/:id/storyboard/generate", cfg.StoryboardHandler.Generate)
					projects.POST("/:id/storyboard/generate-sync", cfg.StoryboardHandler.GenerateSync)
					projects.POST("/:id/storyboard/confirm", cfg.StoryboardHandler.Confirm)
				}

				// 脚本分段
				if cfg.ScriptHandler != nil {
					projects.POST("/:id/segments", cfg.ScriptHandler.Create)
					projects.PUT("/:id/segments/bulk", cfg.ScriptHandler.BulkCreate)
					projects.GET("/:id/segments", cfg.ScriptHandler.List)
					projects.PUT("/:id/segments/:segId", cfg.ScriptHandler.Update)
					projects.DELETE("/:id/segments/:segId", cfg.ScriptHandler.Delete)
					projects.PUT("/:id/segments/reorder", cfg.ScriptHandler.Reorder)
					// 脚本解析与 AI
					projects.POST("/:id/script/parse", cfg.ScriptHandler.Parse)
					projects.POST("/:id/script/parse-sync", cfg.ScriptHandler.ParseSync)
					projects.GET("/:id/script/preview", cfg.ScriptHandler.Preview)
					projects.POST("/:id/script/confirm", cfg.ScriptHandler.Confirm)
					projects.POST("/:id/script/ai-assist", cfg.ScriptHandler.Assist)
				}

				// 镜头 CRUD、生成、合成
				if cfg.ShotHandler != nil {
					projects.POST("/:id/shots", cfg.ShotHandler.Create)
					projects.POST("/:id/shots/bulk", cfg.ShotHandler.BulkCreate)
					projects.GET("/:id/shots", cfg.ShotHandler.List)
					projects.GET("/:id/shots/:shotId", cfg.ShotHandler.Get)
					projects.PUT("/:id/shots/:shotId", cfg.ShotHandler.Update)
					projects.DELETE("/:id/shots/:shotId", cfg.ShotHandler.Delete)
					projects.PUT("/:id/shots/reorder", cfg.ShotHandler.Reorder)
					projects.POST("/:id/shots/generate", cfg.ShotHandler.BatchGenerate)
					projects.POST("/:id/shots/composite", cfg.ShotHandler.BatchComposite)
				}

			// 成片合成
			if cfg.CompositeHandler != nil {
				projects.POST("/:id/composites", cfg.CompositeHandler.Create)
				projects.GET("/:id/composites", cfg.CompositeHandler.List)
				projects.GET("/:id/composites/:taskId", cfg.CompositeHandler.Get)
				projects.PUT("/:id/composites/:taskId/timeline", cfg.CompositeHandler.UpdateTimeline)
				projects.POST("/:id/composites/:taskId/export", cfg.CompositeHandler.Export)
			}

			// 风格资产
			if cfg.StyleHandler != nil {
				projects.POST("/:id/styles", cfg.StyleHandler.Create)
				projects.GET("/:id/styles", cfg.StyleHandler.List)
				projects.GET("/:id/styles/:styleId", cfg.StyleHandler.Get)
				projects.PUT("/:id/styles/:styleId", cfg.StyleHandler.Update)
				projects.DELETE("/:id/styles/:styleId", cfg.StyleHandler.Delete)
			}

			// 任务锁
			if cfg.TaskLockHandler != nil {
				projects.POST("/:id/task-locks", cfg.TaskLockHandler.Acquire)
				projects.DELETE("/:id/task-locks/:lockId", cfg.TaskLockHandler.Release)
				projects.GET("/:id/task-locks/check", cfg.TaskLockHandler.Check)
			}

			// 定时调度
			if cfg.ScheduleHandler != nil {
				projects.POST("/:id/schedules", cfg.ScheduleHandler.Create)
				projects.GET("/:id/schedules", cfg.ScheduleHandler.List)
				projects.GET("/:id/schedules/:schedId", cfg.ScheduleHandler.Get)
				projects.PUT("/:id/schedules/:schedId", cfg.ScheduleHandler.Update)
				projects.DELETE("/:id/schedules/:schedId", cfg.ScheduleHandler.Delete)
			}

			// 审核管理
			if cfg.ReviewHandler != nil {
				projects.POST("/:id/reviews", cfg.ReviewHandler.SubmitReview)
				projects.GET("/:id/reviews", cfg.ReviewHandler.ListByProject)
				projects.GET("/:id/reviews/pending-count", cfg.ReviewHandler.CountPending)
				projects.PUT("/:id/reviews/:reviewId/decide", cfg.ReviewHandler.HumanDecide)
				projects.GET("/:id/reviews/:reviewId", cfg.ReviewHandler.GetRecord)
				projects.GET("/:id/review-config", cfg.ReviewHandler.GetConfig)
				projects.PUT("/:id/review-config", cfg.ReviewHandler.UpdateConfig)
			}

			// 镜图生成、审核
			if cfg.ShotImageHandler != nil {
					projects.POST("/:id/shot-images/generate", cfg.ShotImageHandler.BatchGenerate)
					projects.GET("/:id/shot-images/status", cfg.ShotImageHandler.GetStatus)
					projects.POST("/:id/shot-images/select-candidate", cfg.ShotImageHandler.SelectCandidate)
					projects.POST("/:id/shot-images/batch-review", cfg.ShotImageHandler.BatchReview)
					projects.GET("/:id/shots/:shotId/candidates", cfg.ShotImageHandler.GetCandidates)
					projects.POST("/:id/shots/:shotId/images", cfg.ShotImageHandler.Create)
					projects.GET("/:id/shots/:shotId/images", cfg.ShotImageHandler.List)
					projects.GET("/:id/shots/:shotId/images/:imageId", cfg.ShotImageHandler.Get)
					projects.DELETE("/:id/shots/:shotId/images/:imageId", cfg.ShotImageHandler.Delete)
					projects.PUT("/:id/shots/:shotId/image-review", cfg.ShotImageHandler.UpdateImageReview)
				}
			}
		}

		// 角色（全局 CRUD）
		if cfg.CharacterHandler != nil {
			characters := protected.Group("/characters")
			{
				characters.POST("", cfg.CharacterHandler.Create)
				characters.GET("", cfg.CharacterHandler.ListLibrary)
				characters.POST("/batch-confirm", cfg.CharacterHandler.BatchConfirm)
				characters.POST("/batch-set-style", cfg.CharacterHandler.BatchSetStyle)
				characters.POST("/batch-ai-complete", cfg.CharacterHandler.BatchAIComplete)
				characters.GET("/:charId", cfg.CharacterHandler.Get)
				characters.PUT("/:charId", cfg.CharacterHandler.Update)
				characters.DELETE("/:charId", cfg.CharacterHandler.Delete)
				characters.POST("/:charId/confirm", cfg.CharacterHandler.Confirm)
				characters.POST("/:charId/generate-image", cfg.CharacterHandler.GenerateImage)
				characters.POST("/:charId/variants", cfg.CharacterHandler.AddVariant)
				characters.PUT("/:charId/variants/:idx", cfg.CharacterHandler.UpdateVariant)
				characters.DELETE("/:charId/variants/:idx", cfg.CharacterHandler.DeleteVariant)
				characters.POST("/:charId/reference-images", cfg.CharacterHandler.AddReferenceImage)
				characters.DELETE("/:charId/reference-images/:idx", cfg.CharacterHandler.DeleteReferenceImage)
				characters.PATCH("/:charId/bio", cfg.CharacterHandler.UpdateBio)
				characters.POST("/:charId/regenerate-bio", cfg.CharacterHandler.RegenerateBio)
				characters.POST("/:charId/generate-candidates", cfg.CharacterHandler.GenerateCandidates)
				characters.GET("/:charId/candidates", cfg.CharacterHandler.GetCandidates)
				characters.POST("/:charId/candidates/select", cfg.CharacterHandler.SelectCandidate)
				characters.GET("/:charId/snapshots", cfg.CharacterHandler.ListByCharacter)
			}

			snapshots := protected.Group("/character-snapshots")
			{
				snapshots.POST("", cfg.CharacterHandler.CreateSnapshot)
				snapshots.GET("/:snapshotId", cfg.CharacterHandler.GetSnapshot)
				snapshots.PUT("/:snapshotId", cfg.CharacterHandler.UpdateSnapshot)
				snapshots.DELETE("/:snapshotId", cfg.CharacterHandler.DeleteSnapshot)
			}
		}
	}
}

// RouteConfig 路由依赖配置
type RouteConfig struct {
	AuthHandler        *auth.Handler
	ProjectHandler     *project.Handler
	EpisodeHandler     *episode.Handler
	SceneHandler       *scene.Handler
	ScriptHandler      *script.Handler
	CharacterHandler   *character.Handler
	LocationHandler    *location.Handler
	PropHandler        *prop.Handler
	StoryboardHandler  *storyboard.Handler
	ShotHandler        *shot.Handler
	ShotImageHandler   *shot_image.Handler
	WSHandler          *realtime.WSHandler
	CompositeHandler   *composite.Handler
	ReviewHandler      *review.Handler
	NotifHandler       *notification.Handler
	StyleHandler       *style.Handler
	TaskLockHandler    *tasklock.Handler
	ScheduleHandler    *schedule.Handler
	AsynqClient        *asynq.Client // 供 API 入队任务，Redis 不可用时为 nil
	JWTSecret          string
}
