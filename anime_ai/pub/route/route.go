package route

import (
	"anime_ai/module/ai"
	modauth "anime_ai/module/auth"
	"anime_ai/module/assets/asset_version"
	"anime_ai/module/assets/character"
	"anime_ai/module/composite"
	"anime_ai/module/download"
	"anime_ai/module/episode"
	"anime_ai/module/file"
	"anime_ai/module/health"
	"anime_ai/module/assets/location"
	"anime_ai/module/notification"
	"anime_ai/module/organization"
	"anime_ai/module/package_task"
	"anime_ai/module/project"
	"anime_ai/module/assets/prop"
	"anime_ai/module/assets/resource"
	"anime_ai/module/scene"
	"anime_ai/module/schedule"
	"anime_ai/module/script"
	"anime_ai/module/assets/style"
	"anime_ai/module/shot"
	"anime_ai/module/shot_image"
	"anime_ai/module/shot_video"
	"anime_ai/module/storyboard"
	"anime_ai/module/task"
	"anime_ai/module/usage"
	"anime_ai/pub/auth"
	"anime_ai/pub/metrics"
	"anime_ai/pub/middleware"
	"anime_ai/pub/realtime"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
)

// Config 路由依赖配置
type Config struct {
	AIHandler            *ai.Handler
	AuthHandler          *modauth.Handler
	NotificationHandler  *notification.Handler
	OrgHandler           *organization.Handler
	TaskHandler          *task.Handler
	ProjectHandler       *project.Handler
	AssetVersionHandler  *asset_version.Handler
	EpisodeHandler       *episode.Handler
	SceneHandler         *scene.Handler
	ScriptHandler        *script.Handler
	CharacterHandler     *character.Handler
	LocationHandler      *location.Handler
	PropHandler          *prop.Handler
	ResourceHandler      *resource.Handler
	StyleHandler         *style.Handler
	StoryboardHandler    *storyboard.Handler
	ShotHandler          *shot.Handler
	ShotImageHandler     *shot_image.Handler
	ShotVideoHandler     *shot_video.Handler
	CompositeHandler     *composite.Handler
	TimelineHandler      *composite.TimelineHandler
	DownloadHandler      *download.Handler
	FileHandler          *file.Handler
	PackageHandler       *package_task.Handler
	UsageHandler         *usage.Handler
	ScheduleHandler      *schedule.Handler
	WSHandler            *realtime.WSHandler
	AsynqClient          *asynq.Client
	JWTSecret            string
	ProjectReader        middleware.ProjectReader
	ProjectMemberReader  middleware.ProjectMemberReader
	TeamMemberReader     middleware.TeamMemberReader
	LockChecker          middleware.LockChecker
}

