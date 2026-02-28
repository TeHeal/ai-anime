package project

import (
	"errors"
	"testing"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

func TestProjectService_Create(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, err := svc.Create("user1", CreateProjectRequest{
		Name:      "测试项目",
		Story:     "故事内容",
		StoryMode: "full_script",
		Config:    ProjectConfig{Ratio: "16:9"},
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if p.IDStr == "" && p.ID == 0 {
		t.Error("创建后应有 ID")
	}
	if p.Name != "测试项目" {
		t.Errorf("Name 应为 测试项目, 得 %s", p.Name)
	}
	if p.UserIDStr != "user1" {
		t.Errorf("UserIDStr 应为 user1, 得 %s", p.UserIDStr)
	}
}

func TestProjectService_GetByID_NotFound(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	_, err := svc.GetByID("999", "user1")
	if err == nil {
		t.Fatal("应返回 NotFound")
	}
	if !errors.Is(err, pkg.ErrNotFound) {
		t.Errorf("应为 ErrNotFound, 得 %v", err)
	}
}

func TestProjectService_List(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	svc.Create("user1", CreateProjectRequest{Name: "项目1"})
	svc.Create("user1", CreateProjectRequest{Name: "项目2"})

	list, err := svc.List("user1")
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个项目, 得 %d", len(list))
	}
}

func TestProjectService_Update(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, _ := svc.Create("user1", CreateProjectRequest{Name: "原名称"})
	newName := "新名称"
	updated, err := svc.Update(p.IDStr, "user1", UpdateProjectRequest{Name: &newName})
	if err != nil {
		t.Fatalf("Update 失败: %v", err)
	}
	if updated.Name != "新名称" {
		t.Errorf("Name 应为 新名称, 得 %s", updated.Name)
	}
}

func TestProjectService_Delete(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, _ := svc.Create("user1", CreateProjectRequest{Name: "待删"})
	err := svc.Delete(p.IDStr, "user1")
	if err != nil {
		t.Fatalf("Delete 失败: %v", err)
	}
	_, err = svc.GetByID(p.IDStr, "user1")
	if err == nil {
		t.Fatal("删除后应 NotFound")
	}
}

func TestProjectService_AddMember_OnlyCreator(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, _ := svc.Create("user1", CreateProjectRequest{Name: "项目"})
	// 先将 user2 添加为成员（viewer）
	_, _ = svc.AddMember(p.IDStr, "user1", AddMemberRequest{UserID: "user2", Role: "viewer"})
	// user2 作为成员可访问项目，但非创建者，添加成员应失败
	_, err := svc.AddMember(p.IDStr, "user2", AddMemberRequest{UserID: "user3", Role: "editor"})
	if err == nil {
		t.Fatal("非创建者添加成员应失败")
	}
	if err.Error() != "仅项目创建者可添加成员" {
		t.Errorf("错误信息应为 仅项目创建者可添加成员, 得 %v", err)
	}
}

func TestProjectService_AddMember_Success(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, _ := svc.Create("user1", CreateProjectRequest{Name: "项目"})
	m, err := svc.AddMember(p.IDStr, "user1", AddMemberRequest{UserID: "user2", Role: "editor"})
	if err != nil {
		t.Fatalf("AddMember 失败: %v", err)
	}
	if m.UserIDStr != "user2" || m.Role != "editor" {
		t.Errorf("成员信息不符: %+v", m)
	}

	members, _ := svc.ListMembers(p.IDStr, "user1")
	if len(members) != 1 {
		t.Errorf("应有 1 个成员, 得 %d", len(members))
	}
}
