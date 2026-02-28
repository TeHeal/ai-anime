package review

import (
	"fmt"
	"sync"
)

// ReviewStore 审核数据访问接口
type ReviewStore interface {
	CreateRecord(record *ReviewRecord) (*ReviewRecord, error)
	GetRecord(id string) (*ReviewRecord, error)
	ListByTarget(targetType, targetID string) ([]*ReviewRecord, error)
	ListByProject(projectID string, limit, offset int) ([]*ReviewRecord, error)
	UpdateDecision(id, status string, aiScore *int, aiReason, humanComment string) error
	CountPending(projectID string) (int64, error)

	GetConfig(projectID, phase string) (*ReviewConfig, error)
	UpsertConfig(cfg *ReviewConfig) (*ReviewConfig, error)
	ListConfigs(projectID string) ([]*ReviewConfig, error)
}

// MemReviewStore 内存实现，用于无 DB 开发
type MemReviewStore struct {
	mu       sync.RWMutex
	records  []*ReviewRecord
	configs  map[string]*ReviewConfig // key: projectID+phase
	nextID   int
}

// NewMemReviewStore 创建内存审核存储
func NewMemReviewStore() *MemReviewStore {
	return &MemReviewStore{
		configs: make(map[string]*ReviewConfig),
		nextID:  1,
	}
}

// CreateRecord 创建审核记录
func (s *MemReviewStore) CreateRecord(r *ReviewRecord) (*ReviewRecord, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	r.ID = memID(s.nextID)
	s.nextID++
	cp := *r
	s.records = append(s.records, &cp)
	return &cp, nil
}

// GetRecord 根据 ID 获取审核记录
func (s *MemReviewStore) GetRecord(id string) (*ReviewRecord, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, r := range s.records {
		if r.ID == id {
			cp := *r
			return &cp, nil
		}
	}
	return nil, errNotFound
}

// ListByTarget 按目标类型和目标 ID 查询审核记录列表
func (s *MemReviewStore) ListByTarget(targetType, targetID string) ([]*ReviewRecord, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var result []*ReviewRecord
	for _, r := range s.records {
		if r.TargetType == targetType && r.TargetID == targetID {
			cp := *r
			result = append(result, &cp)
		}
	}
	return result, nil
}

// ListByProject 按项目 ID 分页查询审核记录
func (s *MemReviewStore) ListByProject(projectID string, limit, offset int) ([]*ReviewRecord, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var filtered []*ReviewRecord
	for _, r := range s.records {
		if r.ProjectID == projectID {
			cp := *r
			filtered = append(filtered, &cp)
		}
	}
	if offset >= len(filtered) {
		return nil, nil
	}
	end := offset + limit
	if end > len(filtered) {
		end = len(filtered)
	}
	return filtered[offset:end], nil
}

// UpdateDecision 更新审核决策（状态、AI 评分、AI 理由、人工备注）
func (s *MemReviewStore) UpdateDecision(id, status string, aiScore *int, aiReason, humanComment string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, r := range s.records {
		if r.ID == id {
			r.Status = status
			r.AIScore = aiScore
			r.AIReason = aiReason
			r.HumanComment = humanComment
			return nil
		}
	}
	return errNotFound
}

// CountPending 统计指定项目的待审核记录数量
func (s *MemReviewStore) CountPending(projectID string) (int64, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var count int64
	for _, r := range s.records {
		if r.ProjectID == projectID && r.Status == StatusPending {
			count++
		}
	}
	return count, nil
}

// GetConfig 获取指定项目和阶段的审核配置，不存在则返回默认配置
func (s *MemReviewStore) GetConfig(projectID, phase string) (*ReviewConfig, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	key := projectID + ":" + phase
	if c, ok := s.configs[key]; ok {
		cp := *c
		return &cp, nil
	}
	// 返回默认配置（AI 审核）
	return &ReviewConfig{ProjectID: projectID, Phase: phase, Mode: ModeAI}, nil
}

// UpsertConfig 创建或更新审核配置
func (s *MemReviewStore) UpsertConfig(cfg *ReviewConfig) (*ReviewConfig, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	key := cfg.ProjectID + ":" + cfg.Phase
	if cfg.ID == "" {
		cfg.ID = memID(s.nextID)
		s.nextID++
	}
	cp := *cfg
	s.configs[key] = &cp
	return &cp, nil
}

// ListConfigs 列出指定项目的所有审核配置
func (s *MemReviewStore) ListConfigs(projectID string) ([]*ReviewConfig, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var result []*ReviewConfig
	for _, c := range s.configs {
		if c.ProjectID == projectID {
			cp := *c
			result = append(result, &cp)
		}
	}
	return result, nil
}

func memID(n int) string {
	return fmt.Sprintf("%d", n)
}

var errNotFound = fmt.Errorf("not found")
