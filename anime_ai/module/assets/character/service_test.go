package character

import (
	"testing"
)

func TestCharacterService_Create(t *testing.T) {
	data := NewMemData()
	svc := NewService(data, nil)

	projID := "proj1"
	c, err := svc.Create("user1", CreateCharacterRequest{
		Name:      "测试角色",
		ProjectID: &projID,
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if c.ID == "" {
		t.Error("创建后应有 ID")
	}
	if c.Name != "测试角色" {
		t.Errorf("Name 应为 测试角色, 得 %s", c.Name)
	}
	if c.ProjectID == nil || *c.ProjectID != "proj1" {
		t.Errorf("ProjectID 应为 proj1, 得 %v", c.ProjectID)
	}
}

func TestCharacterService_Get(t *testing.T) {
	data := NewMemData()
	svc := NewService(data, nil)

	c, _ := svc.Create("user1", CreateCharacterRequest{Name: "角色A"})
	got, err := svc.Get(c.ID, "user1")
	if err != nil {
		t.Fatalf("Get 失败: %v", err)
	}
	if got.Name != "角色A" {
		t.Errorf("Name 应为 角色A, 得 %s", got.Name)
	}
}

func TestCharacterService_ListByProject(t *testing.T) {
	data := NewMemData()
	svc := NewService(data, nil)

	projID := "proj1"
	svc.Create("user1", CreateCharacterRequest{Name: "角色1", ProjectID: &projID})
	svc.Create("user1", CreateCharacterRequest{Name: "角色2", ProjectID: &projID})

	list, err := svc.ListByProject("proj1", "user1")
	if err != nil {
		t.Fatalf("ListByProject 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个角色, 得 %d", len(list))
	}
}

func TestCharacterService_ListLibrary(t *testing.T) {
	data := NewMemData()
	svc := NewService(data, nil)

	svc.Create("user1", CreateCharacterRequest{Name: "角色A"})
	svc.Create("user1", CreateCharacterRequest{Name: "角色B"})

	list, err := svc.ListLibrary("user1")
	if err != nil {
		t.Fatalf("ListLibrary 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个角色, 得 %d", len(list))
	}
}
