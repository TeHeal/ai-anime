package shot_image

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"anime_ai/pub/auth"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
	"anime_ai/pub/tasktypes"
	"github.com/google/uuid"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// Service 镜图业务逻辑层
type Service struct {
	store             crossmodule.ShotImageStore
	shotReader        crossmodule.ShotReader
	shotLocker        crossmodule.ShotLocker
	projectVerifier   crossmodule.ProjectVerifier
	memberResolver    crossmodule.ProjectMemberResolver
	reviewRecorder    crossmodule.ReviewRecorder
	scriptLockChecker crossmodule.ScriptLockChecker
	reviewFlowCfg     *ReviewFlowConfig
	asynqClient       *asynq.Client
	logger            *zap.Logger
}

// SetAsynqClient 设置 Asynq 客户端（供 main.go 注入）
func (s *Service) SetAsynqClient(c *asynq.Client) { s.asynqClient = c }

// NewService 创建镜图服务
func NewService(
	store crossmodule.ShotImageStore,
	shotReader crossmodule.ShotReader,
	shotLocker crossmodule.ShotLocker,
	projectVerifier crossmodule.ProjectVerifier,
	reviewRecorder crossmodule.ReviewRecorder,
) *Service {
	return NewServiceWithResolver(store, shotReader, shotLocker, projectVerifier, nil, reviewRecorder)
}

// NewServiceWithResolver 创建镜图服务（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(
	store crossmodule.ShotImageStore,
	shotReader crossmodule.ShotReader,
	shotLocker crossmodule.ShotLocker,
	projectVerifier crossmodule.ProjectVerifier,
	memberResolver crossmodule.ProjectMemberResolver,
	reviewRecorder crossmodule.ReviewRecorder,
) *Service {
	return &Service{
		store:           store,
		shotReader:      shotReader,
		shotLocker:      shotLocker,
		projectVerifier: projectVerifier,
		memberResolver:  memberResolver,
		reviewRecorder:  reviewRecorder,
	}
}

// SetReviewFlowConfig 配置审核流程（AI 审核等），在 Service 创建后调用
func (s *Service) SetReviewFlowConfig(cfg *ReviewFlowConfig) {
	s.reviewFlowCfg = cfg
}

// SetScriptLockChecker 配置脚本锁定检查器（README 2.2/2.4 阶段门禁）
func (s *Service) SetScriptLockChecker(c crossmodule.ScriptLockChecker) {
	s.scriptLockChecker = c
}

// SetLogger 注入 logger，用于记录错误日志（审核流程、重生成等）
func (s *Service) SetLogger(l *zap.Logger) {
	s.logger = l
}

