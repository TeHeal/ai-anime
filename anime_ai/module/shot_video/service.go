package shot_video

import (
	"context"
	"errors"
	"fmt"

	"anime_ai/pub/auth"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
)

// Service 镜头视频业务逻辑层
type Service struct {
	store             Store
	projectVerifier   crossmodule.ProjectVerifier
	memberResolver    crossmodule.ProjectMemberResolver
	scriptLockChecker crossmodule.ScriptLockChecker
}

// NewService 创建镜头视频服务
func NewService(store Store, projectVerifier crossmodule.ProjectVerifier) *Service {
	return NewServiceWithResolver(store, projectVerifier, nil)
}

// NewServiceWithResolver 创建镜头视频服务（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(store Store, projectVerifier crossmodule.ProjectVerifier, memberResolver crossmodule.ProjectMemberResolver) *Service {
	return &Service{
		store:           store,
		projectVerifier: projectVerifier,
		memberResolver:  memberResolver,
	}
}

func (s *Service) verifyProject(projectID, userID string) error {
	if s.projectVerifier != nil {
		if err := s.projectVerifier.Verify(projectID, userID); err != nil {
			if errors.Is(err, pkg.ErrNotFound) {
				return fmt.Errorf("项目不存在: %w", err)
			}
			return err
		}
	}
	return nil
}

// SetScriptLockChecker 配置脚本锁定检查器（README 2.2/2.4 阶段门禁）
func (s *Service) SetScriptLockChecker(c crossmodule.ScriptLockChecker) {
	s.scriptLockChecker = c
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

// ListByShot 按镜头列出视频
func (s *Service) ListByShot(shotID, projectID, userID string) ([]ShotVideo, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByShot(context.Background(), shotID)
}

// ListByProject 按项目列出视频
func (s *Service) ListByProject(projectID, userID string) ([]ShotVideo, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByProject(context.Background(), projectID)
}

// Get 获取单个视频
func (s *Service) Get(id, projectID, userID string) (*ShotVideo, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.FindByID(context.Background(), id)
}

// Create 创建镜头视频（兼容旧接口）
// 阶段门禁：脚本必须已锁定才能生成镜头视频（README 2.2/2.4）
func (s *Service) Create(shotID, projectID, userID string, shotImageID *string) (*ShotVideo, error) {
	return s.CreateWithParams(shotID, projectID, userID, &VideoCreateRequest{})
}

// CreateWithParams 创建镜头视频（支持完整视频生成参数）
func (s *Service) CreateWithParams(shotID, projectID, userID string, req *VideoCreateRequest) (*ShotVideo, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	if s.scriptLockChecker != nil {
		locked, err := s.scriptLockChecker.IsScriptLocked(projectID)
		if err != nil {
			return nil, fmt.Errorf("检查脚本锁定状态失败: %w", err)
		}
		if !locked {
			return nil, fmt.Errorf("请先锁定脚本后再生成镜头视频")
		}
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceShotVideo, "pending", auth.ActionShotVideoGen); err != nil {
		return nil, err
	}

	v := &ShotVideo{
		ShotID:       shotID,
		ProjectID:    projectID,
		Status:       "pending",
		ReviewStatus: "pending",
	}

	if req != nil {
		v.GenMode = req.GenMode
		v.Resolution = req.Resolution
		v.Ratio = req.Ratio
		v.Provider = req.Provider
		v.Model = req.Model
		v.ServiceTier = req.ServiceTier
		if req.Duration > 0 {
			v.Duration = req.Duration
		}
		if req.Seed != nil {
			v.Seed = *req.Seed
		}
		if req.Draft != nil && *req.Draft {
			v.IsDraft = true
		}
		if req.GenerateAudio != nil && *req.GenerateAudio {
			v.GenerateAudio = true
		}
		v.DraftTaskID = req.DraftTaskID
	}

	if err := s.store.Create(context.Background(), v); err != nil {
		return nil, err
	}
	return v, nil
}

// UpdateReview 更新审核状态
func (s *Service) UpdateReview(id, projectID, userID, status, comment string) (*ShotVideo, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	v, err := s.store.FindByID(context.Background(), id)
	if err != nil {
		return nil, err
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceShotVideo, v.ReviewStatus, auth.ActionShotVideoReview); err != nil {
		return nil, err
	}
	uid := userID
	if err := s.store.UpdateReview(context.Background(), id, status, comment, &uid); err != nil {
		return nil, err
	}
	return s.store.FindByID(context.Background(), id)
}
