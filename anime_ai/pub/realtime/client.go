package realtime

import (
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

const (
	writeWait  = 10 * time.Second
	pingPeriod = 30 * time.Second
)

// Client 表示一个 WebSocket 连接
type Client struct {
	UserID string
	conn   *websocket.Conn
	send   chan Event
	once   sync.Once
}

// NewClient 创建客户端
func NewClient(userID string, conn *websocket.Conn) *Client {
	return &Client{
		UserID: userID,
		conn:   conn,
		send:   make(chan Event, 32),
	}
}

// Push 向客户端推送事件（非阻塞）
func (c *Client) Push(evt Event) {
	select {
	case c.send <- evt:
	default:
	}
}

// Run 注册到 Hub 并启动读写循环
func (c *Client) Run(hub *Hub) {
	hub.Register(c)
	go c.writePump(hub)
	c.readPump(hub)
}

func (c *Client) cleanup(hub *Hub) {
	c.once.Do(func() {
		hub.Unregister(c)
		_ = c.conn.Close()
	})
}

func (c *Client) readPump(hub *Hub) {
	defer c.cleanup(hub)

	for {
		if _, _, err := c.conn.ReadMessage(); err != nil {
			return
		}
	}
}

func (c *Client) writePump(hub *Hub) {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.cleanup(hub)
	}()

	for {
		select {
		case evt, ok := <-c.send:
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				_ = c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := c.conn.WriteJSON(evt); err != nil {
				return
			}
		case <-ticker.C:
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
