package storage

import (
	"fmt"
	"path/filepath"
	"time"
)

// PathParams 结构化路径参数
// 约定：projects/{pid}/episodes/{eid}/scenes/{sid}/shots/{shotId}/{category}/{filename}
//       projects/{pid}/characters/{charId}/{category}/{filename}
//       projects/{pid}/locations/{locId}/{category}/{filename}
type PathParams struct {
	ProjectID   uint
	EpisodeID   *uint
	SceneID     *uint
	ShotID      *uint
	CharacterID *uint
	LocationID  *uint
	Category    string // images, videos, audio
	AssetType   string // shot_image, character_image, etc.
	Version     int
	Extension   string // png, mp4, mp3, etc.
}

// BuildStructuredPath 根据参数生成结构化存储路径
func BuildStructuredPath(p PathParams) string {
	ts := time.Now().Format("20060102150405")
	filename := fmt.Sprintf("%s_v%d_%s%s", p.AssetType, p.Version, ts, p.Extension)

	if p.ShotID != nil && p.SceneID != nil && p.EpisodeID != nil {
		return filepath.Join(
			fmt.Sprintf("projects/%d", p.ProjectID),
			fmt.Sprintf("episodes/%d", *p.EpisodeID),
			fmt.Sprintf("scenes/%d", *p.SceneID),
			fmt.Sprintf("shots/%d", *p.ShotID),
			p.Category,
			filename,
		)
	}

	if p.CharacterID != nil {
		return filepath.Join(
			fmt.Sprintf("projects/%d", p.ProjectID),
			fmt.Sprintf("characters/%d", *p.CharacterID),
			p.Category,
			filename,
		)
	}

	if p.LocationID != nil {
		return filepath.Join(
			fmt.Sprintf("projects/%d", p.ProjectID),
			fmt.Sprintf("locations/%d", *p.LocationID),
			p.Category,
			filename,
		)
	}

	// 兜底：项目级通用路径
	return filepath.Join(
		fmt.Sprintf("projects/%d", p.ProjectID),
		p.Category,
		filename,
	)
}

// ExtensionForType 根据资产类型返回默认扩展名
func ExtensionForType(assetType string) string {
	switch assetType {
	case "character_image", "location_image", "shot_image", "reference_image":
		return ".png"
	case "shot_video", "export_video":
		return ".mp4"
	case "voiceover":
		return ".mp3"
	case "bgm", "sfx":
		return ".mp3"
	default:
		return ".bin"
	}
}

// CategoryForType 根据资产类型返回存储分类目录
func CategoryForType(assetType string) string {
	switch assetType {
	case "character_image", "location_image", "shot_image", "reference_image":
		return "images"
	case "shot_video", "export_video":
		return "videos"
	case "voiceover", "bgm", "sfx":
		return "audio"
	default:
		return "misc"
	}
}
