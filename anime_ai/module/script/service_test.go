package script

import (
	"testing"
)

func TestScriptService_Create(t *testing.T) {
	store := NewMemSegmentStore()
	svc := NewService(store, nil)

	seg, err := svc.Create(1, 1, CreateSegmentRequest{
		Content:   "镜头指令内容",
		SortIndex: 0,
	})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	if seg.ID == "" {
		t.Error("创建后应有 ID")
	}
	if seg.Content != "镜头指令内容" {
		t.Errorf("Content 不符: %s", seg.Content)
	}
}

func TestScriptService_List(t *testing.T) {
	store := NewMemSegmentStore()
	svc := NewService(store, nil)

	svc.Create(1, 1, CreateSegmentRequest{Content: "内容1", SortIndex: 0})
	svc.Create(1, 1, CreateSegmentRequest{Content: "内容2", SortIndex: 1})

	list, err := svc.List(1, 1)
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个分段, 得 %d", len(list))
	}
}

func TestScriptService_Update(t *testing.T) {
	store := NewMemSegmentStore()
	svc := NewService(store, nil)

	seg, _ := svc.Create(1, 1, CreateSegmentRequest{Content: "原内容", SortIndex: 0})
	newContent := "新内容"
	updated, err := svc.Update(seg.ID, 1, 1, UpdateSegmentRequest{Content: &newContent})
	if err != nil {
		t.Fatalf("Update 失败: %v", err)
	}
	if updated.Content != "新内容" {
		t.Errorf("Content 应为 新内容, 得 %s", updated.Content)
	}
}

func TestScriptService_Delete(t *testing.T) {
	store := NewMemSegmentStore()
	svc := NewService(store, nil)

	seg, _ := svc.Create(1, 1, CreateSegmentRequest{Content: "待删", SortIndex: 0})
	err := svc.Delete(seg.ID, 1, 1)
	if err != nil {
		t.Fatalf("Delete 失败: %v", err)
	}
	_, err = svc.List(1, 1)
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	// 删除后 List 应少一条
	list, _ := svc.List(1, 1)
	if len(list) != 0 {
		t.Errorf("删除后应有 0 条, 得 %d", len(list))
	}
}

func TestScriptService_BulkCreate(t *testing.T) {
	store := NewMemSegmentStore()
	svc := NewService(store, nil)

	segs, err := svc.BulkCreate(1, 1, BulkCreateSegmentRequest{
		Segments: []CreateSegmentRequest{
			{Content: "A", SortIndex: 0},
			{Content: "B", SortIndex: 1},
		},
	})
	if err != nil {
		t.Fatalf("BulkCreate 失败: %v", err)
	}
	if len(segs) != 2 {
		t.Errorf("应有 2 个分段, 得 %d", len(segs))
	}
}
