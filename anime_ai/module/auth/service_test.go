package auth

import (
	"testing"
)

// newTestService 创建测试用的 AuthService（使用 BootstrapUserStore）
func newTestService(t *testing.T) *AuthService {
	t.Helper()
	store, err := NewBootstrapUserStore("admin", "admin123")
	if err != nil {
		t.Fatalf("创建 BootstrapUserStore 失败: %v", err)
	}
	return NewAuthService(store, "test-jwt-secret")
}

// TestLogin_Success 测试正确用户名密码登录成功
func TestLogin_Success(t *testing.T) {
	svc := newTestService(t)

	resp, err := svc.Login(LoginRequest{Username: "admin", Password: "admin123"})
	if err != nil {
		t.Fatalf("登录应成功，但返回错误: %v", err)
	}
	if resp.Token == "" {
		t.Error("登录成功应返回非空 Token")
	}
	if resp.User == nil || resp.User.Username != "admin" {
		t.Error("登录成功应返回正确的用户信息")
	}
}

// TestLogin_WrongPassword 测试错误密码登录失败
func TestLogin_WrongPassword(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.Login(LoginRequest{Username: "admin", Password: "wrongpass"})
	if err == nil {
		t.Fatal("错误密码登录应返回错误")
	}
}

// TestLogin_NonexistentUser 测试不存在的用户登录失败
func TestLogin_NonexistentUser(t *testing.T) {
	svc := newTestService(t)

	_, err := svc.Login(LoginRequest{Username: "nobody", Password: "admin123"})
	if err == nil {
		t.Fatal("不存在的用户登录应返回错误")
	}
}

// TestCreateUser_Success 测试创建新用户成功
func TestCreateUser_Success(t *testing.T) {
	svc := newTestService(t)

	user, err := svc.CreateUser(CreateUserRequest{
		Username:    "testuser",
		Password:    "password123",
		DisplayName: "Test User",
		Role:        "member",
	})
	if err != nil {
		t.Fatalf("创建用户应成功，但返回错误: %v", err)
	}
	if user.Username != "testuser" {
		t.Errorf("用户名应为 testuser，实际: %s", user.Username)
	}
	if user.DisplayName != "Test User" {
		t.Errorf("显示名应为 Test User，实际: %s", user.DisplayName)
	}
	if user.Role != "member" {
		t.Errorf("角色应为 member，实际: %s", user.Role)
	}
}

// TestCreateUser_DefaultValues 测试创建用户时默认角色和显示名
func TestCreateUser_DefaultValues(t *testing.T) {
	svc := newTestService(t)

	user, err := svc.CreateUser(CreateUserRequest{
		Username: "newuser",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("创建用户应成功: %v", err)
	}
	if user.Role != "member" {
		t.Errorf("默认角色应为 member，实际: %s", user.Role)
	}
	if user.DisplayName != "newuser" {
		t.Errorf("默认显示名应与用户名一致，实际: %s", user.DisplayName)
	}
}

// TestCreateUser_DuplicateUsername 测试重复用户名创建失败
func TestCreateUser_DuplicateUsername(t *testing.T) {
	svc := newTestService(t)

	// admin 已存在于 BootstrapUserStore
	_, err := svc.CreateUser(CreateUserRequest{
		Username: "admin",
		Password: "password123",
	})
	if err == nil {
		t.Fatal("重复用户名应返回错误")
	}
}

// TestChangePassword_Success 测试正确旧密码修改密码成功
func TestChangePassword_Success(t *testing.T) {
	svc := newTestService(t)

	err := svc.ChangePassword("1", ChangePasswordRequest{
		OldPassword: "admin123",
		NewPassword: "newpass456",
	})
	if err != nil {
		t.Fatalf("修改密码应成功: %v", err)
	}

	// 使用新密码登录验证
	resp, err := svc.Login(LoginRequest{Username: "admin", Password: "newpass456"})
	if err != nil {
		t.Fatalf("新密码登录应成功: %v", err)
	}
	if resp.Token == "" {
		t.Error("新密码登录应返回有效 Token")
	}
}

// TestChangePassword_WrongOldPassword 测试旧密码错误时修改失败
func TestChangePassword_WrongOldPassword(t *testing.T) {
	svc := newTestService(t)

	err := svc.ChangePassword("1", ChangePasswordRequest{
		OldPassword: "wrongold",
		NewPassword: "newpass456",
	})
	if err == nil {
		t.Fatal("旧密码错误时修改密码应返回错误")
	}
}

// TestChangePassword_UserNotFound 测试用户不存在时修改密码失败
func TestChangePassword_UserNotFound(t *testing.T) {
	svc := newTestService(t)

	err := svc.ChangePassword("999", ChangePasswordRequest{
		OldPassword: "admin123",
		NewPassword: "newpass456",
	})
	if err == nil {
		t.Fatal("用户不存在时修改密码应返回错误")
	}
}
