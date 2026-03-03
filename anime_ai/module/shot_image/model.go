package shot_image

import (
	"anime_ai/pub/crossmodule"
)

// ShotImage 镜图实体，与 crossmodule.ShotImage 对齐
type ShotImage = crossmodule.ShotImage

// GenerateConfig 镜图生成配置
type GenerateConfig struct {
	GlobalPrompt    string `json:"global_prompt"`
	NegativePrompt  string `json:"negative_prompt"`
	Provider        string `json:"provider"`
	Model           string `json:"model"`
	OutputCount     int    `json:"output_count"`
	AspectRatio     string `json:"aspect_ratio"`
	CardMode        bool   `json:"card_mode"`
	Width           int    `json:"width"`
	Height          int    `json:"height"`
	IncludeAdjacent bool   `json:"include_adjacent"`
}
