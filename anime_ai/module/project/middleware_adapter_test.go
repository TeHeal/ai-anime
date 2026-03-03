package project

import (
	"errors"
	"testing"

	"anime_ai/pub/pkg"
)

func TestProjectReaderAdapter(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, _ := svc.Create("1", CreateProjectRequest{Name: "测试项目"})

	reader := ProjectReaderAdapter(data)
	info, err := reader.FindByIDOnly(p.IDStr)
	if err != nil {
		t.Fatalf("FindByIDOnly 失败: %v", err)
	}
	if info.UserID != p.UserID {
		t.Errorf("UserID 应为 %d, 得 %d", p.UserID, info.UserID)
	}
}

func TestProjectReaderAdapter_NotFound(t *testing.T) {
	data := NewMemData()
	reader := ProjectReaderAdapter(data)

	_, err := reader.FindByIDOnly("999")
	if err == nil {
		t.Fatal("应返回错误")
	}
	if !errors.Is(err, pkg.ErrNotFound) {
		t.Errorf("应为 ErrNotFound, 得 %v", err)
	}
}

func TestProjectMemberReaderAdapter(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, _ := svc.Create("1", CreateProjectRequest{Name: "测试项目"})
	svc.AddMember(p.IDStr, "1", AddMemberRequest{UserID: "2", Role: "editor"})

	reader := ProjectMemberReaderAdapter(data)
	info, err := reader.FindByProjectAndUser(p.IDStr, "2")
	if err != nil {
		t.Fatalf("FindByProjectAndUser 失败: %v", err)
	}
	if info.Role != "editor" {
		t.Errorf("Role 应为 editor, 得 %s", info.Role)
	}
}

func TestProjectMemberReaderAdapter_NotFound(t *testing.T) {
	data := NewMemData()
	reader := ProjectMemberReaderAdapter(data)

	_, err := reader.FindByProjectAndUser("1", "999")
	if err == nil {
		t.Fatal("应返回错误")
	}
}

func TestNoopTeamMemberReader(t *testing.T) {
	reader := &NoopTeamMemberReader{}
	_, err := reader.FindByTeamAndUser(1, 1)
	if err == nil {
		t.Fatal("NoopTeamMemberReader 应始终返回错误")
	}
	if !errors.Is(err, pkg.ErrNotFound) {
		t.Errorf("应为 ErrNotFound, 得 %v", err)
	}
}
