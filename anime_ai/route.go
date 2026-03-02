package main

import (
	modauth "github.com/TeHeal/ai-anime/anime_ai/module/auth"
	"github.com/TeHeal/ai-anime/anime_ai/module/character"
	"github.com/TeHeal/ai-anime/anime_ai/module/composite"
	"github.com/TeHeal/ai-anime/anime_ai/module/download"
	"github.com/TeHeal/ai-anime/anime_ai/module/episode"
	"github.com/TeHeal/ai-anime/anime_ai/module/health"
	"github.com/TeHeal/ai-anime/anime_ai/module/location"
	"github.com/TeHeal/ai-anime/anime_ai/module/notification"
	"github.com/TeHeal/ai-anime/anime_ai/module/organization"
	"github.com/TeHeal/ai-anime/anime_ai/module/package_task"
	"github.com/TeHeal/ai-anime/anime_ai/module/project"
	"github.com/TeHeal/ai-anime/anime_ai/module/prop"
	"github.com/TeHeal/ai-anime/anime_ai/module/scene"
	"github.com/TeHeal/ai-anime/anime_ai/module/schedule"
	"github.com/TeHeal/ai-anime/anime_ai/module/script"
	"github.com/TeHeal/ai-anime/anime_ai/module/shot"
	"github.com/TeHeal/ai-anime/anime_ai/module/shot_image"
	"github.com/TeHeal/ai-anime/anime_ai/module/shot_video"
	"github.com/TeHeal/ai-anime/anime_ai/module/storyboard"
	"github.com/TeHeal/ai-anime/anime_ai/module/task"
	"github.com/TeHeal/ai-anime/anime_ai/module/usage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/metrics"
	"github.com/TeHeal/ai-anime/anime_ai/pub/middleware"
	"github.com/TeHeal/ai-anime/anime_ai/pub/realtime"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
)

