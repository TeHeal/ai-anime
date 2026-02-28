package pkg

import (
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
)

// ParseUUID 将 string 转为 pgtype.UUID，无效时返回 pgtype.UUID{Valid: false}
func ParseUUID(s string) pgtype.UUID {
	if s == "" {
		return pgtype.UUID{Valid: false}
	}
	u, err := uuid.Parse(s)
	if err != nil {
		return pgtype.UUID{Valid: false}
	}
	return pgtype.UUID{Bytes: u, Valid: true}
}

// UUIDString 将 pgtype.UUID 转为 string，无效时返回空字符串
func UUIDString(u pgtype.UUID) string {
	if !u.Valid {
		return ""
	}
	return uuid.UUID(u.Bytes).String()
}

// StringToUUID 将 UUID 字符串转为 pgtype.UUID，失败时返回错误
func StringToUUID(s string) (pgtype.UUID, error) {
	u, err := uuid.Parse(s)
	if err != nil {
		return pgtype.UUID{}, fmt.Errorf("无效的 UUID: %w", err)
	}
	return pgtype.UUID{Bytes: u, Valid: true}, nil
}

// UintToUUID 将 uint 转为确定性 pgtype.UUID（用于 project_id/user_id 等迁移期兼容）
// 格式：00000000-0000-0000-0000-{12位十六进制}
func UintToUUID(id uint) pgtype.UUID {
	s := fmt.Sprintf("00000000-0000-0000-0000-%012x", id)
	return ParseUUID(s)
}

// StrToUUID 别名，兼容 project 等模块
func StrToUUID(s string) pgtype.UUID { return ParseUUID(s) }

// UUIDToStr 别名，兼容 project 等模块
func UUIDToStr(u pgtype.UUID) string { return UUIDString(u) }

// UUIDToUint 将确定性 UintToUUID 格式的 UUID 转回 uint，非该格式返回 0
func UUIDToUint(u pgtype.UUID) uint {
	if !u.Valid {
		return 0
	}
	s := uuid.UUID(u.Bytes).String()
	// 格式 00000000-0000-0000-0000-xxxxxxxxxxxx
	if len(s) != 36 {
		return 0
	}
	hexPart := s[24:]
	var v uint64
	_, err := fmt.Sscanf(hexPart, "%x", &v)
	if err != nil {
		return 0
	}
	return uint(v)
}
