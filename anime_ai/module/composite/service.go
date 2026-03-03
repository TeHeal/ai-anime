package composite

import (
	"context"
	"encoding/json"
	"fmt"

	"anime_ai/pub/auth"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
)

// Service 成片业务逻辑层
type Service struct {
	store          Store
	verifier       crossmodule.ProjectVerifier
	memberResolver crossmodule.ProjectMemberResolver
}

// NewService 创建成片服务
func NewService(store Store, verifier crossmodule.ProjectVerifier) *Service {
	return NewServiceWithResolver(store, verifier, nil)
}

// NewServiceWithResolver 创建成片服务（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(store Store, verifier crossmodule.ProjectVerifier, memberResolver crossmodule.ProjectMemberResolver) *Service {
	if verifier == nil {
		verifier = &dummyVerifier{}
	}
	return &Service{store: store, verifier: verifier, memberResolver: memberResolver}
}

type dummyVerifier struct{}

func (dummyVerifier) Verify(projectID, userID string) error { return nil }

// CreateExportRequest 创建导出任务请求
type CreateExportRequest struct {
	EpisodeID string          `json:"episode_id"`
	Config    json.RawMessage `json:"config"`
}

// CreateExport 创建成片导出任务，返回任务 ID（供 Worker 入队后使用）
func (s *Service) CreateExport(ctx context.Context, projectID, userID string, req CreateExportRequest) (*Task, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceComposite, "editing", auth.ActionCompositeExport); err != nil {
		return nil, err
	}
	configJSON := req.Config
	if configJSON == nil {
		configJSON = []byte("{}")
	}
	t, err := s.store.Create(ctx, projectID, req.EpisodeID, "", StatusPending, configJSON)
	if err != nil {
		return nil, err
	}
	return t, nil
}

// Get 获取成片任务
func (s *Service) Get(ctx context.Context, id, projectID, userID string) (*Task, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	t, err := s.store.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if t.ProjectID != projectID {
		return nil, pkg.ErrNotFound
	}
	return t, nil
}

// GetByTaskID 按 Asynq task_id 获取（供 Worker 回调）
func (s *Service) GetByTaskID(ctx context.Context, taskID string) (*Task, error) {
	return s.store.FindByTaskID(ctx, taskID)
}

// ListByProject 按项目列出成片任务
func (s *Service) ListByProject(ctx context.Context, projectID, userID string) ([]Task, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByProject(ctx, projectID)
}

// ListByEpisode 按集列出成片任务
func (s *Service) ListByEpisode(ctx context.Context, episodeID, projectID, userID string) ([]Task, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByEpisode(ctx, episodeID)
}

// UpdateStatus 更新任务状态（供 Worker 调用）
func (s *Service) UpdateStatus(ctx context.Context, id, status, outputURL, errorMsg string) error {
	return s.store.UpdateStatus(ctx, id, status, outputURL, errorMsg)
}

// UpdateTaskID 更新 Asynq task_id（入队后调用）
func (s *Service) UpdateTaskID(ctx context.Context, id, taskID string) error {
	return s.store.UpdateTaskID(ctx, id, taskID)
}

func (s *Service) checkResourceAction(projectID, userID string, resourceType, status string, action auth.Action) error {
	if s.memberResolver == nil {
		return nil
	}
	info, err := s.memberResolver.Resolve(projectID, userID)
	if err != nil {
		return err
	}
	if !auth.CheckResourceAction(resourceType, status, action, info.JobRoles, info.IsOwner) {
		return fmt.Errorf("%w: 当前工种或资源状态不允许执行此操作", pkg.ErrForbidden)
	}
	return nil
}
