package crossmodule

// SceneInfo 场景摘要信息（供分镜生成使用）
type SceneInfo struct {
	ID               string
	Location         string
	Time             string
	InteriorExterior string
	Characters       []string
	SortIndex        int
}

// BlockInfo 内容块摘要信息（供分镜生成使用）
type BlockInfo struct {
	Type      string
	Character string
	Content   string
	SortIndex int
}

// SceneBlockReader 读取场景及内容块数据，供分镜模块跨模块调用
type SceneBlockReader interface {
	ListScenesByEpisode(episodeID string) ([]SceneInfo, error)
	ListBlocksByScene(sceneID string) ([]BlockInfo, error)
}
