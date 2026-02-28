package prop

import (
	"testing"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

type dummyVerifier struct{}

func (dummyVerifier) Verify(projectID, userID string) error { return nil }

func TestPropService_Create(t *testing.T) {
	store := NewMemPropStore()
	svc := NewService(store, dummyVerifier{})

	p, err := svc.Create("proj1", "user1", CreateRequest{
		Name:       "宝剑",
		Appearance: "银色长剑",
		IsKeyProp:  true,
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if p.ID == "" {
		t.Error("创建后应有 ID")
	}
	if p.Name != "宝剑" {
		t.Errorf("Name 应为 宝剑, 得 %s", p.Name)
	}
}

func TestPropService_List(t *testing.T) {
	store := NewMemPropStore()
	svc := NewService(store, dummyVerifier{})

	svc.Create("proj1", "user1", CreateRequest{Name: "道具1"})
	svc.Create("proj1", "user1", CreateRequest{Name: "道具2"})

	list, err := svc.List("proj1", "user1")
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个道具, 得 %d", len(list))
	}
}

func TestPropService_Get_NotFound(t *testing.T) {
	store := NewMemPropStore()
	svc := NewService(store, dummyVerifier{})

	_, err := svc.Get("999", "proj1", "user1")
	if err == nil {
		t.Fatal("应返回 NotFound")
	}
	if err != pkg.ErrNotFound {
		t.Errorf("应为 ErrNotFound, 得 %v", err)
	}
}
