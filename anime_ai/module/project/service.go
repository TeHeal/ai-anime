package project

import (
	"encoding/json"
	"errors"
)

// Service 项目管理业务逻辑层
type Service struct {
	data Data
}

// NewService 创建 Service 实例
func NewService(data Data) *Service {
	return &Service{data: data}
}

// CreateProjectRequest 创建项目请求
type CreateProjectRequest struct {
	Name      string        `json:"name" binding:"required,max=128"`
	Story     string        `json:"story" binding:"max=6000"`
	StoryMode string        `json:"story_mode" binding:"omitempty,oneof=full_script creative"`
	Config    ProjectConfig `json:"config"`
}

// UpdateProjectRequest 更新项目请求（字段可选）
type UpdateProjectRequest struct {
	Name       *string        `json:"name" binding:"omitempty,max=128"`
	Story      *string        `json:"story" binding:"omitempty,max=6000"`
	StoryMode  *string        `json:"story_mode" binding:"omitempty,oneof=full_script creative"`
	Config     *ProjectConfig `json:"config"`
	MirrorMode *bool          `json:"mirror_mode"`
}

// Create 创建项目
func (s *Service) Create(userID string, req CreateProjectRequest) (*Project, error) {
	p := &Project{
		UserIDStr:  userID,
		Name:       req.Name,
		Story:      req.Story,
		StoryMode:  req.StoryMode,
		MirrorMode: true,
	}
	p.SetConfig(req.Config)
	if err := s.data.CreateProject(p); err != nil {
		return nil, err
	}
	return p, nil
}

// GetByID 获取项目详情（需权限）
func (s *Service) GetByID(id, userID string) (*Project, error) {
	return s.data.FindByID(id, userID)
}

// List 获取当前用户的项目列表
func (s *Service) List(userID string) ([]Project, error) {
	return s.data.ListByUser(userID)
}

// Update 更新项目
func (s *Service) Update(id, userID string, req UpdateProjectRequest) (*Project, error) {
	p, err := s.data.FindByID(id, userID)
	if err != nil {
		return nil, err
	}
	if req.Name != nil {
		p.Name = *req.Name
	}
	if req.Story != nil {
		p.Story = *req.Story
	}
	if req.StoryMode != nil {
		p.StoryMode = *req.StoryMode
	}
	if req.Config != nil {
		p.SetConfig(*req.Config)
	}
	if req.MirrorMode != nil {
		p.MirrorMode = *req.MirrorMode
	}
	if err := s.data.UpdateProject(p); err != nil {
		return nil, err
	}
	return p, nil
}

// Delete 删除项目（仅创建者可删）
func (s *Service) Delete(id, userID string) error {
	return s.data.DeleteProject(id, userID)
}

// GetProps 获取项目 props（自定义属性列表）
func (s *Service) GetProps(id, userID string) ([]map[string]interface{}, error) {
	p, err := s.data.FindByID(id, userID)
	if err != nil {
		return nil, err
	}
	if p.PropsJSON == "" {
		return []map[string]interface{}{}, nil
	}
	var props []map[string]interface{}
	if err := json.Unmarshal([]byte(p.PropsJSON), &props); err != nil {
		return nil, err
	}
	return props, nil
}

// UpdateProps 更新项目 props
func (s *Service) UpdateProps(id, userID string, props []map[string]interface{}) error {
	p, err := s.data.FindByID(id, userID)
	if err != nil {
		return err
	}
	data, err := json.Marshal(props)
	if err != nil {
		return err
	}
	p.PropsJSON = string(data)
	return s.data.UpdateProject(p)
}

// AddMemberRequest 添加成员请求
type AddMemberRequest struct {
	UserID   string   `json:"user_id" binding:"required"`
	Role     string   `json:"role" binding:"required,oneof=editor viewer"`
	JobRoles []string `json:"job_roles"` // 工种：director, storyboarder, designer 等，可选
}

// UpdateMemberRoleRequest 更新成员角色请求
type UpdateMemberRoleRequest struct {
	Role string `json:"role" binding:"required,oneof=editor viewer"`
}

// ListMembers 获取项目成员列表（需项目访问权限）
func (s *Service) ListMembers(projectID, userID string) ([]ProjectMember, error) {
	if _, err := s.data.FindByID(projectID, userID); err != nil {
		return nil, err
	}
	return s.data.ListMembersByProject(projectID)
}

// AddMember 添加项目成员（仅项目创建者可添加）
func (s *Service) AddMember(projectID, operatorID string, req AddMemberRequest) (*ProjectMember, error) {
	p, err := s.data.FindByID(projectID, operatorID)
	if err != nil {
		return nil, err
	}
	if p.UserIDStr != operatorID {
		return nil, errors.New("仅项目创建者可添加成员")
	}
	m := &ProjectMember{
		ProjectIDStr: projectID,
		UserIDStr:    req.UserID,
		Role:         req.Role,
		JobRoles:     req.JobRoles,
	}
	if err := s.data.CreateMember(m); err != nil {
		return nil, err
	}
	return m, nil
}

// UpdateMemberRole 更新成员角色（仅项目创建者可操作）
func (s *Service) UpdateMemberRole(projectID, operatorID, memberUserID string, role string) error {
	p, err := s.data.FindByID(projectID, operatorID)
	if err != nil {
		return err
	}
	if p.UserIDStr != operatorID {
		return errors.New("仅项目创建者可修改成员角色")
	}
	return s.data.UpdateMemberRole(projectID, memberUserID, role)
}