func registerRoutes(r *gin.Engine, cfg *RouteConfig) {
	// Prometheus /metrics（README 8.2 可观测性，无鉴权供 Prometheus 抓取）
	r.GET("/metrics", gin.WrapH(metrics.Handler()))

	api := r.Group("/api/v1")
	{
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
		authGroup.POST("/register", cfg.AuthHandler.Register)
	}

	// 需 JWT 鉴权的接口
	protected := api.Group("")
	protected.Use(middleware.JWTAuth(cfg.JWTSecret))
	{
		protected.GET("/auth/me", cfg.AuthHandler.Me)
		protected.PUT("/auth/password", cfg.AuthHandler.ChangePassword)

		// 站内通知（README 2.6）
		if cfg.NotificationHandler != nil {
			protected.GET("/notifications", cfg.NotificationHandler.List)
			protected.GET("/notifications/unread-count", cfg.NotificationHandler.CountUnread)
			protected.PUT("/notifications/:id/read", cfg.NotificationHandler.MarkAsRead)
			protected.PUT("/notifications/read-all", cfg.NotificationHandler.MarkAllAsRead)
		}

		// 组织管理（README §2.5, §3 组织/团队 CRUD）
		if cfg.OrgHandler != nil {
			orgs := protected.Group("/orgs")
			{
				orgs.POST("", cfg.OrgHandler.Create)
				orgs.GET("", cfg.OrgHandler.List)
				orgs.GET("/:orgId", cfg.OrgHandler.Get)
				orgs.PUT("/:orgId", cfg.OrgHandler.Update)
				orgs.POST("/:orgId/members", cfg.OrgHandler.AddMember)
				orgs.GET("/:orgId/members", cfg.OrgHandler.ListMembers)
				orgs.DELETE("/:orgId/members/:userId", cfg.OrgHandler.RemoveMember)
			}
		}

		// 统一任务中心（README §2.1 任务编排，前端 /tasks）
		if cfg.TaskHandler != nil {
			protected.POST("/tasks", cfg.TaskHandler.Create)
			protected.GET("/tasks", cfg.TaskHandler.List)
			protected.POST("/tasks/batch", cfg.TaskHandler.Batch)
			protected.GET("/tasks/:taskId", cfg.TaskHandler.Get)
			protected.PUT("/tasks/:taskId/cancel", cfg.TaskHandler.Cancel)
		}

		// 项目管理
		if cfg.ProjectHandler != nil {
			projects := protected.Group("/projects")
			{
				projects.POST("", cfg.ProjectHandler.Create)
				projects.GET("", cfg.ProjectHandler.List)

				// 项目级路由：应用 ProjectContext 中间件解析项目权限
				projectScoped := projects.Group("/:id")
				if cfg.ProjectReader != nil {
					projectScoped.Use(middleware.ProjectContext(
						cfg.ProjectReader,
						cfg.ProjectMemberReader,
						cfg.TeamMemberReader,
					))
				}
				projectScoped.GET("", cfg.ProjectHandler.Get)
				projectScoped.PUT("", middleware.RequireAction(auth.ActionEdit), cfg.ProjectHandler.Update)
				projectScoped.DELETE("", middleware.RequireAction(auth.ActionProjectDelete), cfg.ProjectHandler.Delete)
				projectScoped.GET("/props", cfg.ProjectHandler.GetProps)
				projectScoped.PUT("/props", middleware.RequireAction(auth.ActionEdit), cfg.ProjectHandler.UpdateProps)
				// 审核配置（README §2.2 审核方式可配置）
				projectScoped.GET("/review-config", cfg.ProjectHandler.GetReviewConfig)
				projectScoped.PUT("/review-config", middleware.RequireAction(auth.ActionEdit), cfg.ProjectHandler.UpdateReviewConfig)
				// 项目成员
				projectScoped.GET("/members", cfg.ProjectHandler.ListMembers)
				projectScoped.POST("/members", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.AddMember)
				projectScoped.PUT("/members/:userId", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.UpdateMemberRole)
				projectScoped.PUT("/members/:userId/job-roles", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.UpdateMemberJobRoles)
				projectScoped.DELETE("/members/:userId", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.RemoveMember)

				// 集 CRUD
				if cfg.EpisodeHandler != nil {
					projectScoped.POST("/episodes", middleware.RequireAction(auth.ActionEdit), cfg.EpisodeHandler.Create)
					projectScoped.GET("/episodes", cfg.EpisodeHandler.List)
					projectScoped.GET("/episodes/:epId", cfg.EpisodeHandler.Get)
					projectScoped.PUT("/episodes/:epId", middleware.RequireAction(auth.ActionEdit), cfg.EpisodeHandler.Update)
					projectScoped.DELETE("/episodes/:epId", middleware.RequireAction(auth.ActionEdit), cfg.EpisodeHandler.Delete)
					projectScoped.PUT("/episodes/reorder", middleware.RequireAction(auth.ActionEdit), cfg.EpisodeHandler.Reorder)
					projectScoped.GET("/episodes/:epId/package-config", cfg.EpisodeHandler.GetPackageConfig)
					// 按集打包（README 2.7）
					if cfg.PackageHandler != nil {
						projectScoped.POST("/episodes/:epId/package", middleware.RequireAction(auth.ActionEdit), cfg.PackageHandler.RequestPackage)
						projectScoped.GET("/episodes/:epId/package", cfg.PackageHandler.ListByEpisode)
					} else {
						projectScoped.POST("/episodes/:epId/package", middleware.RequireAction(auth.ActionEdit), cfg.EpisodeHandler.RequestPackage)
					}
					// 成片导出
					if cfg.CompositeHandler != nil {
						projectScoped.POST("/episodes/:epId/export", middleware.RequireAction(auth.ActionCompositeExport), cfg.CompositeHandler.CreateExport)
						projectScoped.GET("/episodes/:epId/composite", cfg.CompositeHandler.ListByEpisode)
					}
				}
			// 成片任务（项目级）
			if cfg.CompositeHandler != nil {
				projectScoped.GET("/composite", cfg.CompositeHandler.ListByProject)
				projectScoped.GET("/composite/:taskId", cfg.CompositeHandler.Get)
			}
			// 时间轴（成片模块）
			if cfg.TimelineHandler != nil {
				projectScoped.GET("/timeline", cfg.TimelineHandler.GetTimeline)
				projectScoped.PUT("/timeline", middleware.RequireAction(auth.ActionCompositeEdit), cfg.TimelineHandler.SaveTimeline)
				projectScoped.POST("/timeline/auto", middleware.RequireAction(auth.ActionCompositeEdit), cfg.TimelineHandler.AutoGenerateTimeline)
			}
				// 单文件下载（README 2.7）
				if cfg.DownloadHandler != nil {
					projectScoped.GET("/download", cfg.DownloadHandler.Download)
				}
				// 打包任务状态（项目级）
				if cfg.PackageHandler != nil {
					projectScoped.GET("/package/:taskId", cfg.PackageHandler.Get)
				}
				// 用量查询（README 8.3 AI 成本控制）
				if cfg.UsageHandler != nil {
					projectScoped.GET("/usage", cfg.UsageHandler.List)
				}
				// 定时任务（README 2.1 任务编排与定时）
				if cfg.ScheduleHandler != nil {
					projectScoped.POST("/schedules", middleware.RequireAction(auth.ActionEdit), cfg.ScheduleHandler.Create)
					projectScoped.GET("/schedules", cfg.ScheduleHandler.List)
					projectScoped.GET("/schedules/:scheduleId", cfg.ScheduleHandler.Get)
					projectScoped.PUT("/schedules/:scheduleId", middleware.RequireAction(auth.ActionEdit), cfg.ScheduleHandler.Update)
					projectScoped.DELETE("/schedules/:scheduleId", middleware.RequireAction(auth.ActionEdit), cfg.ScheduleHandler.Delete)
				}

				// 场 CRUD（嵌套在集下）
				if cfg.SceneHandler != nil {
					projectScoped.POST("/episodes/:epId/scenes", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.Create)
					projectScoped.GET("/episodes/:epId/scenes", cfg.SceneHandler.List)
					projectScoped.GET("/episodes/:epId/scenes/:sceneId", cfg.SceneHandler.Get)
					projectScoped.PUT("/episodes/:epId/scenes/:sceneId", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.Update)
					projectScoped.DELETE("/episodes/:epId/scenes/:sceneId", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.Delete)
					projectScoped.PUT("/episodes/:epId/scenes/reorder", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.Reorder)
					projectScoped.PUT("/episodes/:epId/scenes/:sceneId/blocks", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.SaveBlocks)
				}

				// 块 CRUD（project-scoped sceneId）
				if cfg.SceneHandler != nil {
					projectScoped.POST("/scenes/:sceneId/blocks", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.CreateBlock)
					projectScoped.PUT("/scenes/:sceneId/blocks/:blockId", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.UpdateBlock)
					projectScoped.DELETE("/scenes/:sceneId/blocks/:blockId", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.DeleteBlock)
					projectScoped.PUT("/scenes/:sceneId/blocks/reorder", middleware.RequireAction(auth.ActionEdit), cfg.SceneHandler.ReorderBlocks)
				}

				// 角色（项目内）
				if cfg.CharacterHandler != nil {
					projectScoped.GET("/characters", cfg.CharacterHandler.ListByProject)
					projectScoped.POST("/characters/analyze-preview", middleware.RequireAction(auth.ActionGenerate), cfg.CharacterHandler.AnalyzePreview)
					projectScoped.POST("/characters/analyze", middleware.RequireAction(auth.ActionGenerate), cfg.CharacterHandler.AnalyzeConfirm)
					projectScoped.POST("/characters/:charId/extract-bio", middleware.RequireAction(auth.ActionGenerate), cfg.CharacterHandler.ExtractBio)
					projectScoped.GET("/character-snapshots", cfg.CharacterHandler.ListSnapshotsByProject)
				}

				// 场景资产（Location）
				if cfg.LocationHandler != nil {
					projectScoped.POST("/locations", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Create)
					projectScoped.GET("/locations", cfg.LocationHandler.List)
					projectScoped.GET("/locations/:locId", cfg.LocationHandler.Get)
					projectScoped.PUT("/locations/:locId", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Update)
					projectScoped.DELETE("/locations/:locId", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Delete)
					projectScoped.POST("/locations/:locId/confirm", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Confirm)
					projectScoped.POST("/locations/:locId/generate-image", middleware.RequireAction(auth.ActionGenerate), cfg.LocationHandler.GenerateImage)
				}

				// 道具资产（Prop，props-v2）
				if cfg.PropHandler != nil {
					projectScoped.POST("/props-v2", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Create)
					projectScoped.GET("/props-v2", cfg.PropHandler.List)
					projectScoped.GET("/props-v2/:propId", cfg.PropHandler.Get)
					projectScoped.PUT("/props-v2/:propId", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Update)
					projectScoped.DELETE("/props-v2/:propId", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Delete)
					projectScoped.POST("/props-v2/:propId/confirm", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Confirm)
				}

				// 分镜
				if cfg.StoryboardHandler != nil {
					projectScoped.GET("/storyboard", cfg.StoryboardHandler.List)
					projectScoped.POST("/storyboard/preview", middleware.RequireAction(auth.ActionGenerate), cfg.StoryboardHandler.Preview)
					projectScoped.POST("/storyboard/generate", middleware.RequireAction(auth.ActionGenerate), cfg.StoryboardHandler.Generate)
					projectScoped.POST("/storyboard/generate-sync", middleware.RequireAction(auth.ActionGenerate), cfg.StoryboardHandler.GenerateSync)
					projectScoped.POST("/storyboard/confirm", middleware.RequireAction(auth.ActionEdit), cfg.StoryboardHandler.Confirm)
				}

				// 脚本分段
				if cfg.ScriptHandler != nil {
					projectScoped.POST("/segments", middleware.RequireAction(auth.ActionScriptEdit), cfg.ScriptHandler.Create)
					projectScoped.PUT("/segments/bulk", middleware.RequireAction(auth.ActionScriptEdit), cfg.ScriptHandler.BulkCreate)
					projectScoped.GET("/segments", cfg.ScriptHandler.List)
					projectScoped.PUT("/segments/:segId", middleware.RequireAction(auth.ActionScriptEdit), cfg.ScriptHandler.Update)
					projectScoped.DELETE("/segments/:segId", middleware.RequireAction(auth.ActionScriptEdit), cfg.ScriptHandler.Delete)
					projectScoped.PUT("/segments/reorder", middleware.RequireAction(auth.ActionScriptEdit), cfg.ScriptHandler.Reorder)
					projectScoped.POST("/script/parse", middleware.RequireAction(auth.ActionGenerate), cfg.ScriptHandler.Parse)
					projectScoped.POST("/script/parse-sync", middleware.RequireAction(auth.ActionGenerate), cfg.ScriptHandler.ParseSync)
					projectScoped.GET("/script/preview", cfg.ScriptHandler.Preview)
					projectScoped.POST("/script/confirm", middleware.RequireAction(auth.ActionScriptEdit), cfg.ScriptHandler.Confirm)
					projectScoped.POST("/script/ai-assist", middleware.RequireAction(auth.ActionGenerate), cfg.ScriptHandler.Assist)
				}

				// 镜头 CRUD、生成、合成
				if cfg.ShotHandler != nil {
					projectScoped.POST("/shots", middleware.RequireAction(auth.ActionEdit), cfg.ShotHandler.Create)
					projectScoped.POST("/shots/bulk", middleware.RequireAction(auth.ActionEdit), cfg.ShotHandler.BulkCreate)
					projectScoped.GET("/shots", cfg.ShotHandler.List)
					projectScoped.GET("/shots/:shotId", cfg.ShotHandler.Get)
					projectScoped.PUT("/shots/:shotId", middleware.RequireAction(auth.ActionEdit), cfg.ShotHandler.Update)
					projectScoped.DELETE("/shots/:shotId", middleware.RequireAction(auth.ActionEdit), cfg.ShotHandler.Delete)
					projectScoped.PUT("/shots/reorder", middleware.RequireAction(auth.ActionEdit), cfg.ShotHandler.Reorder)
					projectScoped.POST("/shots/generate", middleware.RequireAction(auth.ActionGenerate), cfg.ShotHandler.BatchGenerate)
					projectScoped.POST("/shots/composite", middleware.RequireAction(auth.ActionGenerate), cfg.ShotHandler.BatchComposite)
				}

				// 镜图生成、审核
				if cfg.ShotImageHandler != nil {
					projectScoped.POST("/shot-images/generate", middleware.RequireAction(auth.ActionShotImageGen), cfg.ShotImageHandler.BatchGenerate)
					projectScoped.GET("/shot-images/status", cfg.ShotImageHandler.GetStatus)
					projectScoped.POST("/shot-images/select-candidate", middleware.RequireAction(auth.ActionShotImageEdit), cfg.ShotImageHandler.SelectCandidate)
					projectScoped.POST("/shot-images/batch-review", middleware.RequireAction(auth.ActionShotImageReview), cfg.ShotImageHandler.BatchReview)
					projectScoped.GET("/shots/:shotId/candidates", cfg.ShotImageHandler.GetCandidates)
					projectScoped.GET("/shots/:shotId/allowed-actions", cfg.ShotImageHandler.GetAllowedActions)
					projectScoped.POST("/shots/:shotId/images", middleware.RequireAction(auth.ActionShotImageEdit), cfg.ShotImageHandler.Create)
					projectScoped.GET("/shots/:shotId/images", cfg.ShotImageHandler.List)
					projectScoped.GET("/shots/:shotId/images/:imageId", cfg.ShotImageHandler.Get)
					projectScoped.DELETE("/shots/:shotId/images/:imageId", middleware.RequireAction(auth.ActionShotImageEdit), cfg.ShotImageHandler.Delete)
					projectScoped.PUT("/shots/:shotId/image-review", middleware.RequireAction(auth.ActionShotImageReview), cfg.ShotImageHandler.UpdateImageReview)
				projectScoped.POST("/shots/:shotId/image-review/submit", middleware.RequireAction(auth.ActionShotImageReview), cfg.ShotImageHandler.SubmitForReview)
				}
				// 镜头视频（README 镜头阶段）
				if cfg.ShotVideoHandler != nil {
					projectScoped.GET("/shots/:shotId/videos", cfg.ShotVideoHandler.List)
					projectScoped.POST("/shots/:shotId/videos", middleware.RequireAction(auth.ActionShotVideoGen), cfg.ShotVideoHandler.Create)
					projectScoped.PUT("/shots/:shotId/videos/:videoId/review", middleware.RequireAction(auth.ActionShotVideoReview), cfg.ShotVideoHandler.UpdateReview)
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
	AuthHandler         *modauth.Handler
	NotificationHandler *notification.Handler
	OrgHandler          *organization.Handler
	TaskHandler         *task.Handler
	ProjectHandler      *project.Handler
	EpisodeHandler      *episode.Handler
	SceneHandler        *scene.Handler
	ScriptHandler       *script.Handler
	CharacterHandler    *character.Handler
	LocationHandler     *location.Handler
	PropHandler         *prop.Handler
	StoryboardHandler   *storyboard.Handler
	ShotHandler         *shot.Handler
	ShotImageHandler    *shot_image.Handler
	ShotVideoHandler    *shot_video.Handler
	CompositeHandler    *composite.Handler
	TimelineHandler     *composite.TimelineHandler
	DownloadHandler     *download.Handler
	PackageHandler      *package_task.Handler
	UsageHandler        *usage.Handler
	ScheduleHandler     *schedule.Handler
	WSHandler           *realtime.WSHandler
	AsynqClient         *asynq.Client // 供 API 入队任务，Redis 不可用时为 nil
	JWTSecret           string

	// RBAC 中间件依赖（ProjectContext 所需的读取接口）
	ProjectReader       middleware.ProjectReader
	ProjectMemberReader middleware.ProjectMemberReader
	TeamMemberReader    middleware.TeamMemberReader
}
