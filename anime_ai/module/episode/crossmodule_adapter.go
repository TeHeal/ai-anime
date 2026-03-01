package episode

import (
	"github.com/TeHeal/ai-anime/anime_ai/module/storyboard"
)

// StoryboardEpisodeReaderAdapter 适配 EpisodeStore 为 storyboard.EpisodeReader
type StoryboardEpisodeReaderAdapter struct {
	store EpisodeStore
}

// NewStoryboardEpisodeReaderAdapter 创建集读取适配器
func NewStoryboardEpisodeReaderAdapter(store EpisodeStore) *StoryboardEpisodeReaderAdapter {
	return &StoryboardEpisodeReaderAdapter{store: store}
}

func (a *StoryboardEpisodeReaderAdapter) FindByID(id string) (storyboard.EpisodeInfo, error) {
	ep, err := a.store.FindByID(id)
	if err != nil {
		return storyboard.EpisodeInfo{}, err
	}
	epID := ep.IDStr
	if epID == "" {
		epID = id
	}
	return storyboard.EpisodeInfo{
		ID:    epID,
		Title: ep.Title,
	}, nil
}
