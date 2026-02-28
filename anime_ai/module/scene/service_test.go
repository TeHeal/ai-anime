package scene

import (
	"testing"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

func TestSceneService_Create(t *testing.T) {
	sceneStore := NewMemSceneStore()
	blockStore := NewMemSceneBlockStore()
	svc := NewService(sceneStore, blockStore, nil, nil)

	resp, err := svc.Create("ep1", "user1", CreateSceneRequest{
		SceneID:  "S1",
		Location: "客厅",
		Time:     "白天",
		Characters: []string{"角色A"},
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if resp.ID == "" {
		t.Error("创建后应有 ID")
	}
	if resp.Location != "客厅" {
		t.Errorf("Location 应为 客厅, 得 %s", resp.Location)
	}
}

func TestSceneService_List(t *testing.T) {
	sceneStore := NewMemSceneStore()
	blockStore := NewMemSceneBlockStore()
	svc := NewService(sceneStore, blockStore, nil, nil)

	svc.Create("ep1", "user1", CreateSceneRequest{SceneID: "S1", Location: "A"})
	svc.Create("ep1", "user1", CreateSceneRequest{SceneID: "S2", Location: "B"})

	list, err := svc.List("ep1", "user1")
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 场, 得 %d", len(list))
	}
}

func TestSceneService_CreateBlock(t *testing.T) {
	sceneStore := NewMemSceneStore()
	blockStore := NewMemSceneBlockStore()
	svc := NewService(sceneStore, blockStore, nil, nil)

	sc, _ := svc.Create("ep1", "user1", CreateSceneRequest{SceneID: "S1"})
	block, err := svc.CreateBlock(sc.ID, "user1", CreateBlockRequest{
		Type:    "action",
		Content: "角色走向门口",
	})
	if err != nil {
		t.Fatalf("CreateBlock 失败: %v", err)
	}
	if block.ID == "" {
		t.Error("块应有 ID")
	}
	if block.Type != "action" {
		t.Errorf("Type 应为 action, 得 %s", block.Type)
	}
}

func TestSceneService_Get_NotFound(t *testing.T) {
	sceneStore := NewMemSceneStore()
	blockStore := NewMemSceneBlockStore()
	svc := NewService(sceneStore, blockStore, nil, nil)

	_, err := svc.Get("nonexistent", "ep1", "user1")
	if err == nil {
		t.Fatal("应返回 NotFound")
	}
	if err != pkg.ErrNotFound {
		t.Errorf("应为 ErrNotFound, 得 %v", err)
	}
}
