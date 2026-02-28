package auth

import (
	"testing"
)

// TestDirector_AllActions 测试导演角色拥有所有操作权限
func TestDirector_AllActions(t *testing.T) {
	actions := []Action{
		ActionProjectCreate, ActionProjectDelete, ActionProjectView,
		ActionStoryEdit, ActionAssetManage, ActionScriptEdit,
		ActionShotImageGenerate, ActionShotVideoGenerate, ActionCompositeEdit,
		ActionReviewDecide, ActionManageMembers, ActionScheduleManage,
		ActionViewAuditLog,
	}
	for _, a := range actions {
		if !IsRoleAllowed(RoleDirector, a) {
			t.Errorf("导演应有 %s 权限", a)
		}
	}
}

// TestArtist_OnlyGenerateShotImages 测试原画师只能生成镜图
func TestArtist_OnlyGenerateShotImages(t *testing.T) {
	allowed := []Action{ActionProjectView, ActionShotImageGenerate}
	denied := []Action{
		ActionProjectCreate, ActionProjectDelete, ActionStoryEdit,
		ActionAssetManage, ActionScriptEdit, ActionShotVideoGenerate,
		ActionCompositeEdit, ActionReviewDecide, ActionManageMembers,
		ActionScheduleManage, ActionViewAuditLog,
	}

	for _, a := range allowed {
		if !IsRoleAllowed(RoleArtist, a) {
			t.Errorf("原画师应有 %s 权限", a)
		}
	}
	for _, a := range denied {
		if IsRoleAllowed(RoleArtist, a) {
			t.Errorf("原画师不应有 %s 权限", a)
		}
	}
}

// TestReviewer_CanReviewButNotGenerate 测试审核员可审核但不能生成
func TestReviewer_CanReviewButNotGenerate(t *testing.T) {
	if !IsRoleAllowed(RoleReviewer, ActionReviewDecide) {
		t.Error("审核员应有审核权限")
	}
	if !IsRoleAllowed(RoleReviewer, ActionViewAuditLog) {
		t.Error("审核员应有查看审计日志权限")
	}
	if IsRoleAllowed(RoleReviewer, ActionShotImageGenerate) {
		t.Error("审核员不应有镜图生成权限")
	}
	if IsRoleAllowed(RoleReviewer, ActionShotVideoGenerate) {
		t.Error("审核员不应有镜头生成权限")
	}
}

// TestViewer_OnlyView 测试观众只有查看权限
func TestViewer_OnlyView(t *testing.T) {
	if !IsRoleAllowed(RoleViewer, ActionProjectView) {
		t.Error("观众应有查看权限")
	}

	denied := []Action{
		ActionProjectCreate, ActionProjectDelete, ActionStoryEdit,
		ActionAssetManage, ActionScriptEdit, ActionShotImageGenerate,
		ActionShotVideoGenerate, ActionCompositeEdit, ActionReviewDecide,
		ActionManageMembers, ActionScheduleManage, ActionViewAuditLog,
	}
	for _, a := range denied {
		if IsRoleAllowed(RoleViewer, a) {
			t.Errorf("观众不应有 %s 权限", a)
		}
	}
}

// TestMultiRole_ArtistAndReviewer 测试多角色并集：原画师+审核员可同时生成和审核
func TestMultiRole_ArtistAndReviewer(t *testing.T) {
	roles := []string{RoleArtist, RoleReviewer}

	cases := []struct {
		action  Action
		allowed bool
		desc    string
	}{
		{ActionShotImageGenerate, true, "原画师+审核员应可生成镜图"},
		{ActionReviewDecide, true, "原画师+审核员应可审核"},
		{ActionProjectView, true, "原画师+审核员应可查看项目"},
		{ActionProjectCreate, false, "原画师+审核员不应可创建项目"},
		{ActionCompositeEdit, false, "原画师+审核员不应可编辑成片"},
	}
	for _, tc := range cases {
		t.Run(string(tc.action), func(t *testing.T) {
			got := IsAllowedMultiRole(roles, tc.action)
			if got != tc.allowed {
				t.Errorf("%s: 期望 %v，实际 %v", tc.desc, tc.allowed, got)
			}
		})
	}
}

// TestIsValidRole 测试角色名称合法性校验
func TestIsValidRole(t *testing.T) {
	validRoles := []struct {
		role  string
		valid bool
	}{
		{RoleDirector, true},
		{RoleArtist, true},
		{RoleReviewer, true},
		{RoleViewer, true},
		{RoleAdmin, true},
		{RoleStoryboarder, true},
		{RoleDesigner, true},
		{RoleCinematographer, true},
		{RolePostProducer, true},
		{"invalid_role", false},
		{"", false},
		{"superadmin", false},
	}
	for _, tc := range validRoles {
		t.Run(tc.role, func(t *testing.T) {
			got := IsValidRole(tc.role)
			if got != tc.valid {
				t.Errorf("IsValidRole(%q): 期望 %v，实际 %v", tc.role, tc.valid, got)
			}
		})
	}
}

// TestIsAllowed_BackwardCompat 测试向后兼容的 IsAllowed 函数
func TestIsAllowed_BackwardCompat(t *testing.T) {
	if !IsAllowed(RoleDirector, ActionProjectCreate) {
		t.Error("IsAllowed 向后兼容: 导演应可创建项目")
	}
	if IsAllowed(RoleViewer, ActionProjectCreate) {
		t.Error("IsAllowed 向后兼容: 观众不应可创建项目")
	}
}

// TestUnknownRole_NoPermissions 测试未知角色没有任何权限
func TestUnknownRole_NoPermissions(t *testing.T) {
	if IsRoleAllowed("unknown", ActionProjectView) {
		t.Error("未知角色不应有任何权限")
	}
}
