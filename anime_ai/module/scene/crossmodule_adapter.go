package scene

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
)

// SceneBlockReaderAdapter 适配 SceneStore/SceneBlockStore 为 crossmodule.SceneBlockReader
type SceneBlockReaderAdapter struct {
	sceneStore SceneStore
	blockStore SceneBlockStore
}

// NewSceneBlockReaderAdapter 创建场景/块跨模块读取适配器
func NewSceneBlockReaderAdapter(sceneStore SceneStore, blockStore SceneBlockStore) *SceneBlockReaderAdapter {
	return &SceneBlockReaderAdapter{sceneStore: sceneStore, blockStore: blockStore}
}

func (a *SceneBlockReaderAdapter) ListScenesByEpisode(episodeID string) ([]crossmodule.SceneInfo, error) {
	scenes, err := a.sceneStore.ListByEpisode(episodeID)
	if err != nil {
		return nil, err
	}
	out := make([]crossmodule.SceneInfo, len(scenes))
	for i, s := range scenes {
		out[i] = crossmodule.SceneInfo{
			ID:               s.ID,
			Location:         s.Location,
			Time:             s.Time,
			InteriorExterior: s.InteriorExterior,
			Characters:       s.GetCharacters(),
			SortIndex:        s.SortIndex,
		}
	}
	return out, nil
}

func (a *SceneBlockReaderAdapter) ListBlocksByScene(sceneID string) ([]crossmodule.BlockInfo, error) {
	blocks, err := a.blockStore.ListByScene(sceneID)
	if err != nil {
		return nil, err
	}
	out := make([]crossmodule.BlockInfo, len(blocks))
	for i, b := range blocks {
		out[i] = crossmodule.BlockInfo{
			Type:      b.Type,
			Character: b.Character,
			Content:   b.Content,
			SortIndex: b.SortIndex,
		}
	}
	return out, nil
}
