package realtime

import "sync"

// Room 管理订阅特定项目的 WebSocket 客户端
type Room struct {
	mu      sync.RWMutex
	clients map[*Client]struct{}
}

func newRoom() *Room {
	return &Room{clients: make(map[*Client]struct{})}
}

func (r *Room) add(c *Client) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.clients[c] = struct{}{}
}

func (r *Room) remove(c *Client) {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.clients, c)
}

func (r *Room) isEmpty() bool {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return len(r.clients) == 0
}

func (r *Room) broadcast(evt Event) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	for c := range r.clients {
		c.Push(evt)
	}
}