// UpdateMemberJobRoles 更新成员工种（仅项目创建者可操作）
func (s *Service) UpdateMemberJobRoles(projectID, operatorID, memberUserID string, jobRoles []string) error {
	p, err := s.data.FindByID(projectID, operatorID)
	if err != nil {
		return err
	}
	if p.UserIDStr != operatorID {
		return errors.New("仅项目创建者可修改成员工种")
	}
	return s.data.UpdateMemberJobRoles(projectID, memberUserID, jobRoles)
}

// RemoveMember 移除项目成员（仅项目创建者可操作）
func (s *Service) RemoveMember(projectID, operatorID, memberUserID string) error {
	p, err := s.data.FindByID(projectID, operatorID)
	if err != nil {
		return err
	}
	if p.UserIDStr != operatorID {
		return errors.New("仅项目创建者可移除成员")
	}
	return s.data.DeleteMember(projectID, memberUserID)
}

// GetReviewConfig 获取项目审核配置（README §2.2 审核方式可配置）
func (s *Service) GetReviewConfig(projectID, userID string) (*ReviewConfig, error) {
	p, err := s.data.FindByID(projectID, userID)
	if err != nil {
		return nil, err
	}
	cfg := p.GetReviewConfig()
	return &cfg, nil
}

// UpdateReviewConfigRequest 更新审核配置请求
type UpdateReviewConfigRequest struct {
	Script    *StageReviewConfig `json:"script"`
	ShotImage *StageReviewConfig `json:"shotImage"`
	ShotVideo *StageReviewConfig `json:"shotVideo"`
}

// UpdateReviewConfig 更新项目审核配置
func (s *Service) UpdateReviewConfig(projectID, userID string, req UpdateReviewConfigRequest) (*ReviewConfig, error) {
	p, err := s.data.FindByID(projectID, userID)
	if err != nil {
		return nil, err
	}
	cfg := p.GetReviewConfig()
	if req.Script != nil {
		if !ValidReviewMode(req.Script.Mode) {
			return nil, errors.New("无效的脚本审核模式")
		}
		cfg.Script = *req.Script
	}
	if req.ShotImage != nil {
		if !ValidReviewMode(req.ShotImage.Mode) {
			return nil, errors.New("无效的镜图审核模式")
		}
		cfg.ShotImage = *req.ShotImage
	}
	if req.ShotVideo != nil {
		if !ValidReviewMode(req.ShotVideo.Mode) {
			return nil, errors.New("无效的镜头审核模式")
		}
		cfg.ShotVideo = *req.ShotVideo
	}
	p.SetReviewConfig(cfg)
	if err := s.data.UpdateProject(p); err != nil {
		return nil, err
	}
	return &cfg, nil
}

// GetReviewConfigByIDOnly 按项目 ID 获取审核配置（供跨模块使用，不需要用户权限校验）
func (s *Service) GetReviewConfigByIDOnly(projectID string) (*ReviewConfig, error) {
	p, err := s.data.FindByIDOnly(projectID)
	if err != nil {
		return nil, err
	}
	cfg := p.GetReviewConfig()
	return &cfg, nil
}

// LockPhase 锁定指定阶段（story/assets/script）
func (s *Service) LockPhase(projectID, userID, phase string) error {
	if _, err := s.data.FindByID(projectID, userID); err != nil {
		return err
	}
	return s.data.UpdateLockPhase(projectID, phase, true)
}

// UnlockPhase 解锁指定阶段
func (s *Service) UnlockPhase(projectID, userID, phase string) error {
	if _, err := s.data.FindByID(projectID, userID); err != nil {
		return err
	}
	return s.data.UpdateLockPhase(projectID, phase, false)
}

// GetLockStatus 获取项目各阶段锁定状态
func (s *Service) GetLockStatus(projectID, userID string) (*LockStatus, error) {
	p, err := s.data.FindByID(projectID, userID)
	if err != nil {
		return nil, err
	}
	return &LockStatus{
		StoryLocked:    p.StoryLocked,
		StoryLockedAt:  p.StoryLockedAt,
		AssetsLocked:   p.AssetsLocked,
		AssetsLockedAt: p.AssetsLockedAt,
		ScriptLocked:   p.ScriptLocked,
		ScriptLockedAt: p.ScriptLockedAt,
	}, nil
}

// IsLocked 检查指定阶段是否已锁定（供 LockChecker 使用，不校验用户权限）
func (s *Service) IsLocked(projectID, phase string) (bool, error) {
	p, err := s.data.FindByIDOnly(projectID)
	if err != nil {
		return false, err
	}
	switch phase {
	case "story":
		return p.StoryLocked, nil
	case "assets":
		return p.AssetsLocked, nil
	case "script":
		return p.ScriptLocked, nil
	default:
		return false, nil
	}
}

// UpdateLockPhase 更新指定阶段锁定状态（供跨模块使用，不校验用户权限）
func (s *Service) UpdateLockPhase(projectID, phase string, locked bool) error {
	return s.data.UpdateLockPhase(projectID, phase, locked)
}

// FindByIDOnly 按项目 ID 获取项目（供跨模块使用，不校验用户权限）
func (s *Service) FindByIDOnly(projectID string) (*Project, error) {
	return s.data.FindByIDOnly(projectID)
}
