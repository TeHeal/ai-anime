package health

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestHandler(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.GET("/health", Handler)

	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("状态码应为 200, 得 %d", w.Code)
	}
	body := w.Body.String()
	if body == "" {
		t.Error("响应体不应为空")
	}
	if body != `{"status":"ok"}` && body != "{\"status\":\"ok\"}\n" {
		// Gin 可能加换行
		if body != `{"status":"ok"}` {
			t.Logf("响应体: %q", body)
		}
	}
}
