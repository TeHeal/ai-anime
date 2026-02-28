package auth

// User 用户模型，使用 string ID 以兼容 PostgreSQL UUID
type User struct {
	ID           uint   `json:"id"`   // 兼容 MemData
	IDStr        string `json:"-"`    // DB 时使用
	Username     string `json:"username"`
	PasswordHash string `json:"-"`
	DisplayName  string `json:"display_name"`
	Role         string `json:"role"`
}
