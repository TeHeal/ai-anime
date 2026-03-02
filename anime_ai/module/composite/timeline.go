package composite

import (
	"context"
	"encoding/json"
	"sort"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
)

// TimelineClip 时间轴上的单个片段
type TimelineClip struct {
	ID        string `json:"id"`
	ShotID    string `json:"shotId"`
	Type      string `json:"type"` // "video", "subtitle", "audio"
	StartMs   int64  `json:"startMs"`
	EndMs     int64  `json:"endMs"`
	SourceURL string `json:"sourceUrl,omitempty"`
	Label     string `json:"label,omitempty"`
	Character string `json:"character,omitempty"`
	Text      string `json:"text,omitempty"`
}

// TimelineTrack 时间轴轨道
type TimelineTrack struct {
	ID    string         `json:"id"`
	Type  string         `json:"type"` // "video", "subtitle", "audio"
	Label string         `json:"label"`
	Clips []TimelineClip `json:"clips"`
}

// Timeline 项目时间轴
type Timeline struct {
	ProjectID  string          `json:"projectId"`
	TotalMs    int64           `json:"totalMs"`
	Tracks     []TimelineTrack `json:"tracks"`
	AutoGen    bool            `json:"autoGen"`
}

// TimelineGenerator 时间轴自动生成器
type TimelineGenerator struct {
	shotReader      crossmodule.ExportShotReader
	shotVideoReader crossmodule.ExportShotVideoReader
}

// NewTimelineGenerator 创建时间轴生成器
func NewTimelineGenerator(
	shotReader crossmodule.ExportShotReader,
	shotVideoReader crossmodule.ExportShotVideoReader,
) *TimelineGenerator {
	return &TimelineGenerator{
		shotReader:      shotReader,
		shotVideoReader: shotVideoReader,
	}
}

// AutoGenerate 自动从镜头数据生成时间轴
func (g *TimelineGenerator) AutoGenerate(ctx context.Context, projectID string) (*Timeline, error) {
	shots, err := g.shotReader.ListShotsByProject(ctx, projectID)
	if err != nil {
		return nil, err
	}

	sort.Slice(shots, func(i, j int) bool { return shots[i].SortIndex < shots[j].SortIndex })

	var videoClips []TimelineClip
	var subtitleClips []TimelineClip
	var cumulativeMs int64

	for _, shot := range shots {
		// 尝试获取视频信息
		var videoURL string
		var durationMs int64

		if g.shotVideoReader != nil {
			videoInfo, err := g.shotVideoReader.GetLatestApprovedVideo(ctx, shot.ID)
			if err == nil && videoInfo != nil {
				videoURL = videoInfo.VideoURL
				if videoInfo.Duration > 0 {
					durationMs = int64(videoInfo.Duration) * 1000
				}
			}
		}

		// 默认时长
		if durationMs <= 0 {
			if shot.Duration > 0 {
				durationMs = int64(shot.Duration) * 1000
			} else {
				durationMs = 5000
			}
		}

		endMs := cumulativeMs + durationMs

		// 视频轨道
		videoClips = append(videoClips, TimelineClip{
			ID:        "v_" + shot.ID,
			ShotID:    shot.ID,
			Type:      "video",
			StartMs:   cumulativeMs,
			EndMs:     endMs,
			SourceURL: videoURL,
			Label:     formatShotLabel(shot),
		})

		// 字幕轨道
		if shot.Dialogue != "" {
			subtitleClips = append(subtitleClips, TimelineClip{
				ID:        "s_" + shot.ID,
				ShotID:    shot.ID,
				Type:      "subtitle",
				StartMs:   cumulativeMs,
				EndMs:     endMs,
				Character: shot.CharacterName,
				Text:      shot.Dialogue,
			})
		}

		cumulativeMs = endMs
	}

	tracks := []TimelineTrack{
		{
			ID:    "track_video",
			Type:  "video",
			Label: "视频轨道",
			Clips: videoClips,
		},
	}

	if len(subtitleClips) > 0 {
		tracks = append(tracks, TimelineTrack{
			ID:    "track_subtitle",
			Type:  "subtitle",
			Label: "字幕轨道",
			Clips: subtitleClips,
		})
	}

	return &Timeline{
		ProjectID: projectID,
		TotalMs:   cumulativeMs,
		Tracks:    tracks,
		AutoGen:   true,
	}, nil
}

// TimelineToJSON 序列化时间轴为 JSON 字符串
func TimelineToJSON(tl *Timeline) (string, error) {
	data, err := json.Marshal(tl)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// TimelineFromJSON 从 JSON 字符串反序列化时间轴
func TimelineFromJSON(data string) (*Timeline, error) {
	var tl Timeline
	if err := json.Unmarshal([]byte(data), &tl); err != nil {
		return nil, err
	}
	return &tl, nil
}

func formatShotLabel(shot crossmodule.ExportShotInfo) string {
	if shot.CharacterName != "" {
		return shot.CharacterName
	}
	return "镜头"
}
