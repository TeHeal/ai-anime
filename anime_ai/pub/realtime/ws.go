package realtime

import (
	"net/http"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var wsUpgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

// WSHandler WebSocket 升级处理器
type WSHandler struct {
	Hub    *Hub
	Secret string
}

// NewWSHandler 创建 WebSocket 处理器
func NewWSHandler(hub *Hub, secret string) *WSHandler {
	return &WSHandler{Hub: hub, Secret: secret}
}

// Connect 处理 WebSocket 升级，支持 query token 或 Authorization: Bearer
func (h *WSHandler) Connect(c *gin.Context) {
	if h.Hub == nil {
		pkg.InternalError(c, "realtime hub unavailable")
		return
	}

	token := strings.TrimSpace(c.Query("token"))
	if token == "" {
		header := c.GetHeader("Authorization")
		if header != "" {
			parts := strings.SplitN(header, " ", 2)
			if len(parts) == 2 && parts[0] == "Bearer" {
				token = strings.TrimSpace(parts[1])
			}
		}
	}
	if token == "" {
		pkg.Unauthorized(c, "缺少 token")
		return
	}

	claims, err := pkg.ParseToken(h.Secret, token)
	if err != nil {
		pkg.Unauthorized(c, "Token 无效或已过期")
		return
	}

	conn, err := wsUpgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	client := NewClient(claims.UserID, conn)
	client.Run(h.Hub)
}
