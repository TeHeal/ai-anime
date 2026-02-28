package pkg

import "errors"

// 业务错误码（README §8.4：统一使用 ERR_XXX 格式）
var (
	ErrNotFound      = errors.New("ERR_NOT_FOUND")
	ErrUnauthorized  = errors.New("ERR_UNAUTHORIZED")
	ErrForbidden     = errors.New("ERR_FORBIDDEN")
	ErrBadRequest    = errors.New("ERR_BAD_REQUEST")
	ErrAlreadyExists = errors.New("ERR_ALREADY_EXISTS")
	ErrInternal      = errors.New("ERR_INTERNAL")

	// 审核相关
	ErrReviewInvalidStatus = errors.New("ERR_REVIEW_INVALID_STATUS")
	ErrReviewInvalidMode   = errors.New("ERR_REVIEW_INVALID_MODE")

	// 任务锁相关
	ErrTaskLocked    = errors.New("ERR_TASK_LOCKED")
	ErrLockNotFound  = errors.New("ERR_LOCK_NOT_FOUND")
	ErrLockExpired   = errors.New("ERR_LOCK_EXPIRED")

	// 认证相关
	ErrInvalidCredentials = errors.New("ERR_INVALID_CREDENTIALS")
	ErrUserExists         = errors.New("ERR_USER_EXISTS")
	ErrPasswordHashFailed = errors.New("ERR_PASSWORD_HASH_FAILED")
	ErrTokenGenFailed     = errors.New("ERR_TOKEN_GEN_FAILED")
)
