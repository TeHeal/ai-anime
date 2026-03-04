package team

import (
	"context"

	"anime_ai/module/organization"
)

// OrgCheckerAdapter 将 organization.Service 适配为 team.OrgChecker
type OrgCheckerAdapter struct {
	orgSvc *organization.Service
}

func NewOrgCheckerAdapter(orgSvc *organization.Service) *OrgCheckerAdapter {
	return &OrgCheckerAdapter{orgSvc: orgSvc}
}

func (a *OrgCheckerAdapter) IsOrgAdminOrOwner(ctx context.Context, orgID, userID string) bool {
	// organization.Service 暴露的 verifyAdmin 是私有的，这里用现有的 GetOrg + 成员查询判断
	// 利用 AddMember 等方法内部会调用 verifyAdmin 的逻辑，这里做一个轻量版本
	org, err := a.orgSvc.GetOrg(ctx, orgID, userID)
	if err != nil {
		return false
	}
	if org.OwnerID == userID {
		return true
	}
	// 非 owner，检查是否为 admin 成员（通过 ListMembers 判断太重，直接尝试通过 Service 确认）
	// GetOrg 成功说明至少是成员，但不能确认是 admin
	// 由于 verifyAdmin 是私有方法，这里通过获取成员列表遍历检查
	members, err := a.orgSvc.ListMembers(ctx, orgID, userID)
	if err != nil {
		return false
	}
	for _, m := range members {
		if m.UserID == userID && (m.Role == "admin" || m.Role == "owner") {
			return true
		}
	}
	return false
}

func (a *OrgCheckerAdapter) IsOrgMember(ctx context.Context, orgID, userID string) bool {
	_, err := a.orgSvc.GetOrg(ctx, orgID, userID)
	return err == nil
}
