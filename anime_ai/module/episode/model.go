package episode

import (
	"strconv"
	"time"
)

// EpisodeStatus 集的生产状态
const (
	EpisodeStatusNotStarted = "not_started"
	EpisodeStatusInProgress = "in_progress"
	EpisodeStatusCompleted  = "completed"
)

// Episode 集实体，属于 Project
type Episode struct {
	ID           uint       `json:"id"`
	IDStr        string     `json:"-"`
	ProjectID    uint       `json:"project_id"`
	ProjectIDStr string     `json:"-"`
	Title        string     `json:"title"`
	SortIndex    int        `json:"sort_index"`
	Summary      string     `json:"summary"`
	Status       string     `json:"status"`
	CurrentStep  int        `json:"current_step"`
	CurrentPhase string     `json:"current_phase"`
	LastActiveAt *time.Time `json:"last_active_at"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

// EpisodeResponse 集 API 响应
type EpisodeResponse struct {
	ID           string     `json:"id"`
	ProjectID    string     `json:"project_id"`
	Title        string     `json:"title"`
	SortIndex    int        `json:"sort_index"`
	Summary      string     `json:"summary"`
	Status       string     `json:"status"`
	CurrentStep  int        `json:"current_step"`
	CurrentPhase string     `json:"current_phase"`
	LastActiveAt *time.Time `json:"last_active_at"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

// ToResponse 转为 API 响应（不含 Scenes 时由调用方填充）
func (e *Episode) ToResponse() EpisodeResponse {
	id, pid := strconv.FormatUint(uint64(e.ID), 10), strconv.FormatUint(uint64(e.ProjectID), 10)
	if e.IDStr != "" {
		id = e.IDStr
	}
	if e.ProjectIDStr != "" {
		pid = e.ProjectIDStr
	}
	return EpisodeResponse{
		ID:           id,
		ProjectID:    pid,
		Title:        e.Title,
		SortIndex:    e.SortIndex,
		Summary:      e.Summary,
		Status:       e.Status,
		CurrentStep:  e.CurrentStep,
		CurrentPhase: e.CurrentPhase,
		LastActiveAt: e.LastActiveAt,
		CreatedAt:    e.CreatedAt,
		UpdatedAt:    e.UpdatedAt,
	}
}
