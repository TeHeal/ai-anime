package episode

import (
	"testing"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

func TestEpisodeService_Create(t *testing.T) {
	store := NewMemEpisodeStore()
	svc := NewService(store, nil)

	ep, err := svc.Create("proj1", "user1", CreateEpisodeRequest{
		Title:   "第一集",
		Summary: "简介",
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if ep.IDStr == "" {
		t.Error("创建后应有 IDStr")
	}
	if ep.Title != "第一集" {
		t.Errorf("Title 应为 第一集, 得 %s", ep.Title)
	}
	if ep.ProjectIDStr != "proj1" {
		t.Errorf("ProjectIDStr 应为 proj1, 得 %s", ep.ProjectIDStr)
	}
}

func TestEpisodeService_Get_NotFound(t *testing.T) {
	store := NewMemEpisodeStore()
	svc := NewService(store, nil)

	_, err := svc.Get("999", "proj1", "user1")
	if err == nil {
		t.Fatal("应返回 NotFound")
	}
	if err != pkg.ErrNotFound {
		t.Errorf("应为 ErrNotFound, 得 %v", err)
	}
}

func TestEpisodeService_ListByProject(t *testing.T) {
	store := NewMemEpisodeStore()
	svc := NewService(store, nil)

	svc.Create("proj1", "user1", CreateEpisodeRequest{Title: "集1"})
	svc.Create("proj1", "user1", CreateEpisodeRequest{Title: "集2"})

	list, err := svc.ListByProject("proj1", "user1")
	if err != nil {
		t.Fatalf("ListByProject 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 集, 得 %d", len(list))
	}
}

func TestEpisodeService_Update(t *testing.T) {
	store := NewMemEpisodeStore()
	svc := NewService(store, nil)

	ep, _ := svc.Create("proj1", "user1", CreateEpisodeRequest{Title: "原标题"})
	newTitle := "新标题"
	updated, err := svc.Update(ep.IDStr, "proj1", "user1", UpdateEpisodeRequest{Title: &newTitle})
	if err != nil {
		t.Fatalf("Update 失败: %v", err)
	}
	if updated.Title != "新标题" {
		t.Errorf("Title 应为 新标题, 得 %s", updated.Title)
	}
}

func TestEpisodeService_Delete(t *testing.T) {
	store := NewMemEpisodeStore()
	svc := NewService(store, nil)

	ep, _ := svc.Create("proj1", "user1", CreateEpisodeRequest{Title: "待删"})
	err := svc.Delete(ep.IDStr, "proj1", "user1")
	if err != nil {
		t.Fatalf("Delete 失败: %v", err)
	}
	_, err = svc.Get(ep.IDStr, "proj1", "user1")
	if err == nil {
		t.Fatal("删除后应 NotFound")
	}
}
