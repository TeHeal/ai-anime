package shot_image

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
)

// 审核状态常量（README §状态机：review → ai_reviewing → ai_approved/ai_rejected → approved/rejected）
const (
	ReviewStatusReview      = "review"
	ReviewStatusAIReviewing = "ai_reviewing"
	ReviewStatusAIApproved  = "ai_approved"
	ReviewStatusAIRejected  = "ai_rejected"
	ReviewStatusApproved    = "approved"
	ReviewStatusRejected    = "rejected"
	ReviewStatusHumanReview = "human_review"
)

// AIReviewer AI 审核接口，由 LLM provider 实现
type AIReviewer interface {
	ReviewImage(ctx context.Context, imageURL, projectID, prompt string) (approved bool, comment string, err error)
}

// ReviewFlowConfig 审核流程运行时配置
type ReviewFlowConfig struct {
	ReviewConfigReader crossmodule.ReviewConfigReader
	AIReviewer         AIReviewer
}

// SubmitForReview 提交审核：根据项目审核配置决定走人工/AI/混合流程
// 当 review_config 为 ai_only 时自动走 AI 审核；为 human_and_ai 时先 AI 初筛
func (s *Service) SubmitForReview(shotID, projectID, userID string) error {
	if err := s.verifyProject(projectID, userID); err != nil {
		return err
	}
	if err := s.checkResourceAction(projectID, userID, auth.ResourceShotImage, "review", auth.ActionShotImageReview); err != nil {
		return err
	}

	mode := s.getReviewMode(projectID)
	switch mode {
	case "ai_only":
		return s.executeAIReview(shotID, projectID)
	case "human_and_ai":
		return s.executeAIFirstReview(shotID, projectID)
	default:
		return nil
	}
}

// getReviewMode 获取镜图阶段的审核模式，未配置时默认人工审核
func (s *Service) getReviewMode(projectID string) string {
	if s.reviewFlowCfg == nil || s.reviewFlowCfg.ReviewConfigReader == nil {
		return "human_only"
	}
	mode, err := s.reviewFlowCfg.ReviewConfigReader.GetStageReviewMode(projectID, crossmodule.StageShotImage)
	if err != nil {
		return "human_only"
	}
	return mode
}

// executeAIReview 仅 AI 审核：AI 通过则直接 approved，AI 拒绝则 rejected
func (s *Service) executeAIReview(shotID, projectID string) error {
	if s.reviewFlowCfg == nil || s.reviewFlowCfg.AIReviewer == nil {
		return nil
	}
	if err := s.shotReader.UpdateShotReview(shotID, ReviewStatusAIReviewing, ""); err != nil {
		return fmt.Errorf("更新审核状态失败: %w", err)
	}
	_, imageURL, _, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return fmt.Errorf("获取镜头信息失败: %w", err)
	}
	ctx := context.Background()
	approved, comment, err := s.reviewFlowCfg.AIReviewer.ReviewImage(ctx, imageURL, projectID, "")
	if err != nil {
		_ = s.shotReader.UpdateShotReview(shotID, ReviewStatusReview, "AI 审核异常，回退到人工审核")
		return nil
	}
	var finalStatus string
	if approved {
		finalStatus = ReviewStatusApproved
	} else {
		finalStatus = ReviewStatusRejected
	}
	if err := s.shotReader.UpdateShotReview(shotID, finalStatus, comment); err != nil {
		return fmt.Errorf("更新审核结果失败: %w", err)
	}
	if s.reviewRecorder != nil {
		s.reviewRecorder.Record(ctx, "shot", shotID, projectID, "ai", "ai", finalStatus, comment, nil)
	}
	return nil
}

// executeAIFirstReview 人工+AI 混合审核：AI 初筛，AI 通过则 ai_approved（待人工终审），AI 拒绝则 human_review
func (s *Service) executeAIFirstReview(shotID, projectID string) error {
	if s.reviewFlowCfg == nil || s.reviewFlowCfg.AIReviewer == nil {
		return nil
	}
	if err := s.shotReader.UpdateShotReview(shotID, ReviewStatusAIReviewing, ""); err != nil {
		return fmt.Errorf("更新审核状态失败: %w", err)
	}
	_, imageURL, _, err := s.shotReader.GetShot(shotID)
	if err != nil {
		return fmt.Errorf("获取镜头信息失败: %w", err)
	}
	ctx := context.Background()
	approved, comment, err := s.reviewFlowCfg.AIReviewer.ReviewImage(ctx, imageURL, projectID, "")
	if err != nil {
		_ = s.shotReader.UpdateShotReview(shotID, ReviewStatusReview, "AI 审核异常，回退到人工审核")
		return nil
	}
	var aiStatus string
	if approved {
		aiStatus = ReviewStatusAIApproved
	} else {
		aiStatus = ReviewStatusAIRejected
	}
	if err := s.shotReader.UpdateShotReview(shotID, aiStatus, comment); err != nil {
		return fmt.Errorf("更新 AI 审核结果失败: %w", err)
	}
	if s.reviewRecorder != nil {
		s.reviewRecorder.Record(ctx, "shot", shotID, projectID, "ai", "ai", aiStatus, comment, nil)
	}
	return nil
}

// UpdateImageReviewWithFlow 增强版审核接口：支持审核流程配置
// 当配置为 human_and_ai 时，人工审核 ai_approved/ai_rejected 状态的镜头
func (s *Service) UpdateImageReviewWithFlow(shotID, userID string, status, comment string) error {
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

	mode := s.getReviewMode(projectID)

	if mode == "human_and_ai" {
		if reviewStatus == ReviewStatusAIApproved || reviewStatus == ReviewStatusAIRejected {
			if err := s.checkResourceAction(projectID, userID, auth.ResourceShotImage, "review", auth.ActionShotImageReview); err != nil {
				return err
			}
			if err := s.shotReader.UpdateShotReview(shotID, status, comment); err != nil {
				return err
			}
			if s.reviewRecorder != nil {
				s.reviewRecorder.Record(context.Background(), "shot", shotID, projectID, userID, "human", status, comment, nil)
			}
			return nil
		}
	}

	return s.UpdateImageReview(shotID, userID, status, comment)
}
