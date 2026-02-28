package pkg

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
)

// BizError 业务错误，用于返回给前端的可读消息
type BizError struct {
	Msg string
}

func (e *BizError) Error() string { return e.Msg }

// NewBizError 创建业务错误
func NewBizError(msg string) *BizError { return &BizError{Msg: msg} }

// Response 统一 API 响应结构
type Response struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// OK 成功响应
func OK(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Code:    0,
		Message: "ok",
		Data:    data,
	})
}

// Created 创建成功响应
func Created(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, Response{
		Code:    0,
		Message: "created",
		Data:    data,
	})
}

// Fail 失败响应
func Fail(c *gin.Context, httpCode int, message string) {
	c.JSON(httpCode, Response{
		Code:    -1,
		Message: message,
	})
}

// FailWithCode 带自定义 code 的失败响应
func FailWithCode(c *gin.Context, httpCode int, code int, message string) {
	c.JSON(httpCode, Response{
		Code:    code,
		Message: message,
	})
}

// BadRequest 400 错误
func BadRequest(c *gin.Context, message string) {
	Fail(c, http.StatusBadRequest, message)
}

// Unauthorized 401 错误
func Unauthorized(c *gin.Context, message string) {
	Fail(c, http.StatusUnauthorized, message)
}

// Forbidden 403 错误
func Forbidden(c *gin.Context, message string) {
	Fail(c, http.StatusForbidden, message)
}

// NotFound 404 错误
func NotFound(c *gin.Context, message string) {
	Fail(c, http.StatusNotFound, message)
}

// InternalError 500 错误
func InternalError(c *gin.Context, message string) {
	Fail(c, http.StatusInternalServerError, message)
}

// HandleError 根据错误类型返回对应 HTTP 响应（README §8.4 错误透传）
func HandleError(c *gin.Context, err error) {
	var biz *BizError
	if errors.As(err, &biz) {
		BadRequest(c, biz.Msg)
		return
	}
	if errors.Is(err, ErrNotFound) {
		NotFound(c, "资源不存在")
		return
	}
	if errors.Is(err, ErrBadRequest) {
		BadRequest(c, "请求参数错误")
		return
	}
	if errors.Is(err, ErrLocked) {
		Forbidden(c, "任务被他人锁定")
		return
	}
	if errors.Is(err, ErrUnauthorized) {
		Unauthorized(c, "未授权")
		return
	}
	if errors.Is(err, ErrForbidden) {
		Forbidden(c, "无权限")
		return
	}
	if errors.Is(err, ErrAlreadyExists) {
		Fail(c, http.StatusConflict, "资源已存在")
		return
	}
	InternalError(c, "服务器内部错误")
}
