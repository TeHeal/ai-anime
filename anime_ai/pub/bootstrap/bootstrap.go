package bootstrap

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"anime_ai/module/ai"
	"anime_ai/module/assets/asset_version"
	"anime_ai/module/auth"
	"anime_ai/module/assets/character"
	"anime_ai/module/composite"
	"anime_ai/module/dashboard"
	"anime_ai/module/download"
	"anime_ai/module/episode"
	"anime_ai/module/file"
	"anime_ai/module/assets/location"
	"anime_ai/module/model_catalog"
	"anime_ai/module/notification"
	"anime_ai/module/organization"
	"anime_ai/module/package_task"
	"anime_ai/module/project"
	"anime_ai/module/assets/prop"
	"anime_ai/module/assets/resource"
	"anime_ai/module/schedule"
	"anime_ai/module/scene"
	"anime_ai/module/script"
	"anime_ai/module/shot"
	"anime_ai/module/shot_image"
	"anime_ai/module/shot_video"
	"anime_ai/module/storyboard"
	"anime_ai/module/assets/style"
	"anime_ai/module/task"
	"anime_ai/module/team"
	"anime_ai/module/usage"
	"anime_ai/pub/config"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/mesh"
	"anime_ai/pub/provider/audio"
	"anime_ai/pub/metrics"
	"anime_ai/pub/middleware"
	"anime_ai/pub/provider_usage"
	"anime_ai/pub/realtime"
	"anime_ai/pub/review_ai"
	"anime_ai/pub/review_record"
	"anime_ai/route"
	"anime_ai/pub/scheduler"
	"anime_ai/pub/skeleton"
	"anime_ai/pub/storage"
	"anime_ai/pub/worker"
	"anime_ai/sch/db"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// App 应用实例，持有启动与关闭所需的全部依赖
type App struct {
	deps        *deps
	routeCfg    *route.Config
	srv         *http.Server
	asynqServer *asynq.Server
	asynqClient *asynq.Client
}

