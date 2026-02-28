package prop

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
)

// Service 道具资产业务逻辑层
type Service struct {
	store           Store
	projectVerifier crossmodule.ProjectVerifier
}

// NewService 创建 Service 实例
func NewService(store Store, projectVerifier crossmodule.ProjectVerifier) *Service {
	return &Service{
		store:           store,
		projectVerifier: projectVerifier,
	}
}

// CreateRequest 创建道具请求
type CreateRequest struct {
	Name       string `json:"name" binding:"required"`
	Appearance string `json:"appearance"`
	IsKeyProp  bool   `json:"is_key_prop"`
	Style      string `json:"style"`
	ImageURL   string `json:"image_url"`
}

// UpdateRequest 更新道具请求
type UpdateRequest struct {
	Name                *string `json:"name"`
	Appearance          *string `json:"appearance"`
	IsKeyProp           *bool   `json:"is_key_prop"`
	Style               *string `json:"style"`
	StyleOverride       *bool   `json:"style_override"`
	ReferenceImagesJSON *string `json:"reference_images_json"`
	ImageURL            *string `json:"image_url"`
	UsedByJSON          *string `json:"used_by_json"`
	ScenesJSON          *string `json:"scenes_json"`
	Status              *string `json:"status"`
	Source              *string `json:"source"`
}

// Create 创建道具
func (s *Service) Create(projectID, userID string, req CreateRequest) (*Prop, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	p := &Prop{
		ProjectID:  projectID,
		Name:       req.Name,
		Appearance: req.Appearance,
		IsKeyProp:  req.IsKeyProp,
		Style:      req.Style,
		ImageURL:   req.ImageURL,
	}
	if err := s.store.Create(p); err != nil {
		return nil, err
	}
	return p, nil
}

// List 按项目列出道具
func (s *Service) List(projectID, userID string) ([]Prop, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByProject(projectID)
}

// Get 获取道具详情
func (s *Service) Get(propID, projectID, userID string) (*Prop, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.GetByID(propID, projectID)
}

// Update 更新道具
func (s *Service) Update(propID, projectID, userID string, req UpdateRequest) (*Prop, error) {
	p, err := s.Get(propID, projectID, userID)
	if err != nil {
		return nil, err
	}
	if req.Name != nil {
		p.Name = *req.Name
	}
	if req.Appearance != nil {
		p.Appearance = *req.Appearance
	}
	if req.IsKeyProp != nil {
		p.IsKeyProp = *req.IsKeyProp
	}
	if req.Style != nil {
		p.Style = *req.Style
	}
	if req.StyleOverride != nil {
		p.StyleOverride = *req.StyleOverride
	}
	if req.ReferenceImagesJSON != nil {
		p.ReferenceImagesJSON = *req.ReferenceImagesJSON
	}
	if req.ImageURL != nil {
		p.ImageURL = *req.ImageURL
	}
	if req.UsedByJSON != nil {
		p.UsedByJSON = *req.UsedByJSON
	}
	if req.ScenesJSON != nil {
		p.ScenesJSON = *req.ScenesJSON
	}
	if req.Status != nil {
		p.Status = *req.Status
	}
	if req.Source != nil {
		p.Source = *req.Source
	}
	if err := s.store.Update(p); err != nil {
		return nil, err
	}
	return p, nil
}

// Confirm 确认道具
func (s *Service) Confirm(propID, projectID, userID string) (*Prop, error) {
	p, err := s.Get(propID, projectID, userID)
	if err != nil {
		return nil, err
	}
	p.Status = "confirmed"
	if err := s.store.Update(p); err != nil {
		return nil, err
	}
	return p, nil
}

// Delete 删除道具
func (s *Service) Delete(propID, projectID, userID string) error {
	if _, err := s.Get(propID, projectID, userID); err != nil {
		return err
	}
	return s.store.Delete(propID, projectID)
}
