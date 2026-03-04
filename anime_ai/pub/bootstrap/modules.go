package bootstrap

import (
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
	"anime_ai/pub/middleware"
	"anime_ai/pub/realtime"
	"anime_ai/pub/provider/llm"
	"anime_ai/pub/storage"
	"anime_ai/sch/db"
	"github.com/hibiken/asynq"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
)

// deps 依赖容器，供 bootstrap 在各 init 函数间传递
type deps struct {
	cfg             *config.Config
	pool            *pgxpool.Pool
	queries         *db.Queries
	llmSvc          *llm.LLMService
	imageRouter     *mesh.ImageRouter
	store           storage.Storage
	logger          *zap.Logger
	asynqClient     *asynq.Client
	asynqServer     *asynq.Server
	projectData     project.Data
	projectVerifier crossmodule.ProjectVerifier
	scriptLockCheck crossmodule.ScriptLockChecker
	lockChecker     middleware.LockChecker

	aiHandler            *ai.Handler
	authHandler          *auth.Handler
	projectHandler       *project.Handler
	episodeHandler       *episode.Handler
	sceneHandler         *scene.Handler
	storyboardHandler    *storyboard.Handler
	scriptHandler        *script.Handler
	characterHandler     *character.Handler
	locationHandler      *location.Handler
	propHandler         *prop.Handler
	styleHandler        *style.Handler
	assetVersionHandler  *asset_version.Handler
	shotHandler         *shot.Handler
	shotImageHandler    *shot_image.Handler
	shotVideoHandler    *shot_video.Handler
	notificationHandler *notification.Handler
	orgHandler          *organization.Handler
	teamHandler         *team.Handler
	taskHandler         *task.Handler
	compositeHandler    *composite.Handler
	timelineHandler     *composite.TimelineHandler
	downloadHandler     *download.Handler
	fileHandler        *file.Handler
	packageHandler      *package_task.Handler
	usageHandler        *usage.Handler
	scheduleHandler     *schedule.Handler
	resourceHandler     *resource.Handler
	dashboardHandler    *dashboard.Handler
	wsHandler           *realtime.WSHandler

	projectReader       middleware.ProjectReader
	projectMemberReader middleware.ProjectMemberReader
	teamMemberReader    middleware.TeamMemberReader
}