func (s *Service) log() *zap.Logger {
	if s.logger != nil {
		return s.logger
	}
	return zap.L()
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

// checkResourceAction 校验用户在资源状态下是否有权执行操作（工种+状态）
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

// Create 创建镜图
func (s *Service) Create(shotID, projectID, userID string, imageURL string) (*ShotImage, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	if s.shotReader != nil {
		pid, _, reviewStatus, err := s.shotReader.GetShot(shotID)
		if err != nil {
			return nil, fmt.Errorf("镜头不存在: %w", err)
		}
		if err := s.checkResourceAction(projectID, userID, auth.ResourceShotImage, reviewStatus, auth.ActionShotImageEdit); err != nil {
			return nil, err
		}
		if pid != projectID {
			return nil, fmt.Errorf("镜头不属于该项目")
		}
	}
	img := &ShotImage{
		ShotID:    shotID,
		ProjectID: projectID,
		ImageURL:  imageURL,
		Status:    "completed",
	}
	if err := s.store.Create(img); err != nil {
		return nil, err
	}
	return img, nil
}

// ListByShot 列出镜头的镜图候选
func (s *Service) ListByShot(shotID, userID string) ([]ShotImage, error) {
	if s.shotReader == nil {
		return nil, fmt.Errorf("shot reader 未配置")
	}
	projectID, _, _, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return nil, fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByShot(shotID)
}

// Get 获取镜图
func (s *Service) Get(id, userID string) (*ShotImage, error) {
	img, err := s.store.FindByID(id)
	if err != nil {
		return nil, fmt.Errorf("镜图不存在: %w", err)
	}
	if err := s.verifyProject(img.ProjectID, userID); err != nil {
		return nil, err
	}
	return img, nil
}

// Delete 删除镜图
func (s *Service) Delete(id, userID string) error {
	img, err := s.store.FindByID(id)
	if err != nil {
		return fmt.Errorf("镜图不存在: %w", err)
	}
	if err := s.verifyProject(img.ProjectID, userID); err != nil {
		return err
	}
	var reviewStatus string
	if s.shotReader != nil {
		_, _, reviewStatus, err = s.shotReader.GetShot(img.ShotID)
		if err != nil {
			s.log().Warn("获取镜头审核状态失败，使用空状态继续删除",
				zap.String("shot_id", img.ShotID), zap.Error(err))
			reviewStatus = ""
		}
	}
	if err := s.checkResourceAction(img.ProjectID, userID, auth.ResourceShotImage, reviewStatus, auth.ActionShotImageEdit); err != nil {
		return err
	}
	return s.store.Delete(id)
}

// SelectCandidate 选择镜图作为镜头的关键帧
func (s *Service) SelectCandidate(shotID, assetID, userID string) error {
	if s.shotReader == nil {
		return fmt.Errorf("shot reader 未配置")
	}
	projectID, _, reviewStatus, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(projectID, userID); err != nil {
		return err
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceShotImage, reviewStatus, auth.ActionShotImageEdit); err != nil {
		return err
	}
	img, err := s.store.FindByID(assetID)
	if err != nil {
		return fmt.Errorf("镜图不存在: %w", err)
	}
	if img.ShotID != shotID || img.ProjectID != projectID {
		return fmt.Errorf("镜图不属于该镜头")
	}
	return s.shotReader.UpdateShotImage(shotID, img.ImageURL)
}

// UpdateImageReview 更新镜头镜图审核状态
// 当审核结果为 rejected 且审核配置为 ai_only/human_and_ai 时，自动触发重生成（README 2.2）
func (s *Service) UpdateImageReview(shotID, userID string, status, comment string) error {
	if s.shotReader == nil {
		return fmt.Errorf("shot reader 未配置")
	}
	projectID, _, reviewStatus, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(projectID, userID); err != nil {
		return err
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceShotImage, reviewStatus, auth.ActionShotImageReview); err != nil {
		return err
	}
	if err := s.shotReader.UpdateShotReview(shotID, status, comment); err != nil {
		return err
	}
	if s.reviewRecorder != nil {
		s.reviewRecorder.Record(context.Background(), "shot", shotID, projectID, userID, "human", status, comment, nil)
	}
	// 审核拒绝时自动触发重生成（README 2.2 审核闭环）
	if status == ReviewStatusRejected && s.shouldAutoRetry(projectID) {
		if err := s.triggerRegeneration(shotID, projectID, userID, comment); err != nil {
			s.log().Warn("触发镜图重生成失败", zap.String("shot_id", shotID), zap.Error(err))
		}
	}
	return nil
}

// BatchReview 批量审核镜图
func (s *Service) BatchReview(shotIDs []string, status string, userID string) error {
	if s.shotReader == nil {
		return fmt.Errorf("shot reader 未配置")
	}
	if len(shotIDs) == 0 {
		return nil
	}
	projectID, _, reviewStatus, err := s.shotReader.GetShot(shotIDs[0])
	if err != nil {
		return fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(projectID, userID); err != nil {
		return err
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceShotImage, reviewStatus, auth.ActionShotImageReview); err != nil {
		return err
	}
	if err := s.shotReader.BatchUpdateShotReview(shotIDs, status); err != nil {
		return err
	}
	if s.reviewRecorder != nil {
		ctx := context.Background()
		for _, shotID := range shotIDs {
			s.reviewRecorder.Record(ctx, "shot", shotID, projectID, userID, "human", status, "", nil)
		}
	}
	return nil
}

// BatchGenerate 批量生成镜图，加锁并入队 Asynq 任务（README 2.3 任务锁）
// 阶段门禁：脚本必须已锁定才能生成镜图（README 2.2/2.4）
func (s *Service) BatchGenerate(projectID, userID string, req BatchGenerateRequest) ([]BatchGenerateResult, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	if s.scriptLockChecker != nil {
		locked, err := s.scriptLockChecker.IsScriptLocked(projectID)
		if err != nil {
			return nil, fmt.Errorf("检查脚本锁定状态失败: %w", err)
		}
		if !locked {
			return nil, fmt.Errorf("请先锁定脚本后再生成镜图")
		}
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceShotImage, "pending", auth.ActionShotImageGen); err != nil {
		return nil, err
	}
	results := make([]BatchGenerateResult, len(req.ShotIDs))
	for i, shotID := range req.ShotIDs {
		if s.shotLocker != nil {
			if err := s.shotLocker.TryLockShot(shotID, userID); err != nil {
				if errors.Is(err, pkg.ErrLocked) {
					results[i] = BatchGenerateResult{ShotID: shotID, Status: "locked", Error: "该镜头正在被他人执行"}
					continue
				}
				results[i] = BatchGenerateResult{ShotID: shotID, Status: "error", Error: err.Error()}
				continue
			}
		}

		// 使用全局提示词或默认值
		fullPrompt := req.Config.GlobalPrompt
		if fullPrompt == "" {
			fullPrompt = "anime style illustration, high quality"
		}
		negPrompt := req.Config.NegativePrompt

		// 入队 Asynq 任务
		taskIDs := []string{}
		if s.asynqClient != nil {
			taskID := uuid.New().String()
			payload := map[string]interface{}{
				"task_id":         taskID,
				"shot_image_id":   "",
				"provider":        req.Config.Provider,
				"model":           req.Config.Model,
				"prompt":          fullPrompt,
				"negative_prompt": negPrompt,
				"project_id":      projectID,
				"user_id":         userID,
				"shot_id":         shotID,
			}
			payloadBytes, _ := json.Marshal(payload)
			task := asynq.NewTask(tasktypes.TypeImageGeneration, payloadBytes)
			if _, err := s.asynqClient.Enqueue(task); err == nil {
				taskIDs = append(taskIDs, taskID)
			}
		}
		results[i] = BatchGenerateResult{ShotID: shotID, Status: "queued", TaskIDs: taskIDs}
	}
	return results, nil
}

// BatchGenerateRequest 批量生成请求
type BatchGenerateRequest struct {
	ShotIDs []string       `json:"shot_ids" binding:"required,min=1"`
	Config  GenerateConfig `json:"config"`
}

// BatchGenerateResult 批量生成结果（占位）
type BatchGenerateResult struct {
	ShotID  string   `json:"shot_id"`
	TaskIDs []string `json:"task_ids"`
	Status  string   `json:"status"`
	Error   string   `json:"error,omitempty"`
}

// GetStatus 获取项目镜图生成状态（占位）
func (s *Service) GetStatus(projectID, userID string) (map[string]interface{}, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	return map[string]interface{}{
		"pending":   0,
		"running":   0,
		"completed": 0,
		"failed":    0,
	}, nil
}

// GetAllowedActionsForShot 返回用户在镜头镜图上的可执行操作（供前端渲染按钮）
func (s *Service) GetAllowedActionsForShot(shotID, userID string) ([]string, error) {
	if s.shotReader == nil {
		return nil, nil
	}
	projectID, _, reviewStatus, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return nil, err
	}
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	if s.memberResolver == nil {
		return nil, nil
	}
	info, err := s.memberResolver.Resolve(projectID, userID)
	if err != nil {
		return nil, err
	}
	actions := auth.AllowedActionsForResource(auth.ResourceShotImage, reviewStatus, info.JobRoles, info.IsOwner)
	out := make([]string, len(actions))
	for i, a := range actions {
		out[i] = string(a)
	}
	return out, nil
}
