package style

import (
	"fmt"

	"anime_ai/pub/auth"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
)

// Service 风格业务逻辑层
type Service struct {
	data           Data
	projectVerifier crossmodule.ProjectVerifier
	memberResolver  crossmodule.ProjectMemberResolver
}

// NewService 创建 Service 实例
func NewService(data Data, projectVerifier crossmodule.ProjectVerifier) *Service {
	return NewServiceWithResolver(data, projectVerifier, nil)
}

// NewServiceWithResolver 创建 Service 实例（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(data Data, projectVerifier crossmodule.ProjectVerifier, memberResolver crossmodule.ProjectMemberResolver) *Service {
	return &Service{
		data:           data,
		projectVerifier: projectVerifier,
		memberResolver:  memberResolver,
	}
}

func (s *Service) checkAssetEdit(projectID, userID string) error {
	if s.memberResolver == nil {
		return nil
	}
	info, err := s.memberResolver.Resolve(projectID, userID)
	if err != nil {
		return err
	}
	if info.IsOwner {
		return nil
	}
	if !auth.CanDo(info.JobRoles, auth.ActionAssetEdit) {
		return fmt.Errorf("%w: 当前工种不允许编辑资产", pkg.ErrForbidden)
	}
	return nil
}

// List 按项目列出风格
func (s *Service) List(projectID, userID string) ([]*Style, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.data.ListByProject(projectID)
}

// Create 创建风格
func (s *Service) Create(projectID, userID string, req CreateRequest) (*Style, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	st := &Style{
		ProjectID:           projectID,
		Name:                req.Name,
		Description:         req.Description,
		NegativePrompt:      req.NegativePrompt,
		ReferenceImagesJSON: req.ReferenceImages,
		ThumbnailURL:        req.ThumbnailURL,
		IsPreset:            false,
		IsProjectDefault:    req.IsProjectDefault,
	}
	if req.ReferenceImages == "" {
		st.ReferenceImagesJSON = "[]"
	}
	if req.IsProjectDefault {
		_ = s.data.ClearProjectDefault(projectID)
	}
	if err := s.data.Create(st); err != nil {
		return nil, err
	}
	return st, nil
}

// Get 获取风格详情
func (s *Service) Get(styleID, projectID, userID string) (*Style, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.data.GetByID(styleID, projectID)
}

// Update 更新风格
func (s *Service) Update(styleID, projectID, userID string, req UpdateRequest) (*Style, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	st, err := s.data.GetByID(styleID, projectID)
	if err != nil {
		return nil, err
	}
	if st.IsPreset {
		return nil, fmt.Errorf("预设风格不可修改")
	}
	if req.Name != nil {
		st.Name = *req.Name
	}
	if req.Description != nil {
		st.Description = *req.Description
	}
	if req.NegativePrompt != nil {
		st.NegativePrompt = *req.NegativePrompt
	}
	if req.ReferenceImages != nil {
		st.ReferenceImagesJSON = *req.ReferenceImages
	}
	if req.ThumbnailURL != nil {
		st.ThumbnailURL = *req.ThumbnailURL
	}
	if req.IsProjectDefault != nil && *req.IsProjectDefault {
		_ = s.data.ClearProjectDefault(projectID)
		st.IsProjectDefault = true
		_ = s.data.SetProjectDefault(st.ID, projectID)
	}
	if err := s.data.Update(st); err != nil {
		return nil, err
	}
	return st, nil
}

// Delete 删除风格
func (s *Service) Delete(styleID, projectID, userID string) error {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return err
	}
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return err
	}
	st, err := s.data.GetByID(styleID, projectID)
	if err != nil {
		return err
	}
	if st.IsPreset {
		return fmt.Errorf("预设风格不可删除")
	}
	return s.data.Delete(styleID, projectID)
}

// ApplyAll 将风格应用到项目内所有角色、场景、道具
func (s *Service) ApplyAll(styleID, projectID, userID string) (int, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return 0, err
	}
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return 0, err
	}
	st, err := s.data.GetByID(styleID, projectID)
	if err != nil {
		return 0, err
	}
	return s.data.ApplyAll(styleID, projectID, st.Name)
}