// New 创建应用实例，完成依赖注入与模块组装
func New(cfg *config.Config) (*App, error) {
	dsn := cfg.DB.GetDSN()
	if dsn == "" {
		return nil, fmt.Errorf("PostgreSQL 未配置：请在 config.yaml 或环境变量中设置 DB 连接信息（APP_DB_*）")
	}
	pool, err := initPGXPool(dsn)
	if err != nil {
		return nil, fmt.Errorf("PostgreSQL 连接失败: %w\n请确保数据库已启动且连接信息正确", err)
	}
	runMigrations(dsn, "./migrations")

	queries := db.New(pool)
	d := &deps{
		cfg:     cfg,
		pool:    pool,
		queries: queries,
	}

	// Logger
	var loggerErr error
	if cfg.App.Mode == "debug" {
		d.logger, loggerErr = zap.NewDevelopment()
	} else {
		d.logger, loggerErr = zap.NewProduction()
	}
	if loggerErr != nil {
		return nil, fmt.Errorf("初始化 logger 失败: %w", loggerErr)
	}

	// 存储
	if s, err := storage.NewFromConfig(&cfg.Storage); err != nil {
		log.Printf("Storage 初始化失败，使用 nil: %v", err)
		d.store = nil
	} else {
		d.store = s
	}

	// 认证
	userStore := auth.NewDBUserStore(queries)
	log.Println("使用 PostgreSQL 用户存储")
	authSvc := auth.NewAuthService(userStore, cfg.App.Secret)
	d.authHandler = auth.NewHandler(authSvc)

	// 项目管理
	d.projectData = project.NewDBData(db.New(pool))
	log.Println("使用 PostgreSQL 项目存储")
	projectSvc := project.NewService(d.projectData)
	d.projectHandler = project.NewHandler(projectSvc)
	d.projectVerifier = project.NewProjectVerifier(d.projectData)
	d.scriptLockCheck = project.NewScriptLockChecker(d.projectData)
	d.lockChecker = project.NewLockCheckerAdapter(projectSvc)
	d.projectReader = project.ProjectReaderAdapter(d.projectData)
	d.projectMemberReader = project.ProjectMemberReaderAdapter(d.projectData)
	d.teamMemberReader = &project.NoopTeamMemberReader{}

	// 集、场
	episodeStore := episode.NewDBEpisodeStore(db.New(pool))
	log.Println("使用 PostgreSQL 集存储")
	episodeSvc := episode.NewService(episodeStore, d.projectVerifier)
	d.episodeHandler = episode.NewHandler(episodeSvc)

	sceneQueries := db.New(pool)
	sceneStore := scene.NewDBSceneStore(sceneQueries)
	sceneBlockStore := scene.NewDBSceneBlockStore(sceneQueries)
	log.Println("使用 PostgreSQL 场/块存储")
	episodeReader := episode.EpisodeReaderAdapter(episodeStore)
	sceneSvc := scene.NewService(sceneStore, sceneBlockStore, episodeReader, d.projectVerifier)
	d.sceneHandler = scene.NewHandler(sceneSvc)
	d.episodeHandler.SetSceneService(sceneSvc)

	// LLM
	d.llmSvc = initLLM(cfg)

	// 分镜
	sceneBlockReader := scene.NewSceneBlockReaderAdapter(sceneStore, sceneBlockStore)
	storyboardAccess := project.NewStoryboardAccess(d.projectData)
	storyboardData := storyboard.NewMemData(storyboardAccess)
	var storyboardSvc *storyboard.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		storyboardSvc = storyboard.NewServiceWithResolver(storyboardData, d.projectVerifier, resolver)
	} else {
		storyboardSvc = storyboard.NewService(storyboardData, d.projectVerifier)
	}
	storyboardSvc.SetLLMService(d.llmSvc)
	storyboardSvc.SetSceneBlockReader(sceneBlockReader)
	storyboardSvc.SetEpisodeReader(episode.NewStoryboardEpisodeReaderAdapter(episodeStore))
	d.storyboardHandler = storyboard.NewHandler(storyboardSvc)

	// 脚本
	segmentStore := script.NewDBSegmentStore(db.New(pool))
	log.Println("使用 PostgreSQL 脚本分段存储")
	var scriptSvc *script.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		scriptSvc = script.NewServiceWithResolver(segmentStore, d.projectVerifier, resolver)
	} else {
		scriptSvc = script.NewService(segmentStore, d.projectVerifier)
	}
	scriptSvc.SetLLMService(d.llmSvc)
	scriptSvc.SetEpisodeSceneServices(episodeSvc, sceneSvc)
	d.scriptHandler = script.NewHandler(scriptSvc)

	// 角色
	characterData := character.NewDBData(db.New(pool))
	log.Println("使用 PostgreSQL 角色存储")
	var characterSvc *character.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		characterSvc = character.NewServiceWithResolver(characterData, d.projectVerifier, resolver)
	} else {
		characterSvc = character.NewService(characterData, d.projectVerifier)
	}
	d.characterHandler = character.NewHandler(characterSvc)

	// 场景资产
	locationStore := location.NewDBLocationStore(db.New(pool))
	log.Println("使用 PostgreSQL 场景存储")
	var locationSvc *location.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		locationSvc = location.NewServiceWithResolver(locationStore, d.projectVerifier, resolver)
	} else {
		locationSvc = location.NewService(locationStore, d.projectVerifier)
	}
	d.locationHandler = location.NewHandler(locationSvc)

	// 骨架
	skeletonSvc := skeleton.NewService(episodeSvc, sceneSvc, characterSvc, locationSvc)
	scriptSvc.SetSkeletonService(skeletonSvc)

	// 道具
	propStore := prop.NewDBPropStore(db.New(pool))
	log.Println("使用 PostgreSQL 道具存储")
	var propSvc *prop.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		propSvc = prop.NewServiceWithResolver(propStore, d.projectVerifier, resolver)
	} else {
		propSvc = prop.NewService(propStore, d.projectVerifier)
	}
	d.propHandler = prop.NewHandler(propSvc)

	// 风格
	styleData := style.NewDBData(db.New(pool))
	log.Println("使用 PostgreSQL 风格存储")
	var styleSvc *style.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		styleSvc = style.NewServiceWithResolver(styleData, d.projectVerifier, resolver)
	} else {
		styleSvc = style.NewService(styleData, d.projectVerifier)
	}
	d.styleHandler = style.NewHandler(styleSvc)

	// 资产版本（collector 依赖 character/location/prop Service，projectLock 依赖 project.Service）
	assetVersionData := asset_version.NewDBData(db.New(pool))
	projectLockReader := project.ProjectLockReaderAdapter(projectSvc)
	collector := asset_version.NewConfirmedAssetCollector(characterSvc, locationSvc, propSvc, d.logger)
	assetVersionSvc := asset_version.NewService(assetVersionData, projectLockReader, collector)
	frozenAssetChecker := asset_version.NewFrozenCheckerAdapter(assetVersionSvc)
	d.assetVersionHandler = asset_version.NewHandler(assetVersionSvc)
	characterSvc.SetFrozenAssetChecker(frozenAssetChecker)
	locationSvc.SetFrozenAssetChecker(frozenAssetChecker)
	propSvc.SetFrozenAssetChecker(frozenAssetChecker)
	log.Println("资产版本模块已启用（Freeze/Unfreeze、FrozenAssetChecker）")

	// 镜头
	shotStore := shot.NewDBShotStore(db.New(pool))
	log.Println("使用 PostgreSQL 镜头存储")
	shotReader := shot.ShotReaderAdapter(shotStore)
	shotLocker := shot.ShotLockerAdapter(shotStore)
	shotSvc := shot.NewService(shotStore, d.projectVerifier)
	d.shotHandler = shot.NewHandler(shotSvc)

	// 镜图
	shotImageStore := shot_image.NewDBShotImageStore(db.New(pool))
	log.Println("使用 PostgreSQL 镜图存储")
	reviewRecorder := review_record.NewDBRecorderWithLogger(db.New(pool), d.logger)
	var shotImageSvc *shot_image.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		shotImageSvc = shot_image.NewServiceWithResolver(shotImageStore, shotReader, shotLocker, d.projectVerifier, resolver, reviewRecorder)
	} else {
		shotImageSvc = shot_image.NewService(shotImageStore, shotReader, shotLocker, d.projectVerifier, reviewRecorder)
	}
	reviewConfigReader := project.NewReviewConfigReader(d.projectData)
	var aiReviewer shot_image.AIReviewer
	if d.llmSvc.Available() {
		aiReviewer = review_ai.NewLLMReviewer(d.llmSvc)
		log.Println("AI 审核器已启用（基于 LLM）")
	}
	shotImageSvc.SetReviewFlowConfig(&shot_image.ReviewFlowConfig{
		ReviewConfigReader: reviewConfigReader,
		AIReviewer:         aiReviewer,
	})
	shotImageSvc.SetScriptLockChecker(d.scriptLockCheck)
	shotImageSvc.SetLogger(d.logger)
	d.shotImageHandler = shot_image.NewHandler(shotImageSvc)

	// 镜头视频
	shotVideoStore := shot_video.NewDBShotVideoStore(db.New(pool))
	var shotVideoSvc *shot_video.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		shotVideoSvc = shot_video.NewServiceWithResolver(shotVideoStore, d.projectVerifier, resolver)
	} else {
		shotVideoSvc = shot_video.NewService(shotVideoStore, d.projectVerifier)
	}
	shotVideoSvc.SetScriptLockChecker(d.scriptLockCheck)
	d.shotVideoHandler = shot_video.NewHandler(shotVideoSvc)
	log.Println("镜头视频模块已启用")

	// 通知
	notificationData := notification.NewDBData(db.New(pool))
	notificationSvc := notification.NewService(notificationData)
	_ = notification.NewTaskNotifierAdapter(notificationSvc)
	d.notificationHandler = notification.NewHandler(notificationSvc)
	log.Println("通知模块已启用")

	d.modelCatalogHandler = model_catalog.NewHandler()
	log.Println("模型目录 API 已启用")

	// 组织
	orgData := organization.NewDBData(db.New(pool))
	orgSvc := organization.NewService(orgData)
	d.orgHandler = organization.NewHandler(orgSvc)
	log.Println("组织模块已启用")

	// 团队
	teamData := team.NewDBData(db.New(pool))
	orgChecker := team.NewOrgCheckerAdapter(orgSvc)
	teamSvc := team.NewService(teamData, orgChecker)
	d.teamHandler = team.NewHandler(teamSvc)
	log.Println("团队模块已启用")

	// 任务
	taskData := task.NewDBData(db.New(pool))
	taskSvc := task.NewService(taskData, d.projectVerifier)
	d.taskHandler = task.NewHandler(taskSvc)
	log.Println("统一任务模块已启用")

	// 成片
	compositeStore := composite.NewDBStore(db.New(pool))
	var compositeSvc *composite.Service
	if resolver, ok := d.projectVerifier.(crossmodule.ProjectMemberResolver); ok {
		compositeSvc = composite.NewServiceWithResolver(compositeStore, d.projectVerifier, resolver)
	} else {
		compositeSvc = composite.NewService(compositeStore, d.projectVerifier)
	}
	log.Println("成片模块已启用")

	// WebSocket
	realtimeHub := realtime.NewHub(d.logger)
	d.wsHandler = realtime.NewWSHandler(realtimeHub, cfg.App.Secret)

	// AI 路由
	d.imageRouter = initImageRouter(cfg)
	imageRouter := d.imageRouter
	_ = initMusicRouter(cfg) // 供 Worker 使用，当前未注入
	videoRouter := initVideoRouter(cfg)
	ttsRouter := initTTSRouter(cfg)

	// 下载与文件上传
	if d.store != nil {
		d.downloadHandler = download.NewHandler(d.store, d.projectVerifier)
		d.fileHandler = file.NewHandler(d.store)
	}

	// Worker 依赖
	taskNotifier := notification.NewTaskNotifierAdapter(notificationSvc)
	imageTaskDeps := worker.ImageTaskDeps{
		ImageRouter:    imageRouter,
		Storage:        d.store,
		ShotImageStore: shotImageStore,
		ShotLocker:     shotLocker,
		RealtimeHub:    realtimeHub,
		TaskNotifier:   taskNotifier,
		UsageRecorder:  provider_usage.NewDBRecorderWithLogger(db.New(pool), d.logger),
	}
	imageHandler := worker.NewImageTaskHandler(d.logger, imageTaskDeps)

	videoTaskDeps := worker.VideoTaskDeps{
		VideoRouter:      videoRouter,
		Storage:          d.store,
		ShotLocker:       shotLocker,
		RealtimeHub:      realtimeHub,
		TaskNotifier:     taskNotifier,
		ShotVideoUpdater: shotVideoStore,
		UsageRecorder:    provider_usage.NewDBRecorderWithLogger(db.New(pool), d.logger),
	}
	videoHandler := worker.NewVideoTaskHandler(d.logger, videoTaskDeps)

	ttsTaskDeps := worker.TTSTaskDeps{
		TTSRouter:     ttsRouter,
		Storage:       d.store,
		RealtimeHub:   realtimeHub,
		TaskNotifier:  taskNotifier,
		UsageRecorder: provider_usage.NewDBRecorderWithLogger(db.New(pool), d.logger),
	}
	ttsHandler := worker.NewTTSTaskHandler(d.logger, ttsTaskDeps)

	exportShotReader := shot.ExportShotReaderAdapter(shotStore)
	exportShotVideoReader := shot_video.ExportShotVideoReaderAdapter(shotVideoStore)
	exportHandler := worker.NewExportTaskHandler(d.logger, worker.ExportTaskDeps{
		CompositeUpdater: compositeSvc,
		ShotReader:       exportShotReader,
		ShotVideoReader:  exportShotVideoReader,
		Storage:          d.store,
		RealtimeHub:      realtimeHub,
	})

	packageStore := package_task.NewDBStore(db.New(pool))
	var packageWorkerHandler *worker.PackageTaskHandler
	if d.store != nil {
		packageWorkerHandler = worker.NewPackageTaskHandler(d.logger, worker.PackageTaskDeps{
			PackageUpdater: packageStore,
			Storage:        d.store,
		})
	}
	log.Println("按集打包模块已启用")

	// Asynq
	redisAddr := cfg.Redis.Addr
	if redisAddr != "" && worker.PingRedis(redisAddr, cfg.Redis.Password, cfg.Redis.DB) {
		d.asynqClient = worker.NewClient(redisAddr, cfg.Redis.Password, cfg.Redis.DB)
		d.asynqServer = worker.NewServer(redisAddr, cfg.Redis.Password, cfg.Redis.DB, d.logger)
		pipelineHandler := worker.NewPipelineTaskHandler(d.logger, worker.PipelineTaskDeps{
			ScriptLockChecker: d.scriptLockCheck,
			AsynqClient:       d.asynqClient,
			RealtimeHub:       realtimeHub,
		})
		muxDeps := &worker.MuxDeps{
			ImageHandler:    imageHandler,
			VideoHandler:    videoHandler,
			TTSHandler:      ttsHandler,
			ExportHandler:   exportHandler,
			PackageHandler:  packageWorkerHandler,
			PipelineHandler: pipelineHandler,
		}
		mux := worker.SetupMuxWithDeps(d.logger, muxDeps)
		go func() {
			if err := d.asynqServer.Run(mux); err != nil {
				d.logger.Error("Asynq Worker 异常退出", zap.Error(err))
			}
		}()
		d.logger.Info("Asynq Worker 已启动", zap.String("redis", redisAddr))
	} else {
		if redisAddr == "" {
			d.logger.Info("Redis 未配置，跳过 Asynq Worker 启动")
		} else {
			d.logger.Warn("Redis 连接失败，跳过 Asynq Worker 启动", zap.String("addr", redisAddr))
		}
	}

	if d.asynqClient != nil {
		shotImageSvc.SetAsynqClient(d.asynqClient)
	}

	d.compositeHandler = composite.NewHandler(compositeSvc, d.asynqClient)
	timelineGen := composite.NewTimelineGenerator(exportShotReader, exportShotVideoReader)
	d.timelineHandler = composite.NewTimelineHandler(timelineGen, compositeSvc, storyboardAccess)

	packageSvc := package_task.NewService(packageStore, d.projectVerifier, d.asynqClient)
	d.packageHandler = package_task.NewHandler(packageSvc)

	// 用量
	usageData := usage.NewDBData(db.New(pool))
	usageSvc := usage.NewService(usageData, d.projectVerifier)
	d.usageHandler = usage.NewHandler(usageSvc)

	// 定时任务
	scheduleData := schedule.NewDBData(db.New(pool))
	scheduleSvc := schedule.NewService(scheduleData, d.projectVerifier)
	d.scheduleHandler = schedule.NewHandler(scheduleSvc)
	scheduleDataAdapter := schedule.NewScheduleDataAdapter(scheduleData)
	var trigger scheduler.TaskTrigger
	if d.asynqClient != nil {
		trigger = scheduler.NewAsynqTrigger(d.asynqClient, d.logger)
		d.logger.Info("定时任务调度器使用 AsynqTrigger")
	} else {
		trigger = scheduler.NewNoopTrigger(d.logger)
		d.logger.Info("定时任务调度器使用 NoopTrigger（Redis 不可用）")
	}
	sched := scheduler.NewScheduler(scheduleDataAdapter, trigger, d.logger)
	go sched.Start()
	d.logger.Info("定时任务调度器已启动")

	// 素材库
	resourceData := resource.NewDBData(db.New(pool))
	resourceSvc := resource.NewService(resourceData)
	resourceSvc.SetImageGen(mesh.NewImageCapability(imageRouter))
	if d.llmSvc != nil {
		resourceSvc.SetPromptGen(d.llmSvc)
	}
	resourceSvc.SetTTSCapability(mesh.NewTTSCapability(ttsRouter))
	if cfg.TTS.MiniMaxKey != "" {
		resourceSvc.SetVoiceCloneProvider(audio.NewMiniMaxVoiceCloneProvider(cfg.TTS.MiniMaxKey))
		log.Println("音色克隆 Provider 已注册: minimax_voice_clone")
	}
	if d.store != nil {
		resourceSvc.SetStorage(d.store)
	}
	d.resourceHandler = resource.NewHandler(resourceSvc, realtimeHub)
	d.aiHandler = ai.NewHandler(resourceSvc)
	log.Println("素材库模块已启用")

	// 仪表盘
	dashboardSvc := dashboard.NewService(
		episodeSvc,
		sceneStore,
		characterSvc,
		locationSvc,
		shotStore,
		shotImageStore,
		d.projectVerifier,
	)
	d.dashboardHandler = dashboard.NewHandler(dashboardSvc)
	log.Println("仪表盘模块已启用")

	routeCfg := &route.Config{
		AIHandler:           d.aiHandler,
		AuthHandler:         d.authHandler,
		NotificationHandler:   d.notificationHandler,
		ModelCatalogHandler:  d.modelCatalogHandler,
		OrgHandler:           d.orgHandler,
		TeamHandler:         d.teamHandler,
		TaskHandler:         d.taskHandler,
		ProjectHandler:      d.projectHandler,
		AssetVersionHandler: d.assetVersionHandler,
		EpisodeHandler:      d.episodeHandler,
		SceneHandler:        d.sceneHandler,
		CharacterHandler:    d.characterHandler,
		LocationHandler:    d.locationHandler,
		PropHandler:         d.propHandler,
		StyleHandler:        d.styleHandler,
		ScriptHandler:       d.scriptHandler,
		StoryboardHandler:   d.storyboardHandler,
		ShotHandler:         d.shotHandler,
		ShotImageHandler:    d.shotImageHandler,
		ShotVideoHandler:    d.shotVideoHandler,
		CompositeHandler:    d.compositeHandler,
		TimelineHandler:     d.timelineHandler,
		DownloadHandler:     d.downloadHandler,
		FileHandler:         d.fileHandler,
		PackageHandler:      d.packageHandler,
		UsageHandler:        d.usageHandler,
		ScheduleHandler:     d.scheduleHandler,
		ResourceHandler:     d.resourceHandler,
		DashboardHandler:    d.dashboardHandler,
		WSHandler:           d.wsHandler,
		AsynqClient:        d.asynqClient,
		JWTSecret:          cfg.App.Secret,
		ProjectReader:      d.projectReader,
		ProjectMemberReader: d.projectMemberReader,
		TeamMemberReader:    d.teamMemberReader,
		LockChecker:        d.lockChecker,
		StaticBaseURL:      cfg.Storage.BaseURL,
		StaticRoot:         cfg.Storage.LocalRoot,
	}

	port := os.Getenv("APP_APP_PORT")
	if port == "" {
		port = fmt.Sprintf("%d", cfg.App.Port)
	}
	if port == "0" {
		port = "3737"
	}

	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(middleware.CORS())
	r.Use(middleware.RequestID())
	r.Use(middleware.Logger(d.logger))
	r.Use(metrics.Middleware())
	route.Register(r, routeCfg)

	addr := fmt.Sprintf(":%s", port)
	srv := &http.Server{Addr: addr, Handler: r}

	return &App{
		deps:        d,
		routeCfg:    routeCfg,
		srv:         srv,
		asynqServer: d.asynqServer,
		asynqClient: d.asynqClient,
	}, nil
}

// Run 启动 HTTP 服务并阻塞直到收到退出信号
func (a *App) Run() {
	go func() {
		log.Printf("Server starting on %s", a.srv.Addr)
		if err := a.srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("正在关闭服务...")

	if a.asynqServer != nil {
		a.asynqServer.Shutdown()
		log.Println("Asynq Worker 已停止")
	}
	if a.asynqClient != nil {
		_ = a.asynqClient.Close()
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := a.srv.Shutdown(ctx); err != nil {
		log.Printf("HTTP 服务关闭异常: %v", err)
	} else {
		log.Println("服务已关闭")
	}
}
