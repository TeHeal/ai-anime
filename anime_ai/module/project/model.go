package project

import (
	"encoding/json"
	"strconv"
	"time"
)

// ProjectConfig 项目配置（画幅、模型、旁白等）
type ProjectConfig struct {
	Ratio        string `json:"ratio"`
	ImageModel   string `json:"image_model"`
	VideoModel   string `json:"video_model"`
	Narration    string `json:"narration"`
	ShotDuration string `json:"shot_duration"`
	VideoStyle   string `json:"video_style"`
	LipSyncMode  string `json:"lip_sync_mode"`
}

// Project 项目实体
// 使用 string ID 以兼容 PostgreSQL UUID；MemData 使用 "1","2" 等数字串
type Project struct {
	ID        uint      `json:"id"`         // 兼容旧 API，MemData 时使用
	IDStr     string    `json:"-"`          // DB 时使用 UUID 串
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	UserID     uint   `json:"user_id"`     // 兼容旧 API
	UserIDStr  string `json:"-"`           // DB 时使用
	Name       string `json:"name"`
	Story          string `json:"story"`
	StoryMode      string `json:"story_mode"` // full_script, creative
	ConfigJSON     string `json:"-"`
	PropsJSON      string `json:"-"`
	StoryboardJSON string `json:"-"`
	MirrorMode     bool   `json:"mirror_mode"`

	TeamID     uint   `json:"team_id"`
	Visibility string `json:"visibility"` // private, team
	Version    int    `json:"version"`

	StoryLocked    bool       `json:"story_locked"`
	StoryLockedAt  *time.Time `json:"story_locked_at"`
	AssetsLocked   bool       `json:"assets_locked"`
	AssetsLockedAt *time.Time `json:"assets_locked_at"`
	ScriptLocked   bool       `json:"script_locked"`
	ScriptLockedAt *time.Time `json:"script_locked_at"`
}

// GetConfig 解析配置 JSON
func (p *Project) GetConfig() ProjectConfig {
	var cfg ProjectConfig
	if p.ConfigJSON != "" {
		_ = json.Unmarshal([]byte(p.ConfigJSON), &cfg)
	}
	return cfg
}

// SetConfig 序列化配置为 JSON
func (p *Project) SetConfig(cfg ProjectConfig) {
	data, _ := json.Marshal(cfg)
	p.ConfigJSON = string(data)
}

// LockStatus 阶段锁定状态
type LockStatus struct {
	StoryLocked    bool       `json:"story_locked"`
	StoryLockedAt  *time.Time `json:"story_locked_at"`
	AssetsLocked   bool       `json:"assets_locked"`
	AssetsLockedAt *time.Time `json:"assets_locked_at"`
	ScriptLocked   bool       `json:"script_locked"`
	ScriptLockedAt *time.Time `json:"script_locked_at"`
}

// ProjectResponse 项目 API 响应结构
type ProjectResponse struct {
	ID         string        `json:"id"` // string 以兼容 UUID
	CreatedAt  time.Time     `json:"created_at"`
	UpdatedAt  time.Time     `json:"updated_at"`
	UserID     string        `json:"user_id"`
	Name       string        `json:"name"`
	Story      string        `json:"story"`
	StoryMode  string        `json:"story_mode"`
	Config     ProjectConfig `json:"config"`
	MirrorMode bool          `json:"mirror_mode"`
	LockStatus LockStatus    `json:"lock_status"`
}

// ToResponse 转换为 API 响应
func (p *Project) ToResponse() ProjectResponse {
	id, uid := strconv.FormatUint(uint64(p.ID), 10), strconv.FormatUint(uint64(p.UserID), 10)
	if p.IDStr != "" {
		id, uid = p.IDStr, p.UserIDStr
	}
	return ProjectResponse{
		ID:         id,
		CreatedAt:  p.CreatedAt,
		UpdatedAt:  p.UpdatedAt,
		UserID:     uid,
		Name:       p.Name,
		Story:      p.Story,
		StoryMode:  p.StoryMode,
		Config:     p.GetConfig(),
		MirrorMode: p.MirrorMode,
		LockStatus: LockStatus{
			StoryLocked:    p.StoryLocked,
			StoryLockedAt:  p.StoryLockedAt,
			AssetsLocked:   p.AssetsLocked,
			AssetsLockedAt: p.AssetsLockedAt,
			ScriptLocked:   p.ScriptLocked,
			ScriptLockedAt: p.ScriptLockedAt,
		},
	}
}

// ProjectMember 项目成员
type ProjectMember struct {
	ID          uint       `json:"id"`
	IDStr       string     `json:"-"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	ProjectID   uint       `json:"project_id"`
	ProjectIDStr string    `json:"-"`
	UserID      uint       `json:"user_id"`
	UserIDStr   string     `json:"-"`
	Role        string     `json:"role"` // owner, editor, viewer
	JoinedAt    *time.Time `json:"joined_at"`
}
