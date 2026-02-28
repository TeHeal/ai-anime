package style

import "errors"

// Service 风格业务逻辑
type Service struct {
	store Store
}

// NewService 创建风格服务
func NewService(store Store) *Service {
	return &Service{store: store}
}

// CreateStyleRequest 创建请求
type CreateStyleRequest struct {
	Name           string `json:"name" binding:"required"`
	Description    string `json:"description"`
	Category       string `json:"category"`
	PreviewURL     string `json:"preview_url"`
	PromptTemplate string `json:"prompt_template"`
	NegativePrompt string `json:"negative_prompt"`
}

// UpdateStyleRequest 更新请求
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
	style := &Style{
		ProjectID:      projectID,
		Name:           req.Name,
		Description:    req.Description,
		Category:       req.Category,
		PreviewURL:     req.PreviewURL,
		PromptTemplate: req.PromptTemplate,
		NegativePrompt: req.NegativePrompt,
		Status:         "draft",
	}
	return s.store.Create(style)
}

// List 列出项目风格
func (s *Service) List(projectID string) ([]*Style, error) {
	return s.store.ListByProject(projectID)
}

// Get 获取风格
func (s *Service) Get(id string) (*Style, error) {
	return s.store.Get(id)
}

// Update 更新风格
func (s *Service) Update(id string, req UpdateStyleRequest) (*Style, error) {
	style, err := s.store.Get(id)
	if err != nil {
		return nil, errors.New("风格不存在")
	}
	if req.Name != "" {
		style.Name = req.Name
	}
	if req.Description != "" {
		style.Description = req.Description
	}
	if req.Category != "" {
		style.Category = req.Category
	}
	if req.PreviewURL != "" {
		style.PreviewURL = req.PreviewURL
	}
	if req.PromptTemplate != "" {
		style.PromptTemplate = req.PromptTemplate
	}
	if req.NegativePrompt != "" {
		style.NegativePrompt = req.NegativePrompt
	}
	if req.Status != "" {
		style.Status = req.Status
	}
	return style, s.store.Update(style)
}

// Delete 删除风格
func (s *Service) Delete(id string) error {
	return s.store.Delete(id)
}
