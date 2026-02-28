package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/module/auth"
	"github.com/TeHeal/ai-anime/anime_ai/module/character"
	"github.com/TeHeal/ai-anime/anime_ai/module/composite"
	"github.com/TeHeal/ai-anime/anime_ai/module/download"
	"github.com/TeHeal/ai-anime/anime_ai/module/episode"
	"github.com/TeHeal/ai-anime/anime_ai/module/package_task"
	"github.com/TeHeal/ai-anime/anime_ai/module/location"
	"github.com/TeHeal/ai-anime/anime_ai/module/notification"
	"github.com/TeHeal/ai-anime/anime_ai/module/project"
	"github.com/TeHeal/ai-anime/anime_ai/module/prop"
	"github.com/TeHeal/ai-anime/anime_ai/module/scene"
	"github.com/TeHeal/ai-anime/anime_ai/module/script"
	"github.com/TeHeal/ai-anime/anime_ai/module/shot"
	"github.com/TeHeal/ai-anime/anime_ai/module/shot_image"
	"github.com/TeHeal/ai-anime/anime_ai/module/schedule"
	"github.com/TeHeal/ai-anime/anime_ai/module/storyboard"
	"github.com/TeHeal/ai-anime/anime_ai/module/usage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/config"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/mesh"
	"github.com/TeHeal/ai-anime/anime_ai/pub/metrics"
	"github.com/TeHeal/ai-anime/anime_ai/pub/middleware"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/image"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/kie"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/music"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider_usage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/review_record"
	"github.com/TeHeal/ai-anime/anime_ai/pub/realtime"
	"github.com/TeHeal/ai-anime/anime_ai/pub/scheduler"
	"github.com/TeHeal/ai-anime/anime_ai/pub/storage"
	"github.com/TeHeal/ai-anime/anime_ai/pub/worker"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
)

