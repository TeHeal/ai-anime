package auth

import (
	"testing"
)

func TestAuthService_Login_Success(t *testing.T) {
	store, err := NewBootstrapUserStore("admin", "admin123")
	if err != nil {
		t.Fatalf("NewBootstrapUserStore 失败: %v", err)
	}
	svc := NewAuthService(store, "test-jwt-secret")

	resp, err := svc.Login(LoginRequest{Username: "admin", Password: "admin123"})
	if err != nil {
		t.Fatalf("Login 失败: %v", err)
	}
	if resp.Token == "" {
		t.Error("Token 不应为空")
	}
	if resp.User == nil || resp.User.Username != "admin" {
		t.Errorf("User 应为 admin, 得 %+v", resp.User)
	}
}

func TestAuthService_Login_WrongPassword(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	_, err := svc.Login(LoginRequest{Username: "admin", Password: "wrong"})
	if err == nil {
		t.Fatal("错误密码应失败")
	}
	if err.Error() != "用户名或密码错误" {
		t.Errorf("错误信息不符: %v", err)
	}
}

func TestAuthService_Login_UnknownUser(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	_, err := svc.Login(LoginRequest{Username: "unknown", Password: "any"})
	if err == nil {
		t.Fatal("未知用户应失败")
	}
}

func TestAuthService_GetCurrentUser(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	u, err := svc.GetCurrentUser("1")
	if err != nil {
		t.Fatalf("GetCurrentUser 失败: %v", err)
	}
	if u.Username != "admin" {
		t.Errorf("Username 应为 admin, 得 %s", u.Username)
	}
}

func TestAuthService_ChangePassword_Success(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	err := svc.ChangePassword("1", ChangePasswordRequest{
		OldPassword: "admin123",
		NewPassword: "newpass123",
	})
	if err != nil {
		t.Fatalf("ChangePassword 失败: %v", err)
	}

	_, err = svc.Login(LoginRequest{Username: "admin", Password: "newpass123"})
	if err != nil {
		t.Errorf("新密码应可登录: %v", err)
	}
}

func TestAuthService_ChangePassword_WrongOld(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	err := svc.ChangePassword("1", ChangePasswordRequest{
		OldPassword: "wrong",
		NewPassword: "newpass123",
	})
	if err == nil {
		t.Fatal("错误旧密码应失败")
	}
	if err.Error() != "当前密码错误" {
		t.Errorf("错误信息不符: %v", err)
	}
}

func TestAuthService_Register_Success(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	resp, err := svc.Register(RegisterRequest{
		Username:    "newuser",
		Password:    "pass123",
		DisplayName: "New User",
	})
	if err != nil {
		t.Fatalf("Register 失败: %v", err)
	}
	if resp.Token == "" {
		t.Error("Token 不应为空")
	}
	if resp.User == nil || resp.User.Username != "newuser" {
		t.Errorf("User 应为 newuser, 得 %+v", resp.User)
	}
	if resp.User.DisplayName != "New User" {
		t.Errorf("DisplayName 应为 'New User', 得 %s", resp.User.DisplayName)
	}
	if resp.User.Role != "member" {
		t.Errorf("Role 应为 member, 得 %s", resp.User.Role)
	}
}

func TestAuthService_Register_DuplicateUsername(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	_, err := svc.Register(RegisterRequest{
		Username: "admin",
		Password: "pass123",
	})
	if err == nil {
		t.Fatal("重复用户名应失败")
	}
	if err.Error() != "用户名已被注册" {
		t.Errorf("错误信息不符: %v", err)
	}
}

func TestAuthService_Register_DefaultDisplayName(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	resp, err := svc.Register(RegisterRequest{
		Username: "newuser",
		Password: "pass123",
	})
	if err != nil {
		t.Fatalf("Register 失败: %v", err)
	}
	if resp.User.DisplayName != "newuser" {
		t.Errorf("DisplayName 未设置时应默认为用户名, 得 %s", resp.User.DisplayName)
	}
}

func TestAuthService_Register_ThenLogin(t *testing.T) {
	store, _ := NewBootstrapUserStore("admin", "admin123")
	svc := NewAuthService(store, "test-jwt-secret")

	_, err := svc.Register(RegisterRequest{
		Username: "newuser",
		Password: "mypassword",
	})
	if err != nil {
		t.Fatalf("Register 失败: %v", err)
	}

	resp, err := svc.Login(LoginRequest{
		Username: "newuser",
		Password: "mypassword",
	})
	if err != nil {
		t.Fatalf("注册后登录失败: %v", err)
	}
	if resp.User.Username != "newuser" {
		t.Errorf("登录后用户名应为 newuser, 得 %s", resp.User.Username)
	}
}
