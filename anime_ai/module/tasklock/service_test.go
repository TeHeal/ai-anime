package tasklock

import (
	"testing"

	"go.uber.org/zap"
)

// newTestService 创建测试用的 TaskLock Service（使用 MemStore + nop logger）
func newTestService(t *testing.T) *Service {
	t.Helper()
	store := NewMemStore()
	logger := zap.NewNop()
	return NewService(store, logger)
}

// TestAcquire_Success 测试获取任务锁成功
func TestAcquire_Success(t *testing.T) {
	svc := newTestService(t)

	lock, err := svc.Acquire("proj1", "user1", AcquireRequest{
		ResourceType: "script",
		ResourceID:   "s1",
		Action:       "generate",
		TTLSeconds:   60,
	})
	if err != nil {
		t.Fatalf("获取锁应成功: %v", err)
	}
	if lock.ID == "" {
		t.Error("锁应有非空 ID")
	}
	if lock.Status != StatusRunning {
		t.Errorf("锁状态应为 %s，实际: %s", StatusRunning, lock.Status)
	}
	if lock.LockedBy != "user1" {
		t.Errorf("锁持有者应为 user1，实际: %s", lock.LockedBy)
	}
}

// TestAcquire_SameUserReturnsExisting 测试同一用户重复获取返回已有锁
func TestAcquire_SameUserReturnsExisting(t *testing.T) {
	svc := newTestService(t)
	req := AcquireRequest{
		ResourceType: "script",
		ResourceID:   "s1",
		Action:       "generate",
		TTLSeconds:   60,
	}

	lock1, err := svc.Acquire("proj1", "user1", req)
	if err != nil {
		t.Fatalf("首次获取锁应成功: %v", err)
	}

	lock2, err := svc.Acquire("proj1", "user1", req)
	if err != nil {
		t.Fatalf("同一用户重复获取应返回已有锁: %v", err)
	}
	if lock2.ID != lock1.ID {
		t.Errorf("应返回相同锁 ID: 期望 %s，实际 %s", lock1.ID, lock2.ID)
	}
}

// TestAcquire_DifferentUserError 测试不同用户获取已被锁定的资源失败
func TestAcquire_DifferentUserError(t *testing.T) {
	svc := newTestService(t)
	req := AcquireRequest{
		ResourceType: "script",
		ResourceID:   "s1",
		Action:       "generate",
		TTLSeconds:   60,
	}

	_, err := svc.Acquire("proj1", "user1", req)
	if err != nil {
		t.Fatalf("user1 获取锁应成功: %v", err)
	}

	_, err = svc.Acquire("proj1", "user2", req)
	if err == nil {
		t.Fatal("不同用户获取已锁定资源应返回错误")
	}
}

// TestRelease_Success 测试释放锁成功
func TestRelease_Success(t *testing.T) {
	svc := newTestService(t)

	lock, _ := svc.Acquire("proj1", "user1", AcquireRequest{
		ResourceType: "script",
		ResourceID:   "s1",
		Action:       "generate",
		TTLSeconds:   60,
	})

	err := svc.Release(lock.ID)
	if err != nil {
		t.Fatalf("释放锁应成功: %v", err)
	}

	// 释放后其他用户可以获取
	lock2, err := svc.Acquire("proj1", "user2", AcquireRequest{
		ResourceType: "script",
		ResourceID:   "s1",
		Action:       "generate",
		TTLSeconds:   60,
	})
	if err != nil {
		t.Fatalf("释放后其他用户应可获取锁: %v", err)
	}
	if lock2.LockedBy != "user2" {
		t.Errorf("新锁持有者应为 user2，实际: %s", lock2.LockedBy)
	}
}

// TestRelease_NonexistentLock 测试释放不存在的锁失败
func TestRelease_NonexistentLock(t *testing.T) {
	svc := newTestService(t)

	err := svc.Release("nonexistent")
	if err == nil {
		t.Fatal("释放不存在的锁应返回错误")
	}
}

// TestAcquire_DefaultTTL 测试不指定 TTL 时使用默认值
func TestAcquire_DefaultTTL(t *testing.T) {
	svc := newTestService(t)

	lock, err := svc.Acquire("proj1", "user1", AcquireRequest{
		ResourceType: "script",
		ResourceID:   "s1",
		Action:       "generate",
	})
	if err != nil {
		t.Fatalf("默认TTL获取锁应成功: %v", err)
	}
	if lock.ExpiresAt == "" {
		t.Error("锁应有过期时间")
	}
}

// TestAcquire_DifferentResources 测试不同资源可以分别加锁
func TestAcquire_DifferentResources(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.Acquire("proj1", "user1", AcquireRequest{
		ResourceType: "script", ResourceID: "s1", Action: "generate",
	})
	if err != nil {
		t.Fatalf("第一个资源加锁应成功: %v", err)
	}

	_, err = svc.Acquire("proj1", "user2", AcquireRequest{
		ResourceType: "script", ResourceID: "s2", Action: "generate",
	})
	if err != nil {
		t.Fatalf("不同资源加锁应成功: %v", err)
	}
}
