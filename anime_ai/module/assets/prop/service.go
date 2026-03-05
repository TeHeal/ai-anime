package prop

import (
	"context"
	"fmt"

	"anime_ai/pub/auth"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
)

// Service 道具资产业务逻辑层
type Service struct {
	store              Store
	projectVerifier    crossmodule.ProjectVerifier
	memberResolver     crossmodule.ProjectMemberResolver
	frozenAssetChecker crossmodule.FrozenAssetChecker
}

// NewService 创建 Service 实例
func NewService(store Store, projectVerifier crossmodule.ProjectVerifier) *Service {
	return NewServiceWithResolver(store, projectVerifier, nil)
}

// NewServiceWithResolver 创建 Service 实例（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(store Store, projectVerifier crossmodule.ProjectVerifier, memberResolver crossmodule.ProjectMemberResolver) *Service {
	return &Service{
		store:           store,
		projectVerifier: projectVerifier,
		memberResolver:  memberResolver,
	}
}

// SetFrozenAssetChecker 注入资产冻结检查器
func (s *Service) SetFrozenAssetChecker(c crossmodule.FrozenAssetChecker) {
	s.frozenAssetChecker = c
}

// CreateRequest 创建道具请求（camelCase 以兼容 Flutter）
type CreateRequest struct {
	Name       string `json:"name" binding:"required"`
	Appearance string `json:"appearance"`
	IsKeyProp  bool   `json:"isKeyProp"`
	Style      string `json:"style"`
	ImageURL   string `json:"imageUrl"`
}

// UpdateRequest 更新道具请求（camelCase）
type UpdateRequest struct {
	Name                *string `json:"name"`
	Appearance          *string `json:"appearance"`
	IsKeyProp           *bool   `json:"isKeyProp"`
	Style               *string `json:"style"`
	StyleOverride       *bool   `json:"styleOverride"`
	ReferenceImagesJSON *string `json:"referenceImagesJson"`
	ImageURL            *string `json:"imageUrl"`
	UsedByJSON          *string `json:"usedByJson"`
	ScenesJSON          *string `json:"scenesJson"`
	Status              *string `json:"status"`
	Source              *string `json:"source"`
}

// Create 创建道具
func (s *Service) Create(projectID, userID string, req CreateRequest) (*Prop, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAssetEdit(projectID, userID); err != nil {
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

// ListConfirmedPropIDs 列出项目内已确认道具的 ID（供跨模块 collector 使用，不校验用户权限）
func (s *Service) ListConfirmedPropIDs(ctx context.Context, projectID string) ([]string, error) {
	_ = ctx // 预留，Store 层当前无 context
	props, err := s.store.ListByProject(projectID)
	if err != nil {
		return nil, err
	}
	var ids []string
	for _, p := range props {
		if p.Status == "confirmed" && p.ID != "" {
			ids = append(ids, p.ID)
		}
	}
	return ids, nil
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
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	if s.frozenAssetChecker != nil {
		inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(projectID, "prop", propID)
		if err == nil && inFrozen {
			return nil, fmt.Errorf("%w: assets 阶段已锁定，该道具已纳入版本，无法修改", pkg.ErrPhaseLocked)
		}
	}
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
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	if s.frozenAssetChecker != nil {
		inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(projectID, "prop", propID)
		if err == nil && inFrozen {
			return nil, fmt.Errorf("%w: assets 阶段已锁定，该道具已纳入版本，无法确认", pkg.ErrPhaseLocked)
		}
	}
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
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return err
	}
	if s.frozenAssetChecker != nil {
		inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(projectID, "prop", propID)
		if err == nil && inFrozen {
			return fmt.Errorf("%w: assets 阶段已锁定，该道具已纳入版本，无法删除", pkg.ErrPhaseLocked)
		}
	}
	if _, err := s.Get(propID, projectID, userID); err != nil {
		return err
	}
	return s.store.Delete(propID, projectID)
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
