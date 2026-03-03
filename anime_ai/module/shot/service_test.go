package shot

import (
	"testing"
)

func TestShotService_Create(t *testing.T) {
	store := NewMemShotStore()
	svc := NewService(store, nil)

	sh, err := svc.Create("proj1", "user1", CreateShotRequest{
		Prompt:   "角色走向门口",
		Duration: 5,
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if sh.ID == "" {
		t.Error("创建后应有 ID")
	}
	if sh.ProjectID != "proj1" {
		t.Errorf("ProjectID 应为 proj1, 得 %s", sh.ProjectID)
	}
	if sh.Prompt != "角色走向门口" {
		t.Errorf("Prompt 应为 角色走向门口, 得 %s", sh.Prompt)
	}
	if sh.Duration != 5 {
		t.Errorf("Duration 应为 5, 得 %d", sh.Duration)
	}
}

func TestShotService_BulkCreate(t *testing.T) {
	store := NewMemShotStore()
	svc := NewService(store, nil)

	shots, err := svc.BulkCreate("proj1", "user1", BulkCreateShotRequest{
		Shots: []CreateShotRequest{
			{Prompt: "镜头1", Duration: 5},
			{Prompt: "镜头2", Duration: 3},
		},
	})
	if err != nil {
		t.Fatalf("BulkCreate 失败: %v", err)
	}
	if len(shots) != 2 {
		t.Errorf("应有 2 个镜头, 得 %d", len(shots))
	}
}

func TestShotService_List(t *testing.T) {
	store := NewMemShotStore()
	svc := NewService(store, nil)

	svc.Create("proj1", "user1", CreateShotRequest{Prompt: "镜头1"})
	svc.Create("proj1", "user1", CreateShotRequest{Prompt: "镜头2"})

	list, err := svc.List("proj1", "user1", "")
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个镜头, 得 %d", len(list))
	}
}

func TestShotService_Update(t *testing.T) {
	store := NewMemShotStore()
	svc := NewService(store, nil)

	sh, _ := svc.Create("proj1", "user1", CreateShotRequest{Prompt: "原提示词"})
	newPrompt := "新提示词"
	updated, err := svc.Update(sh.ID, "user1", UpdateShotRequest{Prompt: &newPrompt})
	if err != nil {
		t.Fatalf("Update 失败: %v", err)
	}
	if updated.Prompt != "新提示词" {
		t.Errorf("Prompt 应为 新提示词, 得 %s", updated.Prompt)
	}
}

func TestShotService_Delete(t *testing.T) {
	store := NewMemShotStore()
	svc := NewService(store, nil)

	sh, _ := svc.Create("proj1", "user1", CreateShotRequest{Prompt: "待删"})
	err := svc.Delete(sh.ID, "user1")
	if err != nil {
		t.Fatalf("Delete 失败: %v", err)
	}
	_, err = svc.Get(sh.ID, "user1")
	if err == nil {
		t.Fatal("删除后应 NotFound")
	}
}
