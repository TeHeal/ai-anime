package review

import "errors"

// Service 审核业务逻辑
type Service struct {
	store ReviewStore
}

// NewService 创建审核服务
func NewService(store ReviewStore) *Service {
	return &Service{store: store}
}

// SubmitForReview 提交审核（根据配置决定走 AI/人工/混合）
func (s *Service) SubmitForReview(projectID string, req SubmitReviewRequest) (*ReviewRecord, error) {
	cfg, err := s.store.GetConfig(projectID, req.Phase)
	if err != nil {
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

	return s.store.CreateRecord(record)
}

// AIDecide AI 审核决策（由 Worker 或 AI 线调用）
func (s *Service) AIDecide(recordID string, score int, reason string, approved bool) error {
	record, err := s.store.GetRecord(recordID)
	if err != nil {
		return err
	}
	if record.Status != StatusAIReviewing {
		return errors.New("当前状态不允许 AI 审核")
	}

	// 获取审核配置，判断是否需要人工终审
	cfg, _ := s.store.GetConfig(record.ProjectID, record.Phase)

	var newStatus string
	if approved {
		if cfg != nil && cfg.Mode == ModeHumanAI {
			newStatus = StatusAIApproved
		} else {
			newStatus = StatusApproved
		}
	} else {
		if cfg != nil && cfg.Mode == ModeHumanAI {
			newStatus = StatusAIRejected
		} else {
			newStatus = StatusRejected
		}
	}

	// 人工+AI 模式：AI 不通过时转人工审核
	if newStatus == StatusAIRejected {
		newStatus = StatusHumanReview
	}
	if newStatus == StatusAIApproved {
		newStatus = StatusApproved
	}

	return s.store.UpdateDecision(recordID, newStatus, &score, reason, "")
}

// HumanDecide 人工审核决策
func (s *Service) HumanDecide(recordID, reviewerID string, req DecideReviewRequest) error {
	record, err := s.store.GetRecord(recordID)
	if err != nil {
		return err
	}
	if record.Status != StatusHumanReview && record.Status != StatusPending {
		return errors.New("当前状态不允许人工审核")
	}

	status := req.Status
	if status != StatusApproved && status != StatusRejected {
		return errors.New("无效的审核状态，仅支持 approved/rejected")
	}

	return s.store.UpdateDecision(recordID, status, nil, "", req.Comment)
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
		return nil, errors.New("无效的审核方式，仅支持 human/ai/human_ai")
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
