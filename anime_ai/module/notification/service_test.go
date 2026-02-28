package notification

import (
	"context"
	"testing"
)

func TestNotificationService_Create(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)
	ctx := context.Background()

	err := svc.Create(ctx, "user1", "task_complete", "任务完成", "镜图生成已完成", "/link", map[string]interface{}{"task_id": "t1"})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}
	list, _ := svc.List(ctx, "user1", 10, 0)
	if len(list) != 1 {
		t.Errorf("创建后应有 1 条通知, 得 %d", len(list))
	}
}

func TestNotificationService_List(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)
	ctx := context.Background()

	svc.Create(ctx, "user1", "task_complete", "标题1", "内容1", "", nil)
	svc.Create(ctx, "user1", "task_complete", "标题2", "内容2", "", nil)

	list, err := svc.List(ctx, "user1", 10, 0)
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 条通知, 得 %d", len(list))
	}
}

func TestNotificationService_CountUnread(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)
	ctx := context.Background()

	svc.Create(ctx, "user1", "task_complete", "标题", "内容", "", nil)
	count, err := svc.CountUnread(ctx, "user1")
	if err != nil {
		t.Fatalf("CountUnread 失败: %v", err)
	}
	if count != 1 {
		t.Errorf("未读数应为 1, 得 %d", count)
	}
}

func TestNotificationService_MarkAsRead(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)
	ctx := context.Background()

	_ = svc.Create(ctx, "user1", "task_complete", "标题", "内容", "", nil)
	list, _ := svc.List(ctx, "user1", 10, 0)
	if len(list) == 0 {
		t.Fatal("应有通知")
	}
	err := svc.MarkAsRead(ctx, list[0].ID, "user1")
	if err != nil {
		t.Fatalf("MarkAsRead 失败: %v", err)
	}
	count, _ := svc.CountUnread(ctx, "user1")
	if count != 0 {
		t.Errorf("标记已读后未读数应为 0, 得 %d", count)
	}
}

func TestNotificationService_MarkAllAsRead(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)
	ctx := context.Background()

	svc.Create(ctx, "user1", "task_complete", "标题1", "内容1", "", nil)
	svc.Create(ctx, "user1", "task_complete", "标题2", "内容2", "", nil)
	err := svc.MarkAllAsRead(ctx, "user1")
	if err != nil {
		t.Fatalf("MarkAllAsRead 失败: %v", err)
	}
	count, _ := svc.CountUnread(ctx, "user1")
	if count != 0 {
		t.Errorf("全部已读后未读数应为 0, 得 %d", count)
	}
}