// Register 注册 HTTP 路由
func Register(r *gin.Engine, cfg *Config) {
	r.GET("/metrics", gin.WrapH(metrics.Handler()))
	api := r.Group("/api/v1")
	{
		api.GET("/health", health.Handler)
	}
	if cfg.WSHandler != nil {
		api.GET("/ws", cfg.WSHandler.Connect)
	}
	authGroup := api.Group("/auth")
	{
		authGroup.POST("/login", cfg.AuthHandler.Login)
		authGroup.POST("/register", cfg.AuthHandler.Register)
	}
	protected := api.Group("")
	protected.Use(middleware.JWTAuth(cfg.JWTSecret))
	{
		protected.GET("/auth/me", cfg.AuthHandler.Me)
		protected.PUT("/auth/password", cfg.AuthHandler.ChangePassword)
		if cfg.FileHandler != nil {
			protected.POST("/files/upload", cfg.FileHandler.Upload)
		}
		if cfg.AIHandler != nil {
			aiGroup := protected.Group("/ai")
			{
				aiGroup.POST("/generate/image", cfg.AIHandler.GenerateImage)
				aiGroup.POST("/generate/text", cfg.AIHandler.GenerateText)
				aiGroup.POST("/generate/voice", cfg.AIHandler.GenerateVoice)
			}
		}
		if cfg.NotificationHandler != nil {
			protected.GET("/notifications", cfg.NotificationHandler.List)
			protected.GET("/notifications/unread-count", cfg.NotificationHandler.CountUnread)
			protected.PUT("/notifications/:id/read", cfg.NotificationHandler.MarkAsRead)
			protected.PUT("/notifications/read-all", cfg.NotificationHandler.MarkAllAsRead)
		}
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
		if cfg.TaskHandler != nil {
			protected.POST("/tasks", cfg.TaskHandler.Create)
			protected.GET("/tasks", cfg.TaskHandler.List)
			protected.POST("/tasks/batch", cfg.TaskHandler.Batch)
			protected.GET("/tasks/:taskId", cfg.TaskHandler.Get)
			protected.PUT("/tasks/:taskId/cancel", cfg.TaskHandler.Cancel)
		}
		if cfg.ProjectHandler != nil {
			projects := protected.Group("/projects")
			{
				projects.POST("", cfg.ProjectHandler.Create)
				projects.GET("", cfg.ProjectHandler.List)
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
				projectScoped.GET("/review-config", cfg.ProjectHandler.GetReviewConfig)
				projectScoped.PUT("/review-config", middleware.RequireAction(auth.ActionEdit), cfg.ProjectHandler.UpdateReviewConfig)
				projectScoped.GET("/members", cfg.ProjectHandler.ListMembers)
				projectScoped.POST("/members", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.AddMember)
				projectScoped.PUT("/members/:userId", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.UpdateMemberRole)
				projectScoped.PUT("/members/:userId/job-roles", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.UpdateMemberJobRoles)
				projectScoped.DELETE("/members/:userId", middleware.RequireAction(auth.ActionManageMembers), cfg.ProjectHandler.RemoveMember)
				projectScoped.GET("/lock", cfg.ProjectHandler.GetLockStatus)
				projectScoped.POST("/lock/:phase", middleware.RequireAction(auth.ActionEdit), cfg.ProjectHandler.LockPhase)
				projectScoped.DELETE("/lock/:phase", middleware.RequireAction(auth.ActionEdit), cfg.ProjectHandler.UnlockPhase)
				if cfg.AssetVersionHandler != nil {
					projectScoped.GET("/asset-versions", cfg.AssetVersionHandler.List)
					projectScoped.GET("/asset-versions/impact", cfg.AssetVersionHandler.Impact)
					projectScoped.POST("/asset-versions/freeze", middleware.RequireAction(auth.ActionEdit), cfg.AssetVersionHandler.Freeze)
					projectScoped.POST("/asset-versions/unfreeze", middleware.RequireAction(auth.ActionEdit), cfg.AssetVersionHandler.Unfreeze)
				}
				var storyGuard gin.HandlerFunc
				if cfg.LockChecker != nil {
					storyGuard = middleware.LockGuard(cfg.LockChecker, "story")
				} else {
					storyGuard = func(c *gin.Context) { c.Next() }
				}
				if cfg.EpisodeHandler != nil {
					projectScoped.POST("/episodes", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.EpisodeHandler.Create)
					projectScoped.GET("/episodes", cfg.EpisodeHandler.List)
					projectScoped.GET("/episodes/:epId", cfg.EpisodeHandler.Get)
					projectScoped.PUT("/episodes/:epId", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.EpisodeHandler.Update)
					projectScoped.DELETE("/episodes/:epId", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.EpisodeHandler.Delete)
					projectScoped.PUT("/episodes/reorder", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.EpisodeHandler.Reorder)
					projectScoped.GET("/episodes/:epId/package-config", cfg.EpisodeHandler.GetPackageConfig)
					if cfg.PackageHandler != nil {
						projectScoped.POST("/episodes/:epId/package", middleware.RequireAction(auth.ActionEdit), cfg.PackageHandler.RequestPackage)
						projectScoped.GET("/episodes/:epId/package", cfg.PackageHandler.ListByEpisode)
					} else {
						projectScoped.POST("/episodes/:epId/package", middleware.RequireAction(auth.ActionEdit), cfg.EpisodeHandler.RequestPackage)
					}
					if cfg.CompositeHandler != nil {
						projectScoped.POST("/episodes/:epId/export", middleware.RequireAction(auth.ActionCompositeExport), cfg.CompositeHandler.CreateExport)
						projectScoped.GET("/episodes/:epId/composite", cfg.CompositeHandler.ListByEpisode)
					}
				}
				if cfg.CompositeHandler != nil {
					projectScoped.GET("/composite", cfg.CompositeHandler.ListByProject)
					projectScoped.GET("/composite/:taskId", cfg.CompositeHandler.Get)
				}
				if cfg.TimelineHandler != nil {
					projectScoped.GET("/timeline", cfg.TimelineHandler.GetTimeline)
					projectScoped.PUT("/timeline", middleware.RequireAction(auth.ActionCompositeEdit), cfg.TimelineHandler.SaveTimeline)
					projectScoped.POST("/timeline/auto", middleware.RequireAction(auth.ActionCompositeEdit), cfg.TimelineHandler.AutoGenerateTimeline)
				}
				if cfg.DownloadHandler != nil {
					projectScoped.GET("/download", cfg.DownloadHandler.Download)
				}
				if cfg.PackageHandler != nil {
					projectScoped.GET("/package/:taskId", cfg.PackageHandler.Get)
				}
				if cfg.UsageHandler != nil {
					projectScoped.GET("/usage", cfg.UsageHandler.List)
				}
				if cfg.ScheduleHandler != nil {
					projectScoped.POST("/schedules", middleware.RequireAction(auth.ActionEdit), cfg.ScheduleHandler.Create)
					projectScoped.GET("/schedules", cfg.ScheduleHandler.List)
					projectScoped.GET("/schedules/:scheduleId", cfg.ScheduleHandler.Get)
					projectScoped.PUT("/schedules/:scheduleId", middleware.RequireAction(auth.ActionEdit), cfg.ScheduleHandler.Update)
					projectScoped.DELETE("/schedules/:scheduleId", middleware.RequireAction(auth.ActionEdit), cfg.ScheduleHandler.Delete)
				}
				if cfg.SceneHandler != nil {
					projectScoped.POST("/episodes/:epId/scenes", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.Create)
					projectScoped.GET("/episodes/:epId/scenes", cfg.SceneHandler.List)
					projectScoped.GET("/episodes/:epId/scenes/:sceneId", cfg.SceneHandler.Get)
					projectScoped.PUT("/episodes/:epId/scenes/:sceneId", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.Update)
					projectScoped.DELETE("/episodes/:epId/scenes/:sceneId", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.Delete)
					projectScoped.PUT("/episodes/:epId/scenes/reorder", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.Reorder)
					projectScoped.PUT("/episodes/:epId/scenes/:sceneId/blocks", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.SaveBlocks)
					projectScoped.POST("/scenes/:sceneId/blocks", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.CreateBlock)
					projectScoped.PUT("/scenes/:sceneId/blocks/:blockId", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.UpdateBlock)
					projectScoped.DELETE("/scenes/:sceneId/blocks/:blockId", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.DeleteBlock)
					projectScoped.PUT("/scenes/:sceneId/blocks/reorder", middleware.RequireAction(auth.ActionEdit), storyGuard, cfg.SceneHandler.ReorderBlocks)
				}
				if cfg.CharacterHandler != nil {
					projectScoped.GET("/characters", cfg.CharacterHandler.ListByProject)
					projectScoped.POST("/characters/analyze-preview", middleware.RequireAction(auth.ActionGenerate), cfg.CharacterHandler.AnalyzePreview)
					projectScoped.POST("/characters/analyze", middleware.RequireAction(auth.ActionGenerate), cfg.CharacterHandler.AnalyzeConfirm)
					projectScoped.POST("/characters/:charId/extract-bio", middleware.RequireAction(auth.ActionGenerate), cfg.CharacterHandler.ExtractBio)
					projectScoped.GET("/character-snapshots", cfg.CharacterHandler.ListSnapshotsByProject)
				}
				if cfg.LocationHandler != nil {
					projectScoped.POST("/locations", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Create)
					projectScoped.GET("/locations", cfg.LocationHandler.List)
					projectScoped.GET("/locations/:locId", cfg.LocationHandler.Get)
					projectScoped.PUT("/locations/:locId", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Update)
					projectScoped.DELETE("/locations/:locId", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Delete)
					projectScoped.POST("/locations/:locId/confirm", middleware.RequireAction(auth.ActionAssetEdit), cfg.LocationHandler.Confirm)
					projectScoped.POST("/locations/:locId/generate-image", middleware.RequireAction(auth.ActionGenerate), cfg.LocationHandler.GenerateImage)
				}
				if cfg.PropHandler != nil {
					projectScoped.POST("/asset-props", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Create)
					projectScoped.GET("/asset-props", cfg.PropHandler.List)
					projectScoped.GET("/asset-props/:propId", cfg.PropHandler.Get)
					projectScoped.PUT("/asset-props/:propId", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Update)
					projectScoped.DELETE("/asset-props/:propId", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Delete)
					projectScoped.POST("/asset-props/:propId/confirm", middleware.RequireAction(auth.ActionAssetEdit), cfg.PropHandler.Confirm)
				}
				if cfg.StyleHandler != nil {
					projectScoped.GET("/styles", cfg.StyleHandler.List)
					projectScoped.POST("/styles", middleware.RequireAction(auth.ActionAssetEdit), cfg.StyleHandler.Create)
					projectScoped.GET("/styles/:styleId", cfg.StyleHandler.Get)
					projectScoped.PUT("/styles/:styleId", middleware.RequireAction(auth.ActionAssetEdit), cfg.StyleHandler.Update)
					projectScoped.DELETE("/styles/:styleId", middleware.RequireAction(auth.ActionAssetEdit), cfg.StyleHandler.Delete)
					projectScoped.POST("/styles/:styleId/apply-all", middleware.RequireAction(auth.ActionAssetEdit), cfg.StyleHandler.ApplyAll)
				}
				if cfg.StoryboardHandler != nil {
					projectScoped.GET("/storyboard", cfg.StoryboardHandler.List)
					projectScoped.POST("/storyboard/preview", middleware.RequireAction(auth.ActionGenerate), cfg.StoryboardHandler.Preview)
					projectScoped.POST("/storyboard/generate", middleware.RequireAction(auth.ActionGenerate), cfg.StoryboardHandler.Generate)
					projectScoped.POST("/storyboard/generate-sync", middleware.RequireAction(auth.ActionGenerate), cfg.StoryboardHandler.GenerateSync)
					projectScoped.POST("/storyboard/confirm", middleware.RequireAction(auth.ActionEdit), cfg.StoryboardHandler.Confirm)
				}
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
					projectScoped.POST("/script/confirm", middleware.RequireAction(auth.ActionScriptEdit), storyGuard, cfg.ScriptHandler.Confirm)
					projectScoped.POST("/script/ai-assist", middleware.RequireAction(auth.ActionGenerate), cfg.ScriptHandler.Assist)
				}
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
				if cfg.ShotVideoHandler != nil {
					projectScoped.GET("/shots/:shotId/videos", cfg.ShotVideoHandler.List)
					projectScoped.POST("/shots/:shotId/videos", middleware.RequireAction(auth.ActionShotVideoGen), cfg.ShotVideoHandler.Create)
					projectScoped.PUT("/shots/:shotId/videos/:videoId/review", middleware.RequireAction(auth.ActionShotVideoReview), cfg.ShotVideoHandler.UpdateReview)
				}
			}
		}
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
		if cfg.ResourceHandler != nil {
			resources := protected.Group("/resources")
			{
				resources.POST("", cfg.ResourceHandler.Create)
				resources.GET("", cfg.ResourceHandler.List)
				resources.GET("/counts", cfg.ResourceHandler.Counts)
				resources.POST("/generate-image", cfg.ResourceHandler.GenerateImage)
				resources.POST("/generate-prompt", cfg.ResourceHandler.GeneratePrompt)
				resources.POST("/generate-voice", cfg.ResourceHandler.GenerateVoice)
				resources.POST("/generate-voice-design", cfg.ResourceHandler.GenerateVoiceDesign)
				resources.POST("/generate-preview-text", cfg.ResourceHandler.GeneratePreviewText)
				resources.GET("/:resourceId", cfg.ResourceHandler.Get)
				resources.PUT("/:resourceId", cfg.ResourceHandler.Update)
				resources.DELETE("/:resourceId", cfg.ResourceHandler.Delete)
			}
		}
	}
}
