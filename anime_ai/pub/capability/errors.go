package capability

import (
	"errors"
	"fmt"
)

// ErrorCode 稳定的、与 Provider 无关的能力错误码
type ErrorCode string

const (
	ErrAuthFailed  ErrorCode = "ERR_AUTH_FAILED"
	ErrRateLimited ErrorCode = "ERR_RATE_LIMITED"
	ErrTimeout     ErrorCode = "ERR_TIMEOUT"
	ErrUpstream    ErrorCode = "ERR_UPSTREAM"
	ErrBadResponse ErrorCode = "ERR_BAD_RESPONSE"
	ErrNotAvail    ErrorCode = "ERR_NOT_AVAILABLE"
)

// CapabilityError 各 Provider 使用的规范化错误
type CapabilityError struct {
	Code    ErrorCode
	Message string
	Cause   error
}

func (e *CapabilityError) Error() string {
	if e == nil {
		return ""
	}
	if e.Cause == nil {
		return fmt.Sprintf("%s: %s", e.Code, e.Message)
	}
	return fmt.Sprintf("%s: %s: %v", e.Code, e.Message, e.Cause)
}

func (e *CapabilityError) Unwrap() error {
	if e == nil {
		return nil
	}
	return e.Cause
}

// Wrap 包装错误为 CapabilityError
func Wrap(code ErrorCode, message string, cause error) *CapabilityError {
	return &CapabilityError{
		Code:    code,
		Message: message,
		Cause:   cause,
	}
}

// CodeOf 从错误中提取 ErrorCode
func CodeOf(err error) ErrorCode {
	var ce *CapabilityError
	if errors.As(err, &ce) {
		return ce.Code
	}
	return ErrUpstream
}
