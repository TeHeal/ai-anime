package episode

import (
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

func episodeProjectID(ep *Episode) string {
	if ep.ProjectIDStr != "" {
		return ep.ProjectIDStr
	}
	return strconv.FormatUint(uint64(ep.ProjectID), 10)
}

// DummyProjectVerifier 占位实现，始终通过验证
type DummyProjectVerifier struct{}

func (DummyProjectVerifier) Verify(projectID, userID string) error { return nil }

// Service 集业务逻辑层
type Service struct {
	store    EpisodeStore
	verifier crossmodule.ProjectVerifier
}

// NewService 创建集服务
func NewService(store EpisodeStore, verifier crossmodule.ProjectVerifier) *Service {
	if verifier == nil {
		verifier = DummyProjectVerifier{}
	}
	return &Service{store: store, verifier: verifier}
}

// CreateEpisodeRequest 创建集请求
type CreateEpisodeRequest struct {
	Title   string `json:"title" binding:"max=128"`
	Summary string `json:"summary"`
}

// UpdateEpisodeRequest 更新集请求
type UpdateEpisodeRequest struct {
	Title       *string `json:"title" binding:"omitempty,max=128"`
	Summary     *string `json:"summary"`
	SortIndex   *int    `json:"sort_index"`
	Status      *string `json:"status"`
	CurrentStep *int    `json:"current_step"`
}

// ReorderEpisodesRequest 排序请求
type ReorderEpisodesRequest struct {
	OrderedIDs []string `json:"ordered_ids" binding:"required"`
}

// Create 创建集
func (s *Service) Create(projectID, userID string, req CreateEpisodeRequest) (*Episode, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	count, _ := s.store.CountByProject(projectID)
	ep := &Episode{
		ProjectIDStr: projectID,
		Title:        req.Title,
		Summary:      req.Summary,
		SortIndex:    int(count),
	}
	if err := s.store.Create(ep); err != nil {
		return nil, err
	}
	return ep, nil
}

// Get 获取集
func (s *Service) Get(id, projectID, userID string) (*Episode, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	ep, err := s.store.FindByID(id)
	if err != nil {
		return nil, err
	}
	if episodeProjectID(ep) != projectID {
		return nil, pkg.ErrNotFound
	}
	return ep, nil
}

// ListByProject 按项目列出集
func (s *Service) ListByProject(projectID, userID string) ([]Episode, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByProject(projectID)
}

// Update 更新集
func (s *Service) Update(id, projectID, userID string, req UpdateEpisodeRequest) (*Episode, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	ep, err := s.store.FindByID(id)
	if err != nil {
		return nil, err
	}
	if episodeProjectID(ep) != projectID {
		return nil, pkg.ErrNotFound
	}
	if req.Title != nil {
		ep.Title = *req.Title
	}
	if req.Summary != nil {
		ep.Summary = *req.Summary
	}
	if req.SortIndex != nil {
		ep.SortIndex = *req.SortIndex
	}
	if req.Status != nil {
		ep.Status = *req.Status
	}
	if req.CurrentStep != nil {
		ep.CurrentStep = *req.CurrentStep
	}
	if err := s.store.Update(ep); err != nil {
		return nil, err
	}
	return ep, nil
}

// Delete 删除集
func (s *Service) Delete(id, projectID, userID string) error {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return err
	}
	ep, err := s.store.FindByID(id)
	if err != nil {
		return err
	}
	if episodeProjectID(ep) != projectID {
		return pkg.ErrNotFound
	}
	return s.store.Delete(id)
}

// Reorder 排序集
func (s *Service) Reorder(projectID, userID string, req ReorderEpisodesRequest) error {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return err
	}
	return s.store.ReorderByProject(projectID, req.OrderedIDs)
}
