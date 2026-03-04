package team

import (
	"context"
	"fmt"

	"anime_ai/pub/pkg"
)

// Service 团队业务逻辑层
type Service struct {
	data    Data
	orgData OrgChecker
}

// OrgChecker 校验组织成员权限（由 organization 模块实现注入）
type OrgChecker interface {
	IsOrgAdminOrOwner(ctx context.Context, orgID, userID string) bool
	IsOrgMember(ctx context.Context, orgID, userID string) bool
}

func NewService(data Data, orgData OrgChecker) *Service {
	return &Service{data: data, orgData: orgData}
}

// CreateTeam 创建团队（需组织管理员权限）
func (s *Service) CreateTeam(ctx context.Context, orgID, userID, name, description string) (*Team, error) {
	if name == "" {
		return nil, fmt.Errorf("%w: 团队名称不能为空", pkg.ErrBadRequest)
	}
	if !s.orgData.IsOrgAdminOrOwner(ctx, orgID, userID) {
		return nil, fmt.Errorf("%w: 仅组织管理员可创建团队", pkg.ErrForbidden)
	}
	return s.data.CreateTeam(ctx, orgID, name, description)
}

// GetTeam 获取团队详情（需组织成员权限）
func (s *Service) GetTeam(ctx context.Context, orgID, teamID, userID string) (*Team, error) {
	if !s.orgData.IsOrgMember(ctx, orgID, userID) {
		return nil, fmt.Errorf("%w: 无权访问该组织", pkg.ErrForbidden)
	}
	return s.data.GetTeamByID(ctx, teamID)
}

// ListTeams 列出组织下团队（需组织成员权限）
func (s *Service) ListTeams(ctx context.Context, orgID, userID string) ([]Team, error) {
	if !s.orgData.IsOrgMember(ctx, orgID, userID) {
		return nil, fmt.Errorf("%w: 无权访问该组织", pkg.ErrForbidden)
	}
	return s.data.ListTeamsByOrg(ctx, orgID)
}

// UpdateTeam 更新团队信息（需组织管理员权限）
func (s *Service) UpdateTeam(ctx context.Context, orgID, teamID, userID string, name, description *string) (*Team, error) {
	if !s.orgData.IsOrgAdminOrOwner(ctx, orgID, userID) {
		return nil, fmt.Errorf("%w: 仅组织管理员可修改团队", pkg.ErrForbidden)
	}
	return s.data.UpdateTeam(ctx, teamID, name, description)
}

// DeleteTeam 删除团队（需组织管理员权限）
func (s *Service) DeleteTeam(ctx context.Context, orgID, teamID, userID string) error {
	if !s.orgData.IsOrgAdminOrOwner(ctx, orgID, userID) {
		return fmt.Errorf("%w: 仅组织管理员可删除团队", pkg.ErrForbidden)
	}
	return s.data.DeleteTeam(ctx, teamID)
}

// AddMember 添加团队成员（需组织管理员权限）
func (s *Service) AddMember(ctx context.Context, orgID, teamID, operatorID, targetUserID, role string, jobRoles []string) (*TeamMember, error) {
	if !s.orgData.IsOrgAdminOrOwner(ctx, orgID, operatorID) {
		return nil, fmt.Errorf("%w: 仅组织管理员可管理团队成员", pkg.ErrForbidden)
	}
	existing, _ := s.data.GetMember(ctx, teamID, targetUserID)
	if existing != nil {
		return nil, fmt.Errorf("%w: 该用户已是团队成员", pkg.ErrAlreadyExists)
	}
	if role == "" {
		role = "viewer"
	}
	return s.data.AddMember(ctx, teamID, targetUserID, role, jobRoles)
}

// ListMembers 列出团队成员（需组织成员权限）
func (s *Service) ListMembers(ctx context.Context, orgID, teamID, userID string) ([]TeamMember, error) {
	if !s.orgData.IsOrgMember(ctx, orgID, userID) {
		return nil, fmt.Errorf("%w: 无权访问该组织", pkg.ErrForbidden)
	}
	return s.data.ListMembers(ctx, teamID)
}

// UpdateMember 更新团队成员角色/工种（需组织管理员权限）
func (s *Service) UpdateMember(ctx context.Context, orgID, teamID, operatorID, targetUserID string, role *string, jobRoles []string) (*TeamMember, error) {
	if !s.orgData.IsOrgAdminOrOwner(ctx, orgID, operatorID) {
		return nil, fmt.Errorf("%w: 仅组织管理员可修改成员", pkg.ErrForbidden)
	}
	return s.data.UpdateMember(ctx, teamID, targetUserID, role, jobRoles)
}

// RemoveMember 移除团队成员（需组织管理员权限）
func (s *Service) RemoveMember(ctx context.Context, orgID, teamID, operatorID, targetUserID string) error {
	if !s.orgData.IsOrgAdminOrOwner(ctx, orgID, operatorID) {
		return fmt.Errorf("%w: 仅组织管理员可移除成员", pkg.ErrForbidden)
	}
	return s.data.RemoveMember(ctx, teamID, targetUserID)
}
