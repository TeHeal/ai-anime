package location

import (
	"context"
	"fmt"

	"anime_ai/pub/auth"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
)

// Service 场景资产业务逻辑层
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

// CreateRequest 创建场景请求
type CreateRequest struct {
	Name             string `json:"name" binding:"required"`
	Time             string `json:"time"`
	InteriorExterior string `json:"interior_exterior"`
	Atmosphere       string `json:"atmosphere"`
	ColorTone        string `json:"color_tone"`
	Layout           string `json:"layout"`
	Style            string `json:"style"`
	StyleOverride    bool   `json:"style_override"`
	StyleNote        string `json:"style_note"`
}

// UpdateRequest 更新场景请求
type UpdateRequest struct {
	Name                *string `json:"name"`
	Time                *string `json:"time"`
	InteriorExterior    *string `json:"interior_exterior"`
	Atmosphere          *string `json:"atmosphere"`
	ColorTone           *string `json:"color_tone"`
	Layout              *string `json:"layout"`
	Style               *string `json:"style"`
	StyleOverride       *bool   `json:"style_override"`
	StyleNote           *string `json:"style_note"`
	ImageURL            *string `json:"image_url"`
	ReferenceImagesJSON *string `json:"reference_images_json"`
}

// Create 创建场景
func (s *Service) Create(projectID, userID string, req CreateRequest) (*Location, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	loc := &Location{
		ProjectID:        projectID,
		Name:             req.Name,
		Time:             req.Time,
		InteriorExterior: req.InteriorExterior,
		Atmosphere:       req.Atmosphere,
		ColorTone:        req.ColorTone,
		Layout:           req.Layout,
		Style:            req.Style,
		StyleOverride:    req.StyleOverride,
		StyleNote:        req.StyleNote,
	}
	if err := s.store.Create(loc); err != nil {
		return nil, err
	}
	return loc, nil
}

// CreateSkeleton 创建骨架场景（剧本导入后从场数据提取，status=skeleton）
func (s *Service) CreateSkeleton(projectID, userID, name, timeOfDay, intExt string) (*Location, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	loc := &Location{
		ProjectID:        projectID,
		Name:             name,
		Time:             timeOfDay,
		InteriorExterior: intExt,
		Status:           LocationStatusSkeleton,
		Source:           LocationSourceSkeleton,
	}
	if err := s.store.Create(loc); err != nil {
		return nil, err
	}
	return loc, nil
}

// List 按项目列出场景
func (s *Service) List(projectID, userID string) ([]Location, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.ListByProject(projectID)
}

// ListConfirmedLocationIDs 列出项目内已确认场景的 ID（供跨模块 collector 使用，不校验用户权限）
func (s *Service) ListConfirmedLocationIDs(ctx context.Context, projectID string) ([]string, error) {
	_ = ctx // 预留，Store 层当前无 context
	locs, err := s.store.ListByProject(projectID)
	if err != nil {
		return nil, err
	}
	var ids []string
	for _, loc := range locs {
		if loc.Status == "confirmed" && loc.ID != "" {
			ids = append(ids, loc.ID)
		}
	}
	return ids, nil
}

// Get 获取场景详情
func (s *Service) Get(locID, projectID, userID string) (*Location, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.store.GetByID(locID, projectID)
}

// Update 更新场景
func (s *Service) Update(locID, projectID, userID string, req UpdateRequest) (*Location, error) {
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	if s.frozenAssetChecker != nil {
		inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(projectID, "location", locID)
		if err == nil && inFrozen {
			return nil, fmt.Errorf("%w: assets 阶段已锁定，该场景已纳入版本，无法修改", pkg.ErrPhaseLocked)
		}
	}
	loc, err := s.Get(locID, projectID, userID)
	if err != nil {
		return nil, err
	}
	if req.Name != nil {
		loc.Name = *req.Name
	}
	if req.Time != nil {
		loc.Time = *req.Time
	}
	if req.InteriorExterior != nil {
		loc.InteriorExterior = *req.InteriorExterior
	}
	if req.Atmosphere != nil {
		loc.Atmosphere = *req.Atmosphere
	}
	if req.ColorTone != nil {
		loc.ColorTone = *req.ColorTone
	}
	if req.Layout != nil {
		loc.Layout = *req.Layout
	}
	if req.Style != nil {
		loc.Style = *req.Style
	}
	if req.StyleOverride != nil {
		loc.StyleOverride = *req.StyleOverride
	}
	if req.StyleNote != nil {
		loc.StyleNote = *req.StyleNote
	}
	if req.ImageURL != nil {
		loc.ImageURL = *req.ImageURL
		if *req.ImageURL != "" {
			loc.ImageStatus = "completed"
		}
	}
	if req.ReferenceImagesJSON != nil {
		loc.ReferenceImagesJSON = *req.ReferenceImagesJSON
	}
	if err := s.store.Update(loc); err != nil {
		return nil, err
	}
	return loc, nil
}

// Confirm 确认场景
func (s *Service) Confirm(locID, projectID, userID string) (*Location, error) {
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	if s.frozenAssetChecker != nil {
		inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(projectID, "location", locID)
		if err == nil && inFrozen {
			return nil, fmt.Errorf("%w: assets 阶段已锁定，该场景已纳入版本，无法确认", pkg.ErrPhaseLocked)
		}
	}
	loc, err := s.Get(locID, projectID, userID)
	if err != nil {
		return nil, err
	}
	loc.Status = "confirmed"
	if err := s.store.Update(loc); err != nil {
		return nil, err
	}
	return loc, nil
}

// Delete 删除场景
func (s *Service) Delete(locID, projectID, userID string) error {
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return err
	}
	if s.frozenAssetChecker != nil {
		inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(projectID, "location", locID)
		if err == nil && inFrozen {
			return fmt.Errorf("%w: assets 阶段已锁定，该场景已纳入版本，无法删除", pkg.ErrPhaseLocked)
		}
	}
	if _, err := s.Get(locID, projectID, userID); err != nil {
		return err
	}
	return s.store.Delete(locID, projectID)
}

// GenerateImage 触发场景图生成（占位，后续接入 Worker）
func (s *Service) GenerateImage(locID, projectID, userID, provider, model string) (*Location, error) {
	if err := s.checkAssetEdit(projectID, userID); err != nil {
		return nil, err
	}
	loc, err := s.Get(locID, projectID, userID)
	if err != nil {
		return nil, err
	}
	// 占位：仅更新状态为 generating，实际任务入队由 Worker 实现
	_ = provider
	_ = model
	if err := s.store.UpdateImage(locID, projectID, "", "pending", "generating"); err != nil {
		return nil, err
	}
	loc.ImageStatus = "generating"
	loc.TaskID = "pending"
	return loc, nil
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
