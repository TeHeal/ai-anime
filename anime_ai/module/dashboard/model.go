package dashboard

import "time"

// Dashboard 仪表盘聚合数据（与 Flutter Dashboard 模型对齐）
type Dashboard struct {
	TotalEpisodes  int                    `json:"totalEpisodes"`
	StatusCounts   map[string]int          `json:"statusCounts"`
	PhaseCounts    map[string]StepCount    `json:"phaseCounts"`
	AssetSummary   *AssetSummary           `json:"assetSummary,omitempty"`
	ReviewSummary  *ReviewSummary         `json:"reviewSummary,omitempty"`
	Episodes       []DashboardEpisode     `json:"episodes"`
}

// StepCount 阶段完成数
type StepCount struct {
	Done  int `json:"done"`
	Total int `json:"total"`
}

// AssetSummary 资产概况
type AssetSummary struct {
	CharactersTotal     int `json:"charactersTotal"`
	CharactersConfirmed int `json:"charactersConfirmed"`
	LocationsTotal      int `json:"locationsTotal"`
	LocationsConfirmed  int `json:"locationsConfirmed"`
}

// ReviewSummary 镜图审核概况
type ReviewSummary struct {
	TotalShots     int `json:"totalShots"`
	PendingReview  int `json:"pendingReview"`
	Approved       int `json:"approved"`
	Rejected       int `json:"rejected"`
}

// DashboardEpisode 仪表盘集项
type DashboardEpisode struct {
	ID              string          `json:"id"`
	Title           string          `json:"title"`
	SortIndex       int             `json:"sortIndex"`
	Summary         string          `json:"summary"`
	Status          string          `json:"status"`
	CurrentStep     int             `json:"currentStep"`
	CurrentPhase    string          `json:"currentPhase"`
	SceneCount      int             `json:"sceneCount"`
	CharacterNames  []string        `json:"characterNames"`
	LastActiveAt    *time.Time      `json:"lastActiveAt,omitempty"`
	CreatedAt       *time.Time      `json:"createdAt,omitempty"`
	Progress        *EpisodeProgress `json:"progress,omitempty"`
}

// EpisodeProgress 集进度（与 Flutter EpisodeProgress 对齐）
type EpisodeProgress struct {
	ID             string `json:"id,omitempty"`
	EpisodeID      string `json:"episodeId,omitempty"`
	ProjectID      string `json:"projectId,omitempty"`
	StoryDone      bool   `json:"storyDone"`
	AssetsDone     bool   `json:"assetsDone"`
	ScriptDone     bool   `json:"scriptDone"`
	StoryboardDone bool   `json:"storyboardDone"`
	ShotsDone      bool   `json:"shotsDone"`
	EpisodeDone    bool   `json:"episodeDone"`
	StoryPct       int    `json:"storyPct"`
	AssetsPct      int    `json:"assetsPct"`
	ScriptPct      int    `json:"scriptPct"`
	StoryboardPct  int    `json:"storyboardPct"`
	ShotsPct       int    `json:"shotsPct"`
	EpisodePct     int    `json:"episodePct"`
	CurrentStep    int    `json:"currentStep"`
	CurrentPhase   string `json:"currentPhase"`
	OverallPct     int    `json:"overallPct"`
}
