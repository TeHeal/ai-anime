package scene

import (
	"encoding/json"
	"time"
)

// SceneBlockType 内容块类型（README 领域模型）
const (
	BlockTypeAction    = "action"    // 动作描写
	BlockTypeDialogue  = "dialogue"  // 台词
	BlockTypeOS        = "os"        // OS 旁白
	BlockTypeDirection = "direction" // 场景指示
	BlockTypeCloseup   = "closeup"   // 特写
)

// Scene 场实体，属于 Episode，ID 统一为 string (UUID)
type Scene struct {
	ID               string    `json:"id"`
	EpisodeID        string    `json:"episode_id"`
	SceneID          string    `json:"scene_id"`
	Location         string    `json:"location"`
	Time             string    `json:"time"`
	InteriorExterior string    `json:"interior_exterior"`
	CharactersJSON   string    `json:"-"`
	SortIndex        int       `json:"sort_index"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

// GetCharacters 解析角色列表
func (s *Scene) GetCharacters() []string {
	var chars []string
	if s.CharactersJSON != "" {
		_ = json.Unmarshal([]byte(s.CharactersJSON), &chars)
	}
	return chars
}

// SetCharacters 设置角色列表
func (s *Scene) SetCharacters(chars []string) {
	data, _ := json.Marshal(chars)
	s.CharactersJSON = string(data)
}

// SceneBlock 内容块实体，属于 Scene，ID 统一为 string (UUID)
type SceneBlock struct {
	ID        string    `json:"id"`
	SceneID   string    `json:"scene_id"`
	Type      string    `json:"type"`
	Character string    `json:"character"`
	Emotion   string    `json:"emotion"`
	Content   string    `json:"content"`
	SortIndex int       `json:"sort_index"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// SceneResponse 场 API 响应
type SceneResponse struct {
	ID               string       `json:"id"`
	EpisodeID        string       `json:"episode_id"`
	SceneID          string       `json:"scene_id"`
	Location         string       `json:"location"`
	Time             string       `json:"time"`
	InteriorExterior string       `json:"interior_exterior"`
	Characters       []string     `json:"characters"`
	SortIndex        int          `json:"sort_index"`
	Blocks           []SceneBlock `json:"blocks,omitempty"`
	CreatedAt        time.Time    `json:"created_at"`
	UpdatedAt        time.Time    `json:"updated_at"`
}

// ToResponse 转为 API 响应
func (s *Scene) ToResponse(blocks []SceneBlock) SceneResponse {
	return SceneResponse{
		ID:               s.ID,
		EpisodeID:        s.EpisodeID,
		SceneID:          s.SceneID,
		Location:         s.Location,
		Time:             s.Time,
		InteriorExterior: s.InteriorExterior,
		Characters:       s.GetCharacters(),
		SortIndex:        s.SortIndex,
		Blocks:           blocks,
		CreatedAt:        s.CreatedAt,
		UpdatedAt:        s.UpdatedAt,
	}
}
