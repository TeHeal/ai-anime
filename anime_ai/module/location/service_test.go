package location

import (
	"testing"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

type dummyVerifier struct{}

func (dummyVerifier) Verify(projectID, userID string) error { return nil }

func TestLocationService_Create(t *testing.T) {
	store := NewMemLocationStore()
	svc := NewService(store, dummyVerifier{})

	loc, err := svc.Create("proj1", "user1", CreateRequest{
		Name:             "客厅",
		Time:             "白天",
		InteriorExterior: "内景",
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if loc.ID == "" {
		t.Error("创建后应有 ID")
	}
	if loc.Name != "客厅" {
		t.Errorf("Name 应为 客厅, 得 %s", loc.Name)
	}
}

func TestLocationService_List(t *testing.T) {
	store := NewMemLocationStore()
	svc := NewService(store, dummyVerifier{})

	svc.Create("proj1", "user1", CreateRequest{Name: "场景1"})
	svc.Create("proj1", "user1", CreateRequest{Name: "场景2"})

	list, err := svc.List("proj1", "user1")
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个场景, 得 %d", len(list))
	}
}

func TestLocationService_Get_NotFound(t *testing.T) {
	store := NewMemLocationStore()
	svc := NewService(store, dummyVerifier{})

	_, err := svc.Get("999", "proj1", "user1")
	if err == nil {
		t.Fatal("应返回 NotFound")
	}
	if err != pkg.ErrNotFound {
		t.Errorf("应为 ErrNotFound, 得 %v", err)
	}
}