// initPGXPool 创建 pgxpool，DSN 为空或连接失败时返回 nil
func initPGXPool(dsn string) (*pgxpool.Pool, error) {
	if dsn == "" {
		return nil, fmt.Errorf("DSN 为空")
	}
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return nil, err
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, err
	}
	return pool, nil
}

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("加载配置失败: %v", err)
	}

	// 用户存储：DB 可用时优先用 DBUserStore，否则用 BootstrapUserStore
	var userStore auth.UserStore
	var pool *pgxpool.Pool
	dsn := cfg.DB.GetDSN()
	if dsn != "" {
		var poolErr error
		pool, poolErr = initPGXPool(dsn)
		if poolErr != nil {
			log.Printf("PostgreSQL 连接失败，fallback 到内存存储: %v", poolErr)
		}
	}
	if pool != nil {
		queries := db.New(pool)
		userStore = auth.NewDBUserStore(queries)
		log.Println("使用 PostgreSQL 用户存储")
	} else {
		userStore, err = auth.NewBootstrapUserStore(cfg.Admin.Username, cfg.Admin.Password)
		if err != nil {
			log.Fatalf("初始化用户存储失败: %v", err)
		}
		log.Println("使用引导用户存储（无 DB）")
	}

	authSvc := auth.NewAuthService(userStore, cfg.App.Secret)
	authHandler := auth.NewHandler(authSvc)

	// 项目管理：DB 可用时用 DBData，否则 MemData
	var projectData project.Data
	if pool != nil {
		projectData = project.NewDBData(db.New(pool))
		log.Println("使用 PostgreSQL 项目存储")
	} else {
		projectData = project.NewMemData()
	}
	projectSvc := project.NewService(projectData)
	projectHandler := project.NewHandler(projectSvc)
	projectVerifier := project.NewProjectVerifier(projectData)

	// 集、场模块：DB 可用时用 DB 存储，否则 Mem
	var episodeStore episode.EpisodeStore
	if pool != nil {
		episodeStore = episode.NewDBEpisodeStore(db.New(pool))
		log.Println("使用 PostgreSQL 集存储")
	} else {
		episodeStore = episode.NewMemEpisodeStore()
	}
	episodeSvc := episode.NewService(episodeStore, projectVerifier)
	episodeHandler := episode.NewHandler(episodeSvc)

	// 场、块模块：DB 可用时用 DB 存储，否则 Mem
	var sceneStore scene.SceneStore
	var sceneBlockStore scene.SceneBlockStore
	if pool != nil {
		queries := db.New(pool)
		sceneStore = scene.NewDBSceneStore(queries)
		sceneBlockStore = scene.NewDBSceneBlockStore(queries)
		log.Println("使用 PostgreSQL 场/块存储")
	} else {
		sceneStore = scene.NewMemSceneStore()
		sceneBlockStore = scene.NewMemSceneBlockStore()
	}
	episodeReader := episode.EpisodeReaderAdapter(episodeStore)
	sceneSvc := scene.NewService(sceneStore, sceneBlockStore, episodeReader, projectVerifier)
	sceneHandler := scene.NewHandler(sceneSvc)

	// 分镜模块
	storyboardAccess := project.NewStoryboardAccess(projectData)
	storyboardData := storyboard.NewMemData(storyboardAccess)
	storyboardSvc := storyboard.NewService(storyboardData, projectVerifier)
	storyboardHandler := storyboard.NewHandler(storyboardSvc)

	// 脚本模块：DB 可用时用 DBSegmentStore，否则 Mem
	var segmentStore script.SegmentStore
	if pool != nil {
		segmentStore = script.NewDBSegmentStore(db.New(pool))
		log.Println("使用 PostgreSQL 脚本分段存储")
	} else {
		segmentStore = script.NewMemSegmentStore()
	}
	scriptSvc := script.NewService(segmentStore, projectVerifier)
	scriptHandler := script.NewHandler(scriptSvc)

	// 角色模块：DB 可用时用 DBData，否则 Mem
	var characterData character.Data
	if pool != nil {
		characterData = character.NewDBData(db.New(pool))
		log.Println("使用 PostgreSQL 角色存储")
	} else {
		characterData = character.NewMemData()
	}
	characterSvc := character.NewService(characterData, projectVerifier)
	characterHandler := character.NewHandler(characterSvc)

	// 场景资产模块：DB 可用时用 DB，否则 Mem
	var locationStore location.Store
	if pool != nil {
		locationStore = location.NewDBLocationStore(db.New(pool))
		log.Println("使用 PostgreSQL 场景存储")
	} else {
		locationStore = location.NewMemLocationStore()
	}
	locationSvc := location.NewService(locationStore, projectVerifier)
	locationHandler := location.NewHandler(locationSvc)

	// 道具资产模块：DB 可用时用 DB，否则 Mem
	var propStore prop.Store
	if pool != nil {
		propStore = prop.NewDBPropStore(db.New(pool))
		log.Println("使用 PostgreSQL 道具存储")
	} else {
		propStore = prop.NewMemPropStore()
	}
	propSvc := prop.NewService(propStore, projectVerifier)
	propHandler := prop.NewHandler(propSvc)

	// 镜头模块：DB 可用时用 DBShotStore，否则 Mem
	var shotStore shot.ShotStore
	if pool != nil {
		shotStore = shot.NewDBShotStore(db.New(pool))
		log.Println("使用 PostgreSQL 镜头存储")
	} else {
		shotStore = shot.NewMemShotStore()
	}
	shotReader := shot.ShotReaderAdapter(shotStore)
	shotLocker := shot.ShotLockerAdapter(shotStore)
	shotSvc := shot.NewService(shotStore, projectVerifier)
	shotHandler := shot.NewHandler(shotSvc)

	// 镜图模块：DB 可用时用 DBShotImageStore，否则 Mem
	var shotImageStore shot_image.ShotImageStore
	if pool != nil {
		shotImageStore = shot_image.NewDBShotImageStore(db.New(pool))
		log.Println("使用 PostgreSQL 镜图存储")
	} else {
		shotImageStore = shot_image.NewMemShotImageStore()
	}
	var reviewRecorder crossmodule.ReviewRecorder
	if pool != nil {
		reviewRecorder = review_record.NewDBRecorder(db.New(pool))
	}
	shotImageSvc := shot_image.NewService(shotImageStore, shotReader, shotLocker, projectVerifier, reviewRecorder)
	shotImageHandler := shot_image.NewHandler(shotImageSvc)

	// 通知模块（README 2.6 站内通知中心、红点）
	var notificationHandler *notification.Handler
	var taskNotifier worker.TaskNotifier
	if pool != nil {
		notificationData := notification.NewDBData(db.New(pool))
		notificationSvc := notification.NewService(notificationData)
		notificationHandler = notification.NewHandler(notificationSvc)
		taskNotifier = notification.NewTaskNotifierAdapter(notificationSvc)
		log.Println("通知模块已启用")
	}

	// 成片模块（README 成片阶段，状态机 editing→exporting→done）
	var compositeStore composite.Store
	var compositeSvc *composite.Service
	if pool != nil {
		compositeStore = composite.NewDBStore(db.New(pool))
		compositeSvc = composite.NewService(compositeStore, projectVerifier)
		log.Println("成片模块已启用")
	}

	// WebSocket Hub（任务进度推送等）
	logger, _ := zap.NewProduction()
	if cfg.App.Mode == "debug" {
		logger, _ = zap.NewDevelopment()
	}
	realtimeHub := realtime.NewHub(logger)
	wsHandler := realtime.NewWSHandler(realtimeHub, cfg.App.Secret)

	// 文生图路由与存储（供 Worker 使用）
	imagePolicy := mesh.DefaultPolicy()
	imageBreaker := mesh.NewBreaker(3)
	imageRouter := mesh.NewImageRouter(imagePolicy, imageBreaker)
	if cfg.Image.SeedreamKey != "" {
		imageRouter.RegisterProvider(image.NewSeedreamProvider(cfg.Image.SeedreamKey))
	}
	if cfg.Image.WanxKey != "" {
		imageRouter.RegisterProvider(image.NewWanxProvider(cfg.Image.WanxKey))
	}
	if cfg.KIE.APIKey != "" {
		imageRouter.RegisterProvider(kie.NewKIEImageProvider(cfg.KIE.APIKey))
	}

	// 音乐路由（README：Suno 通过 kie.ai API）
	musicPolicy := mesh.DefaultPolicy()
	musicBreaker := mesh.NewBreaker(3)
	musicRouter := mesh.NewMusicRouter(musicPolicy, musicBreaker)
	if cfg.KIE.APIKey != "" {
		musicRouter.RegisterProvider(music.NewKieMusicProvider(cfg.KIE.APIKey))
	}
	if cfg.Music.SunoKey != "" {
		musicRouter.RegisterProvider(music.NewSunoProvider(cfg.Music.SunoKey, cfg.Music.SunoBaseURL))
	}

	var store storage.Storage
	if s, storeErr := storage.NewFromConfig(&cfg.Storage); storeErr != nil {
		log.Printf("Storage 初始化失败，使用 nil: %v", storeErr)
		store = nil
	} else {
		store = s
	}

	var downloadHandler *download.Handler
	if store != nil {
		downloadHandler = download.NewHandler(store, projectVerifier)
	}

	imageTaskDeps := worker.ImageTaskDeps{
		ImageRouter:    imageRouter,
		Storage:        store,
		ShotImageStore: shotImageStore,
		ShotLocker:     shotLocker,
		RealtimeHub:    realtimeHub,
		TaskNotifier:   taskNotifier,
		UsageRecorder:  nil,
	}
	if pool != nil {
		imageTaskDeps.UsageRecorder = provider_usage.NewDBRecorder(db.New(pool))
	}
	imageHandler := worker.NewImageTaskHandler(logger, imageTaskDeps)

	var exportHandler *worker.ExportTaskHandler
	if compositeSvc != nil {
		exportHandler = worker.NewExportTaskHandler(logger, worker.ExportTaskDeps{CompositeService: compositeSvc})
	}

	// 按集打包模块（README 2.7）：Store 与 Worker 需在 Redis 块前创建，供 muxDeps 使用
	var packageHandler *package_task.Handler
	var packageStore package_task.Store
	var packageWorkerHandler *worker.PackageTaskHandler
	if pool != nil {
		packageStore = package_task.NewDBStore(db.New(pool))
		if packageStore != nil && store != nil {
			packageWorkerHandler = worker.NewPackageTaskHandler(logger, worker.PackageTaskDeps{
				PackageStore: packageStore,
				Storage:      store,
			})
		}
		log.Println("按集打包模块已启用")
	}

	// Asynq Worker：Redis 可用时创建 Client 与 Server，供 API 入队任务
	var asynqClient *asynq.Client
	var asynqServer *asynq.Server
	redisAddr := cfg.Redis.Addr
	if redisAddr != "" && worker.PingRedis(redisAddr, cfg.Redis.Password, cfg.Redis.DB) {
		asynqClient = worker.NewClient(redisAddr, cfg.Redis.Password, cfg.Redis.DB)
		asynqServer = worker.NewServer(redisAddr, cfg.Redis.Password, cfg.Redis.DB, logger)
		muxDeps := &worker.MuxDeps{
			ImageHandler:   imageHandler,
			ExportHandler:  exportHandler,
			PackageHandler: packageWorkerHandler,
		}
		mux := worker.SetupMuxWithDeps(logger, muxDeps)
		go func() {
			if err := asynqServer.Run(mux); err != nil {
				logger.Error("Asynq Worker 异常退出", zap.Error(err))
			}
		}()
		logger.Info("Asynq Worker 已启动", zap.String("redis", redisAddr))
	} else {
		if redisAddr == "" {
			logger.Info("Redis 未配置，跳过 Asynq Worker 启动")
		} else {
			logger.Warn("Redis 连接失败，跳过 Asynq Worker 启动", zap.String("addr", redisAddr))
		}
	}

	var compositeHandler *composite.Handler
	if compositeSvc != nil {
		compositeHandler = composite.NewHandler(compositeSvc, asynqClient)
	}

	// 打包 HTTP Handler（需 asynqClient 入队，Redis 可用时创建）
	if packageStore != nil {
		packageSvc := package_task.NewService(packageStore, projectVerifier, asynqClient)
		packageHandler = package_task.NewHandler(packageSvc)
	}

	// 用量查询模块（README 8.3 AI 成本控制）
	var usageHandler *usage.Handler
	if pool != nil {
		usageData := usage.NewDBData(db.New(pool))
		usageSvc := usage.NewService(usageData, projectVerifier)
		usageHandler = usage.NewHandler(usageSvc)
	}

	// 定时任务模块（README 2.1 任务编排与定时）
	var scheduleHandler *schedule.Handler
	if pool != nil {
		scheduleData := schedule.NewDBData(db.New(pool))
		scheduleSvc := schedule.NewService(scheduleData, projectVerifier)
		scheduleHandler = schedule.NewHandler(scheduleSvc)
		// 启动调度器（占位触发器，后续可接入批量镜图等）
		sched := scheduler.NewScheduler(scheduleData, scheduler.NewNoopTrigger(logger), logger)
		go sched.Start()
		logger.Info("定时任务调度器已启动")
	}

	routeCfg := &RouteConfig{
		AuthHandler:         authHandler,
		NotificationHandler: notificationHandler,
		ProjectHandler:      projectHandler,
		EpisodeHandler:      episodeHandler,
		SceneHandler:        sceneHandler,
		CharacterHandler:    characterHandler,
		LocationHandler:     locationHandler,
		PropHandler:         propHandler,
		ScriptHandler:       scriptHandler,
		StoryboardHandler:   storyboardHandler,
		ShotHandler:         shotHandler,
		ShotImageHandler:    shotImageHandler,
		CompositeHandler:    compositeHandler,
		DownloadHandler:     downloadHandler,
		PackageHandler:      packageHandler,
		UsageHandler:        usageHandler,
		ScheduleHandler:     scheduleHandler,
		WSHandler:           wsHandler,
		AsynqClient:         asynqClient,
		JWTSecret:           cfg.App.Secret,
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
	r.Use(middleware.RequestID())
	r.Use(middleware.Logger(logger))
	r.Use(metrics.Middleware())
	registerRoutes(r, routeCfg)

	addr := fmt.Sprintf(":%s", port)
	srv := &http.Server{Addr: addr, Handler: r}
	go func() {
		log.Printf("Server starting on %s", addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed: %v", err)
		}
	}()

	// 优雅关闭：等待 SIGINT/SIGTERM 后 Stop Worker、Close Client、Shutdown HTTP
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("正在关闭服务...")

	if asynqServer != nil {
		asynqServer.Shutdown()
		log.Println("Asynq Worker 已停止")
	}
	if asynqClient != nil {
		_ = asynqClient.Close()
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("HTTP 服务关闭异常: %v", err)
	} else {
		log.Println("服务已关闭")
	}
}
