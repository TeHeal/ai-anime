package style

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"go.uber.org/zap"
)

// Service 风格资产业务逻辑
type Service struct {
	store  Store
	logger *zap.Logger
}

// NewService 创建风格服务
func NewService(store Store, logger *zap.Logger) *Service {
	return &Service{store: store, logger: logger}
}

// CreateStyleRequest 创建风格请求
type CreateStyleRequest struct {
	Name           string `json:"name" binding:"required"`
	Description    string `json:"description"`
	Category       string `json:"category"`
	PreviewURL     string `json:"preview_url"`
	PromptTemplate string `json:"prompt_template"`
	NegativePrompt string `json:"negative_prompt"`
}

// UpdateStyleRequest 更新风格请求
type UpdateStyleRequest struct {
	Name           string `json:"name"`
	Description    string `json:"description"`
	Category       string `json:"category"`
	PreviewURL     string `json:"preview_url"`
	PromptTemplate string `json:"prompt_template"`
	NegativePrompt string `json:"negative_prompt"`
	Status         string `json:"status"`
}

// Create 创建风格
func (s *Service) Create(projectID string, req CreateStyleRequest) (*Style, error) {
	st := &Style{
		ProjectID:      projectID,
		Name:           req.Name,
		Description:    req.Description,
		Category:       req.Category,
		PreviewURL:     req.PreviewURL,
		PromptTemplate: req.PromptTemplate,
		NegativePrompt: req.NegativePrompt,
		Status:         "draft",
	}
	created, err := s.store.Create(st)
	if err != nil {
		s.logger.Error("创建风格失败", zap.String("project_id", projectID), zap.Error(err))
		return nil, pkg.NewBizError("创建风格失败")
	}
	return created, nil
}

// List 列出项目风格
func (s *Service) List(projectID string) ([]*Style, error) {
	return s.store.ListByProject(projectID)
}

// Get 获取风格详情
func (s *Service) Get(id string) (*Style, error) {
	st, err := s.store.Get(id)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return st, nil
}

// Update 更新风格
func (s *Service) Update(id string, req UpdateStyleRequest) (*Style, error) {
	st, err := s.store.Get(id)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	if req.Name != "" {
		st.Name = req.Name
	}
	if req.Description != "" {
		st.Description = req.Description
	}
	if req.Category != "" {
		st.Category = req.Category
	}
	if req.PreviewURL != "" {
		st.PreviewURL = req.PreviewURL
	}
	if req.PromptTemplate != "" {
		st.PromptTemplate = req.PromptTemplate
	}
	if req.NegativePrompt != "" {
		st.NegativePrompt = req.NegativePrompt
	}
	if req.Status != "" {
		st.Status = req.Status
	}
	if err := s.store.Update(st); err != nil {
		s.logger.Error("更新风格失败", zap.String("id", id), zap.Error(err))
		return nil, pkg.NewBizError("更新风格失败")
	}
	return st, nil
}

// Delete 删除风格
func (s *Service) Delete(id string) error {
	if err := s.store.Delete(id); err != nil {
		return pkg.ErrNotFound
	}
	return nil
}
