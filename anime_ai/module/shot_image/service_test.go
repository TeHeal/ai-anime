package shot_image

import (
	"testing"

	"anime_ai/module/shot"
)

func TestShotImageService_Create(t *testing.T) {
	store := NewMemShotImageStore()
	svc := NewService(store, nil, nil, nil, nil)

	img, err := svc.Create("shot1", "proj1", "user1", "https://example.com/img.png")
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if img.ID == "" {
		t.Error("创建后应有 ID")
	}
	if img.ShotID != "shot1" {
		t.Errorf("ShotID 应为 shot1, 得 %s", img.ShotID)
	}
	if img.ImageURL != "https://example.com/img.png" {
		t.Errorf("ImageURL 不匹配")
	}
	if img.Status != "completed" {
		t.Errorf("Status 应为 completed, 得 %s", img.Status)
	}
}

func TestShotImageService_Get(t *testing.T) {
	store := NewMemShotImageStore()
	svc := NewService(store, nil, nil, nil, nil)

	img, _ := svc.Create("shot1", "proj1", "user1", "https://example.com/img.png")
	got, err := svc.Get(img.ID, "user1")
	if err != nil {
		t.Fatalf("Get 失败: %v", err)
	}
	if got.ID != img.ID {
		t.Errorf("ID 不匹配")
	}
}

func TestShotImageService_GetStatus(t *testing.T) {
	store := NewMemShotImageStore()
	shotStore := shot.NewMemShotStore()
	shotReader := shot.ShotReaderAdapter(shotStore)
	shotLocker := shot.ShotLockerAdapter(shotStore)
	svc := NewService(store, shotReader, shotLocker, nil, nil)

	status, err := svc.GetStatus("proj1", "user1")
	if err != nil {
		t.Fatalf("GetStatus 失败: %v", err)
	}
	if status["pending"] == nil {
		t.Error("status 应包含 pending")
	}
	if status["completed"] == nil {
		t.Error("status 应包含 completed")
	}
}

func TestShotImageService_ListByShot(t *testing.T) {
	shotStore := shot.NewMemShotStore()
	shotReader := shot.ShotReaderAdapter(shotStore)
	shotLocker := shot.ShotLockerAdapter(shotStore)

	// 先创建镜头，否则 ListByShot 会因 shotReader 找不到镜头而失败
	sh, _ := shot.NewService(shotStore, nil).Create("proj1", "user1", shot.CreateShotRequest{Prompt: "test"})

	store := NewMemShotImageStore()
	svc := NewService(store, shotReader, shotLocker, nil, nil)
	svc.Create(sh.ID, "proj1", "user1", "https://example.com/1.png")

	list, err := svc.ListByShot(sh.ID, "user1")
	if err != nil {
		t.Fatalf("ListByShot 失败: %v", err)
	}
	if len(list) != 1 {
		t.Errorf("应有 1 个镜图, 得 %d", len(list))
	}
}
