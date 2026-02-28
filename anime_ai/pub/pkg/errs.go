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
	ErrLocked        = errors.New("ERR_LOCKED") // 任务被他人锁定（README 2.3）
)
