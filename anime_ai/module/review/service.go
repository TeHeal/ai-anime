package review

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"go.uber.org/zap"
)

// Service 审核业务逻辑
type Service struct {
	store  ReviewStore
	logger *zap.Logger
}

// NewService 创建审核服务
func NewService(store ReviewStore, logger *zap.Logger) *Service {
	return &Service{store: store, logger: logger}
}

// SubmitForReview 提交审核（根据配置决定走 AI/人工/混合）
func (s *Service) SubmitForReview(projectID string, req SubmitReviewRequest) (*ReviewRecord, error) {
	cfg, err := s.store.GetConfig(projectID, req.Phase)
	if err != nil {
		s.logger.Warn("获取审核配置失败，使用默认 AI 模式", zap.String("project_id", projectID), zap.Error(err))
		cfg = &ReviewConfig{Mode: ModeAI}
	}

	// 获取当前轮次
	existing, _ := s.store.ListByTarget(req.TargetType, req.TargetID)
	round := 1
	if len(existing) > 0 {
		round = existing[0].Round + 1
	}

	record := &ReviewRecord{
		ProjectID:  projectID,
		Phase:      req.Phase,
		TargetType: req.TargetType,
		TargetID:   req.TargetID,
		Round:      round,
	}

	switch cfg.Mode {
	case ModeHuman:
		record.ReviewerType = ReviewerHuman
		record.Status = StatusHumanReview
	case ModeAI:
		record.ReviewerType = ReviewerAI
		record.Status = StatusAIReviewing
	case ModeHumanAI:
		record.ReviewerType = ReviewerAI
		record.Status = StatusAIReviewing
	default:
		record.ReviewerType = ReviewerAI
		record.Status = StatusAIReviewing
	}

	created, err := s.store.CreateRecord(record)
	if err != nil {
		s.logger.Error("创建审核记录失败", zap.String("project_id", projectID), zap.Error(err))
		return nil, pkg.NewBizError("创建审核记录失败")
	}
	s.logger.Info("审核已提交",
		zap.String("record_id", created.ID),
		zap.String("phase", req.Phase),
		zap.String("mode", cfg.Mode),
		zap.Int("round", round),
	)
	return created, nil
}

// AIDecide AI 审核决策（由 Worker 或 AI 线调用）
func (s *Service) AIDecide(recordID string, score int, reason string, approved bool) error {
	record, err := s.store.GetRecord(recordID)
	if err != nil {
		s.logger.Error("审核记录不存在", zap.String("record_id", recordID), zap.Error(err))
		return pkg.ErrNotFound
	}
	if record.Status != StatusAIReviewing {
		return &pkg.BizError{Msg: "当前状态不允许 AI 审核，当前状态: " + record.Status}
	}

	// 获取审核配置，判断是否需要人工终审
	cfg, _ := s.store.GetConfig(record.ProjectID, record.Phase)

	var newStatus string
	if approved {
		newStatus = StatusApproved
	} else {
		if cfg != nil && cfg.Mode == ModeHumanAI {
			// 人工+AI 模式：AI 不通过时转人工审核
			newStatus = StatusHumanReview
		} else {
			newStatus = StatusRejected
		}
	}

	if err := s.store.UpdateDecision(recordID, newStatus, &score, reason, ""); err != nil {
		s.logger.Error("更新审核决策失败", zap.String("record_id", recordID), zap.Error(err))
		return pkg.NewBizError("更新审核决策失败")
	}
	s.logger.Info("AI 审核完成", zap.String("record_id", recordID), zap.String("status", newStatus), zap.Int("score", score))
	return nil
}

// HumanDecide 人工审核决策
func (s *Service) HumanDecide(recordID, reviewerID string, req DecideReviewRequest) error {
	record, err := s.store.GetRecord(recordID)
	if err != nil {
		return pkg.ErrNotFound
	}
	if record.Status != StatusHumanReview && record.Status != StatusPending {
		return &pkg.BizError{Msg: "当前状态不允许人工审核，当前状态: " + record.Status}
	}
	if req.Status != StatusApproved && req.Status != StatusRejected {
		return pkg.ErrReviewInvalidStatus
	}

	if err := s.store.UpdateDecision(recordID, req.Status, nil, "", req.Comment); err != nil {
		s.logger.Error("人工审核决策更新失败", zap.String("record_id", recordID), zap.Error(err))
		return pkg.NewBizError("更新审核决策失败")
	}
	s.logger.Info("人工审核完成", zap.String("record_id", recordID), zap.String("reviewer", reviewerID), zap.String("status", req.Status))
	return nil
}

// GetRecord 获取审核记录
func (s *Service) GetRecord(id string) (*ReviewRecord, error) {
	return s.store.GetRecord(id)
}

// ListByTarget 获取目标的审核记录列表
func (s *Service) ListByTarget(targetType, targetID string) ([]*ReviewRecord, error) {
	return s.store.ListByTarget(targetType, targetID)
}

// ListByProject 获取项目审核列表
func (s *Service) ListByProject(projectID string, limit, offset int) ([]*ReviewRecord, error) {
	return s.store.ListByProject(projectID, limit, offset)
}

// CountPending 获取项目待审核数量
func (s *Service) CountPending(projectID string) (int64, error) {
	return s.store.CountPending(projectID)
}

// GetConfig 获取审核配置
func (s *Service) GetConfig(projectID, phase string) (*ReviewConfig, error) {
	return s.store.GetConfig(projectID, phase)
}

// UpdateConfig 更新审核配置
func (s *Service) UpdateConfig(projectID string, req UpdateConfigRequest) (*ReviewConfig, error) {
	if req.Mode != ModeHuman && req.Mode != ModeAI && req.Mode != ModeHumanAI {
		return nil, pkg.ErrReviewInvalidMode
	}
	cfg := &ReviewConfig{
		ProjectID: projectID,
		Phase:     req.Phase,
		Mode:      req.Mode,
		AIModel:   req.AIModel,
		AIPrompt:  req.AIPrompt,
	}
	return s.store.UpsertConfig(cfg)
}

// ListConfigs 获取项目所有审核配置
func (s *Service) ListConfigs(projectID string) ([]*ReviewConfig, error) {
	return s.store.ListConfigs(projectID)
}
