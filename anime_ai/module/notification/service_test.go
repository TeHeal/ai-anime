package notification

import (
	"testing"
)

// newTestService 创建测试用的 Notification Service（使用 MemStore）
func newTestService(t *testing.T) *Service {
	t.Helper()
	store := NewMemStore()
	return NewService(store)
}

// sendTestNotification 发送测试通知的辅助方法
func sendTestNotification(t *testing.T, svc *Service, userID, title string) *Notification {
	t.Helper()
	n, err := svc.Send(userID, "proj1", TypeSystem, title, "内容", "", "")
	if err != nil {
		t.Fatalf("发送通知失败: %v", err)
	}
	return n
}

// TestSend_Success 测试发送通知成功
func TestSend_Success(t *testing.T) {
	svc := newTestService(t)

	n, err := svc.Send("user1", "proj1", TypeReviewCompleted, "审核完成", "脚本审核已通过", "script", "s1")
	if err != nil {
		t.Fatalf("发送通知应成功: %v", err)
	}
	if n.ID == "" {
		t.Error("通知应有非空 ID")
	}
	if n.UserID != "user1" {
		t.Errorf("用户ID应为 user1，实际: %s", n.UserID)
	}
	if n.Type != TypeReviewCompleted {
		t.Errorf("类型应为 %s，实际: %s", TypeReviewCompleted, n.Type)
	}
	if n.Title != "审核完成" {
		t.Errorf("标题应为 审核完成，实际: %s", n.Title)
	}
	if n.IsRead {
		t.Error("新通知应为未读状态")
	}
}

// TestCountUnread_CorrectCount 测试未读计数正确
func TestCountUnread_CorrectCount(t *testing.T) {
	svc := newTestService(t)

	sendTestNotification(t, svc, "user1", "通知1")
	sendTestNotification(t, svc, "user1", "通知2")
	sendTestNotification(t, svc, "user1", "通知3")
	sendTestNotification(t, svc, "user2", "其他用户通知")

	count, err := svc.CountUnread("user1")
	if err != nil {
		t.Fatalf("获取未读数量失败: %v", err)
	}
	if count != 3 {
		t.Errorf("user1 未读数应为 3，实际: %d", count)
	}

	count2, _ := svc.CountUnread("user2")
	if count2 != 1 {
		t.Errorf("user2 未读数应为 1，实际: %d", count2)
	}
}

// TestMarkRead_CountDecreases 测试标记单条已读后未读数减少
func TestMarkRead_CountDecreases(t *testing.T) {
	svc := newTestService(t)

	n1 := sendTestNotification(t, svc, "user1", "通知1")
	sendTestNotification(t, svc, "user1", "通知2")

	// 标记第一条已读
	err := svc.MarkRead(n1.ID, "user1")
	if err != nil {
		t.Fatalf("标记已读失败: %v", err)
	}

	count, _ := svc.CountUnread("user1")
	if count != 1 {
		t.Errorf("标记一条已读后未读数应为 1，实际: %d", count)
	}
}

// TestMarkAllRead_CountBecomesZero 测试标记全部已读后未读数为 0
func TestMarkAllRead_CountBecomesZero(t *testing.T) {
	svc := newTestService(t)

	sendTestNotification(t, svc, "user1", "通知1")
	sendTestNotification(t, svc, "user1", "通知2")
	sendTestNotification(t, svc, "user1", "通知3")

	err := svc.MarkAllRead("user1")
	if err != nil {
		t.Fatalf("标记全部已读失败: %v", err)
	}

	count, _ := svc.CountUnread("user1")
	if count != 0 {
		t.Errorf("标记全部已读后未读数应为 0，实际: %d", count)
	}
}

// TestMarkAllRead_DoesNotAffectOtherUsers 测试全部已读不影响其他用户
func TestMarkAllRead_DoesNotAffectOtherUsers(t *testing.T) {
	svc := newTestService(t)

	sendTestNotification(t, svc, "user1", "用户1通知")
	sendTestNotification(t, svc, "user2", "用户2通知")

	_ = svc.MarkAllRead("user1")

	count, _ := svc.CountUnread("user2")
	if count != 1 {
		t.Errorf("全部已读不应影响 user2，未读数应为 1，实际: %d", count)
	}
}

// TestList_Pagination 测试通知列表分页
func TestList_Pagination(t *testing.T) {
	svc := newTestService(t)

	for i := 0; i < 5; i++ {
		sendTestNotification(t, svc, "user1", "通知")
	}

	list, err := svc.List("user1", 2, 0)
	if err != nil {
		t.Fatalf("列出通知失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("分页应返回 2 条，实际: %d", len(list))
	}
}
