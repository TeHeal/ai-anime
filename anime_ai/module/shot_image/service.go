package shot_image

import (
	"encoding/json"
	"errors"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/pub/prompt"
	"github.com/hibiken/asynq"
	"go.uber.org/zap"
)

// Service 镜图业务逻辑层
type Service struct {
	store           ShotImageStore
	shotReader      crossmodule.ShotReader
	projectVerifier crossmodule.ProjectVerifier
	asynqClient     *asynq.Client
	logger          *zap.Logger
}

// NewService 创建镜图服务
func NewService(
	store ShotImageStore,
	shotReader crossmodule.ShotReader,
	projectVerifier crossmodule.ProjectVerifier,
	asynqClient *asynq.Client,
	logger *zap.Logger,
) *Service {
	return &Service{
		store:           store,
		shotReader:      shotReader,
		projectVerifier: projectVerifier,
		asynqClient:     asynqClient,
		logger:          logger,
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

// Create 创建镜图
func (s *Service) Create(shotID, projectID, userID string, imageURL string) (*ShotImage, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	if s.shotReader != nil {
		pid, _, _, err := s.shotReader.GetShot(shotID)
		if err != nil {
			return nil, fmt.Errorf("镜头不存在: %w", err)
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
	return s.store.Delete(id)
}

// SelectCandidate 选择镜图作为镜头的关键帧
func (s *Service) SelectCandidate(shotID, assetID, userID string) error {
	if s.shotReader == nil {
		return fmt.Errorf("shot reader 未配置")
	}
	projectID, _, _, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(projectID, userID); err != nil {
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
func (s *Service) UpdateImageReview(shotID, userID string, status, comment string) error {
	if s.shotReader == nil {
		return fmt.Errorf("shot reader 未配置")
	}
	projectID, _, _, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(projectID, userID); err != nil {
		return err
	}
	return s.shotReader.UpdateShotReview(shotID, status, comment)
}

// BatchReview 批量审核镜图
func (s *Service) BatchReview(shotIDs []string, status string, userID string) error {
	if s.shotReader == nil {
		return fmt.Errorf("shot reader 未配置")
	}
	if len(shotIDs) == 0 {
		return nil
	}
	projectID, _, _, err := s.shotReader.GetShot(shotIDs[0])
	if err != nil {
		return fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(projectID, userID); err != nil {
		return err
	}
	return s.shotReader.BatchUpdateShotReview(shotIDs, status)
}

// BatchGenerate 批量生成镜图（入队 Asynq 任务）
func (s *Service) BatchGenerate(projectID, userID string, req BatchGenerateRequest) ([]BatchGenerateResult, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}

	results := make([]BatchGenerateResult, len(req.ShotIDs))
	for i, shotID := range req.ShotIDs {
		result := BatchGenerateResult{ShotID: shotID, Status: "queued"}

		// 构建完整的生成 prompt
		fullPrompt := prompt.ShotImagePrompt(req.Config.GlobalPrompt, "", "")
		negPrompt := prompt.ShotImageNegative(req.Config.NegativePrompt)

		// 创建镜图记录
		img := &ShotImage{
			ShotID:    shotID,
			ProjectID: projectID,
			Status:    "pending",
		}
		if err := s.store.Create(img); err != nil {
			result.Status = "failed"
			result.Error = "创建镜图记录失败"
			results[i] = result
			continue
		}

		// 入队 Asynq 任务（如果 Client 可用）
		if s.asynqClient != nil {
			payload, _ := json.Marshal(map[string]interface{}{
				"task_id":        fmt.Sprintf("img_%s_%s", projectID, img.ID),
				"shot_image_id":  img.ID,
				"provider":       req.Config.Provider,
				"model":          req.Config.Model,
				"prompt":         fullPrompt,
				"negative_prompt": negPrompt,
				"width":          req.Config.Width,
				"height":         req.Config.Height,
				"count":          1,
				"project_id":     projectID,
				"user_id":        userID,
			})
			task := asynq.NewTask("image:generate", payload)
			info, err := s.asynqClient.Enqueue(task)
			if err != nil {
				if s.logger != nil {
					s.logger.Error("入队镜图生成任务失败", zap.String("shot_id", shotID), zap.Error(err))
				}
				result.Status = "failed"
				result.Error = "任务入队失败"
			} else {
				result.TaskIDs = []string{info.ID}
				if s.logger != nil {
					s.logger.Info("镜图生成任务已入队", zap.String("task_id", info.ID), zap.String("shot_id", shotID))
				}
			}
		} else {
			result.TaskIDs = []string{}
			if s.logger != nil {
				s.logger.Warn("Asynq 未配置，镜图任务未入队", zap.String("shot_id", shotID))
			}
		}

		results[i] = result
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
