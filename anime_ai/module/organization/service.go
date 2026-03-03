package organization

import (
	"context"
	"fmt"

	"anime_ai/pub/pkg"
)

// Service 组织业务逻辑层
type Service struct {
	data Data
}

// NewService 创建 Service 实例
func NewService(data Data) *Service {
	return &Service{data: data}
}

// CreateOrg 创建组织，创建者自动成为 owner
func (s *Service) CreateOrg(ctx context.Context, name, avatarURL, plan, ownerID string) (*Org, error) {
	if name == "" {
		return nil, fmt.Errorf("%w: 组织名称不能为空", pkg.ErrBadRequest)
	}
	org, err := s.data.CreateOrg(ctx, name, avatarURL, plan, ownerID)
	if err != nil {
		return nil, err
	}
	// 创建者自动成为组织成员（角色 owner）
	_, _ = s.data.AddMember(ctx, org.ID, ownerID, "owner")
	return org, nil
}

// GetOrg 获取组织详情（需验证用户为成员或 owner）
func (s *Service) GetOrg(ctx context.Context, orgID, userID string) (*Org, error) {
	org, err := s.data.GetOrgByID(ctx, orgID)
	if err != nil {
		return nil, err
	}
	if err := s.verifyMembership(ctx, orgID, userID, org.OwnerID); err != nil {
		return nil, err
	}
	return org, nil
}

// ListOrgs 列出用户所属组织
func (s *Service) ListOrgs(ctx context.Context, userID string) ([]Org, error) {
	return s.data.ListOrgsByUser(ctx, userID)
}

// UpdateOrg 更新组织信息（仅 owner 可操作）
func (s *Service) UpdateOrg(ctx context.Context, orgID, userID string, name, avatarURL, plan *string) (*Org, error) {
	org, err := s.data.GetOrgByID(ctx, orgID)
	if err != nil {
		return nil, err
	}
	if org.OwnerID != userID {
		return nil, fmt.Errorf("%w: 仅组织所有者可修改", pkg.ErrForbidden)
	}
	return s.data.UpdateOrg(ctx, orgID, name, avatarURL, plan)
}

// AddMember 添加组织成员（需验证操作者为 owner 或 admin）
func (s *Service) AddMember(ctx context.Context, orgID, operatorID, targetUserID, role string) (*OrgMember, error) {
	if err := s.verifyAdmin(ctx, orgID, operatorID); err != nil {
		return nil, err
	}
	// 检查目标用户是否已是成员
	existing, _ := s.data.GetMember(ctx, orgID, targetUserID)
	if existing != nil {
		return nil, fmt.Errorf("%w: 该用户已是组织成员", pkg.ErrAlreadyExists)
	}
	if role == "" {
		role = "member"
	}
	return s.data.AddMember(ctx, orgID, targetUserID, role)
}

// ListMembers 列出组织成员（需验证用户为成员）
func (s *Service) ListMembers(ctx context.Context, orgID, userID string) ([]OrgMember, error) {
	org, err := s.data.GetOrgByID(ctx, orgID)
	if err != nil {
		return nil, err
	}
	if err := s.verifyMembership(ctx, orgID, userID, org.OwnerID); err != nil {
		return nil, err
	}
	return s.data.ListMembers(ctx, orgID)
}

// RemoveMember 移除组织成员（需验证操作者为 owner 或 admin，不可移除 owner）
func (s *Service) RemoveMember(ctx context.Context, orgID, operatorID, targetUserID string) error {
	org, err := s.data.GetOrgByID(ctx, orgID)
	if err != nil {
		return err
	}
	if org.OwnerID == targetUserID {
		return fmt.Errorf("%w: 不能移除组织所有者", pkg.ErrForbidden)
	}
	if err := s.verifyAdmin(ctx, orgID, operatorID); err != nil {
		return err
	}
	return s.data.RemoveMember(ctx, orgID, targetUserID)
}

// verifyMembership 校验用户是否为组织成员或 owner
func (s *Service) verifyMembership(ctx context.Context, orgID, userID, ownerID string) error {
	if userID == ownerID {
		return nil
	}
	member, _ := s.data.GetMember(ctx, orgID, userID)
	if member != nil {
		return nil
	}
	return fmt.Errorf("%w: 无权访问该组织", pkg.ErrForbidden)
}

// verifyAdmin 校验用户是否为 owner 或 admin
func (s *Service) verifyAdmin(ctx context.Context, orgID, userID string) error {
	org, err := s.data.GetOrgByID(ctx, orgID)
	if err != nil {
		return err
	}
	if org.OwnerID == userID {
		return nil
	}
	member, _ := s.data.GetMember(ctx, orgID, userID)
	if member != nil && (member.Role == "admin" || member.Role == "owner") {
		return nil
	}
	return fmt.Errorf("%w: 仅组织管理员可执行此操作", pkg.ErrForbidden)
}
