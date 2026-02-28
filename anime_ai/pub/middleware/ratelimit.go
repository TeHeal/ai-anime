package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
)

type visitor struct {
	tokens   float64
	lastSeen time.Time
}

// RateLimiter 按 IP 的令牌桶限流器。burst 为最大突发量，rps 为每秒补充速率。
type RateLimiter struct {
	mu       sync.Mutex
	visitors map[string]*visitor
	burst    float64
	rps      float64
}

// NewRateLimiter 创建限流器
func NewRateLimiter(rps float64, burst int) *RateLimiter {
	rl := &RateLimiter{
		visitors: make(map[string]*visitor),
		burst:    float64(burst),
		rps:      rps,
	}
	go rl.cleanup()
	return rl
}

func (rl *RateLimiter) allow(ip string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	v, ok := rl.visitors[ip]
	if !ok {
		rl.visitors[ip] = &visitor{tokens: rl.burst - 1, lastSeen: time.Now()}
		return true
	}

	elapsed := time.Since(v.lastSeen).Seconds()
	v.lastSeen = time.Now()
	v.tokens += elapsed * rl.rps
	if v.tokens > rl.burst {
		v.tokens = rl.burst
	}

	if v.tokens < 1 {
		return false
	}
	v.tokens--
	return true
}

func (rl *RateLimiter) cleanup() {
	for {
		time.Sleep(5 * time.Minute)
		rl.mu.Lock()
		for ip, v := range rl.visitors {
			if time.Since(v.lastSeen) > 10*time.Minute {
				delete(rl.visitors, ip)
			}
		}
		rl.mu.Unlock()
	}
}

// RateLimit 全局按 IP 限流中间件
func RateLimit(rps float64, burst int) gin.HandlerFunc {
	limiter := NewRateLimiter(rps, burst)
	return func(c *gin.Context) {
		if !limiter.allow(c.ClientIP()) {
			pkg.Fail(c, http.StatusTooManyRequests, "请求过于频繁，请稍后再试")
			c.Abort()
			return
		}
		c.Next()
	}
}

// LoginRateLimit 登录接口专用限流（更严格）
func LoginRateLimit() gin.HandlerFunc {
	return RateLimit(1, 5) // 1 req/s, burst 5
}
