package package_task

import (
	"context"
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/hibiken/asynq"
)

// Config 打包配置（与 episode.PackageConfig 一致）
type Config struct {
	IncludeShotImages bool `json:"include_shot_images"`
	IncludeVoices     bool `json:"include_voices"`
	IncludeShots      bool `json:"include_shots"`
	IncludeFinal      bool `json:"include_final"`
}

// Service 打包任务业务逻辑层
type Service struct {
	store       Store
	verifier    crossmodule.ProjectVerifier
	asynqClient *asynq.Client
}

// NewService 创建打包服务
func NewService(store Store, verifier crossmodule.ProjectVerifier, asynqClient *asynq.Client) *Service {
	return &Service{store: store, verifier: verifier, asynqClient: asynqClient}
}

// CreateAndEnqueue 创建打包任务并入队，返回任务 ID
func (s *Service) CreateAndEnqueue(ctx context.Context, projectID, episodeID, userID string, cfg Config) (*Task, error) {
	if s.verifier != nil {
		if err := s.verifier.Verify(projectID, userID); err != nil {
			return nil, err
		}
	}
	configJSON, _ := json.Marshal(cfg)
	task, err := s.store.Create(ctx, projectID, episodeID, "", StatusPending, configJSON)
	if err != nil {
		return nil, err
	}
	if s.asynqClient != nil {
		payload, _ := json.Marshal(map[string]interface{}{
			"package_task_id": task.ID,
			"project_id":      projectID,
			"episode_id":      episodeID,
			"user_id":         userID,
			"config":          cfg,
		})
		asynqTask, err := s.asynqClient.EnqueueContext(ctx, asynq.NewTask(tasktypes.TypePackage, payload))
		if err == nil {
			_ = s.store.UpdateTaskID(ctx, task.ID, asynqTask.ID)
			task.TaskID = asynqTask.ID
		}
	}
	return task, nil
}

// Get 获取打包任务
func (s *Service) Get(ctx context.Context, id, projectID, userID string) (*Task, error) {
	if s.verifier != nil {
		if err := s.verifier.Verify(projectID, userID); err != nil {
			return nil, err
		}
	}
	task, err := s.store.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if task.ProjectID != projectID {
		return nil, pkg.ErrNotFound
	}
	return task, nil
}

// GetByTaskID 按 Asynq task_id 获取
func (s *Service) GetByTaskID(ctx context.Context, taskID string) (*Task, error) {
	return s.store.FindByTaskID(ctx, taskID)
}

// ListByEpisode 按集列出
func (s *Service) ListByEpisode(ctx context.Context, episodeID, projectID, userID string) ([]Task, error) {
	if s.verifier != nil {
		if err := s.verifier.Verify(projectID, userID); err != nil {
			return nil, err
		}
	}
	return s.store.ListByEpisode(ctx, episodeID)
}

// UpdateStatus 更新状态（供 Worker 调用）
func (s *Service) UpdateStatus(ctx context.Context, id, status, outputURL, errorMsg string) error {
	return s.store.UpdateStatus(ctx, id, status, outputURL, errorMsg)
}
