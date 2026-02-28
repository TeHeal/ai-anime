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
	"github.com/TeHeal/ai-anime/anime_ai/module/episode"
	"github.com/TeHeal/ai-anime/anime_ai/module/location"
	"github.com/TeHeal/ai-anime/anime_ai/module/project"
	"github.com/TeHeal/ai-anime/anime_ai/module/prop"
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
	"github.com/TeHeal/ai-anime/anime_ai/pub/config"
	"github.com/TeHeal/ai-anime/anime_ai/pub/mesh"
	"github.com/TeHeal/ai-anime/anime_ai/pub/middleware"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/image"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/kie"
	"github.com/TeHeal/ai-anime/anime_ai/pub/realtime"
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
	shotImageSvc := shot_image.NewService(shotImageStore, shotReader, projectVerifier)
	shotImageHandler := shot_image.NewHandler(shotImageSvc)

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

	var store storage.Storage
	if s, storeErr := storage.NewFromConfig(&cfg.Storage); storeErr != nil {
		log.Printf("Storage 初始化失败，使用 nil: %v", storeErr)
		store = nil
	} else {
		store = s
	}

	imageTaskDeps := worker.ImageTaskDeps{
		ImageRouter:    imageRouter,
		Storage:        store,
		ShotImageStore: shotImageStore,
		RealtimeHub:    realtimeHub,
	}
	imageHandler := worker.NewImageTaskHandler(logger, imageTaskDeps)

	// Asynq Worker：Redis 可用时创建 Client 与 Server，供 API 入队任务
	var asynqClient *asynq.Client
	var asynqServer *asynq.Server
	redisAddr := cfg.Redis.Addr
	if redisAddr != "" && worker.PingRedis(redisAddr, cfg.Redis.Password, cfg.Redis.DB) {
		asynqClient = worker.NewClient(redisAddr, cfg.Redis.Password, cfg.Redis.DB)
		asynqServer = worker.NewServer(redisAddr, cfg.Redis.Password, cfg.Redis.DB, logger)
		mux := worker.SetupMuxWithDeps(logger, &worker.MuxDeps{ImageHandler: imageHandler})
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

	// 审核模块
	reviewStore := review.NewMemReviewStore()
	reviewSvc := review.NewService(reviewStore)
	reviewHandler := review.NewHandler(reviewSvc)

	// 通知模块
	notifStore := notification.NewMemStore()
	notifSvc := notification.NewService(notifStore)
	notifHandler := notification.NewHandler(notifSvc)

	// 风格资产模块
	styleStore := style.NewMemStore()
	styleSvc := style.NewService(styleStore)
	styleHandler := style.NewHandler(styleSvc)

	// 任务锁模块
	taskLockStore := tasklock.NewMemStore()
	taskLockSvc := tasklock.NewService(taskLockStore)
	taskLockHandler := tasklock.NewHandler(taskLockSvc)

	// 调度模块
	schedStore := schedule.NewMemStore()
	schedSvc := schedule.NewService(schedStore)
	schedHandler := schedule.NewHandler(schedSvc)

	routeCfg := &RouteConfig{
		AuthHandler:        authHandler,
		ProjectHandler:     projectHandler,
		EpisodeHandler:     episodeHandler,
		SceneHandler:       sceneHandler,
		CharacterHandler:   characterHandler,
		LocationHandler:    locationHandler,
		PropHandler:        propHandler,
		ScriptHandler:      scriptHandler,
		StoryboardHandler:  storyboardHandler,
		ShotHandler:        shotHandler,
		ShotImageHandler:   shotImageHandler,
		WSHandler:          wsHandler,
		AsynqClient:        asynqClient,
		ReviewHandler:      reviewHandler,
		NotifHandler:       notifHandler,
		StyleHandler:       styleHandler,
		TaskLockHandler:    taskLockHandler,
		ScheduleHandler:    schedHandler,
		JWTSecret:          cfg.App.Secret,
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
