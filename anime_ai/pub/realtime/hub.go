package realtime

import (
	"sync"
	"sync/atomic"
	"time"

	"go.uber.org/zap"
)

// Hub 管理所有 WebSocket 连接与房间，ID 使用 string 兼容 UUID
type Hub struct {
	log *zap.Logger

	mu      sync.RWMutex
	clients map[string]map[*Client]struct{}
	seq     atomic.Uint64

	roomsMu sync.RWMutex
	rooms   map[string]*Room // project_id → Room
}

// NewHub 创建 Hub
func NewHub(log *zap.Logger) *Hub {
	return &Hub{
		log:     log,
		clients: make(map[string]map[*Client]struct{}),
		rooms:   make(map[string]*Room),
	}
}

// Register 注册客户端
func (h *Hub) Register(c *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.clients[c.UserID]; !ok {
		h.clients[c.UserID] = make(map[*Client]struct{})
	}
	h.clients[c.UserID][c] = struct{}{}
	h.log.Debug("realtime client connected", zap.String("user_id", c.UserID))
	c.Push(h.decorate(Event{
		Type:      "system.connected",
		UserIDStr: c.UserID,
		Payload: map[string]any{
			"connected": true,
		},
	}))
}

// Unregister 注销客户端
func (h *Hub) Unregister(c *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if set, ok := h.clients[c.UserID]; ok {
		delete(set, c)
		if len(set) == 0 {
			delete(h.clients, c.UserID)
		}
	}

	h.leaveAllRooms(c)
	h.log.Debug("realtime client disconnected", zap.String("user_id", c.UserID))
}

// JoinRoom 将客户端加入项目房间
func (h *Hub) JoinRoom(c *Client, projectID string) {
	h.roomsMu.Lock()
	defer h.roomsMu.Unlock()

	room, ok := h.rooms[projectID]
	if !ok {
		room = newRoom()
		h.rooms[projectID] = room
	}
	room.add(c)

	h.log.Debug("client joined room",
		zap.String("user_id", c.UserID),
		zap.String("project_id", projectID))
}

// LeaveRoom 将客户端移出项目房间
func (h *Hub) LeaveRoom(c *Client, projectID string) {
	h.roomsMu.Lock()
	defer h.roomsMu.Unlock()

	if room, ok := h.rooms[projectID]; ok {
		room.remove(c)
		if room.isEmpty() {
			delete(h.rooms, projectID)
		}
	}
}

func (h *Hub) leaveAllRooms(c *Client) {
	h.roomsMu.Lock()
	defer h.roomsMu.Unlock()

	for pid, room := range h.rooms {
		room.remove(c)
		if room.isEmpty() {
			delete(h.rooms, pid)
		}
	}
}

// Broadcast 广播事件。路由优先级：
// 1. 若 ProjectIDStr 非空 → 广播给项目房间成员；房间为空时回退到按 UserIDStr
// 2. 若 UserIDStr 非空 → 广播给该用户的所有连接
// 3. 否则 → 广播给所有已连接客户端
func (h *Hub) Broadcast(evt Event) {
	evt = h.decorate(evt)

	if evt.ProjectIDStr != "" {
		sent := false
		h.roomsMu.RLock()
		if room, ok := h.rooms[evt.ProjectIDStr]; ok && !room.isEmpty() {
			room.broadcast(evt)
			sent = true
		}
		h.roomsMu.RUnlock()
		if sent {
			return
		}
		// 房间为空或不存在时回退到按用户广播
	}

	h.mu.RLock()
	defer h.mu.RUnlock()

	if evt.UserIDStr != "" {
		h.broadcastToSet(h.clients[evt.UserIDStr], evt)
		return
	}

	for _, set := range h.clients {
		h.broadcastToSet(set, evt)
	}
}

// BroadcastTaskProgress 推送任务进度（前端订阅 task_progress 事件）
func (h *Hub) BroadcastTaskProgress(userID string, projectID *string, taskID string, payload interface{}) {
	h.Broadcast(Event{
		Type:         "task_progress",
		UserIDStr:    userID,
		ProjectIDStr: ptrToStr(projectID),
		TaskID:       taskID,
		Timestamp:    time.Now(),
		Payload:      payload,
	})
}

// BroadcastTaskComplete 推送任务完成事件（前端订阅 task_complete 事件）
func (h *Hub) BroadcastTaskComplete(userID string, projectID *string, taskID string, payload interface{}) {
	h.Broadcast(Event{
		Type:         "task_complete",
		UserIDStr:    userID,
		ProjectIDStr: ptrToStr(projectID),
		TaskID:       taskID,
		Timestamp:    time.Now(),
		Payload:      payload,
	})
}

// BroadcastTaskError 推送任务失败事件（前端可订阅 task_error 事件）
func (h *Hub) BroadcastTaskError(userID string, projectID *string, taskID string, payload interface{}) {
	h.Broadcast(Event{
		Type:         "task_error",
		UserIDStr:    userID,
		ProjectIDStr: ptrToStr(projectID),
		TaskID:       taskID,
		Timestamp:    time.Now(),
		Payload:      payload,
	})
}

// BroadcastResourceCreated 推送素材创建完成事件（素材页订阅 resource_created 刷新列表）
func (h *Hub) BroadcastResourceCreated(userID string, resourceID string, resourceType string) {
	h.Broadcast(Event{
		Type:      "resource_created",
		UserIDStr: userID,
		TaskID:    resourceID,
		Timestamp: time.Now(),
		Payload: map[string]any{
			"resource_id":   resourceID,
			"resource_type": resourceType,
		},
	})
}

func ptrToStr(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

func (h *Hub) decorate(evt Event) Event {
	if evt.Timestamp.IsZero() {
		evt.Timestamp = time.Now()
	}
	evt.Version = h.seq.Add(1)
	return evt
}

func (h *Hub) broadcastToSet(set map[*Client]struct{}, evt Event) {
	for c := range set {
		select {
		case c.send <- evt:
		default:
		}
	}
}
