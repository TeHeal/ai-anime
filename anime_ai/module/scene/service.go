package scene

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// DummyEpisodeReader 占位实现，返回 episodeID 作为 projectID（开发用）
type DummyEpisodeReader struct{}

func (DummyEpisodeReader) GetProjectIDByEpisode(episodeID string) (string, error) {
	return episodeID, nil
}

// DummyProjectVerifier 占位实现
type DummyProjectVerifier struct{}

func (DummyProjectVerifier) Verify(projectID, userID string) error { return nil }

// Service 场业务逻辑层
type Service struct {
	sceneStore      SceneStore
	blockStore      SceneBlockStore
	episodeReader   crossmodule.EpisodeReader
	projectVerifier crossmodule.ProjectVerifier
}

// NewService 创建场服务
func NewService(
	sceneStore SceneStore,
	blockStore SceneBlockStore,
	episodeReader crossmodule.EpisodeReader,
	projectVerifier crossmodule.ProjectVerifier,
) *Service {
	if episodeReader == nil {
		episodeReader = DummyEpisodeReader{}
	}
	if projectVerifier == nil {
		projectVerifier = DummyProjectVerifier{}
	}
	return &Service{
		sceneStore:      sceneStore,
		blockStore:      blockStore,
		episodeReader:   episodeReader,
		projectVerifier: projectVerifier,
	}
}

// CreateSceneRequest 创建场请求
type CreateSceneRequest struct {
	SceneID          string   `json:"scene_id" binding:"max=16"`
	Location         string   `json:"location" binding:"max=128"`
	Time             string   `json:"time" binding:"max=32"`
	InteriorExterior string   `json:"interior_exterior" binding:"max=8"`
	Characters       []string `json:"characters"`
}

// UpdateSceneRequest 更新场请求
type UpdateSceneRequest struct {
	SceneID          *string  `json:"scene_id" binding:"omitempty,max=16"`
	Location         *string  `json:"location" binding:"omitempty,max=128"`
	Time             *string  `json:"time" binding:"omitempty,max=32"`
	InteriorExterior *string  `json:"interior_exterior" binding:"omitempty,max=8"`
	Characters       []string `json:"characters"`
	SortIndex        *int     `json:"sort_index"`
}

// CreateBlockRequest 创建块请求
type CreateBlockRequest struct {
	Type      string `json:"type" binding:"required,max=16"`
	Character string `json:"character" binding:"max=64"`
	Emotion   string `json:"emotion" binding:"max=128"`
	Content   string `json:"content" binding:"max=65535"`
}

// UpdateBlockRequest 更新块请求
type UpdateBlockRequest struct {
	Type      *string `json:"type" binding:"omitempty,max=16"`
	Character *string `json:"character" binding:"omitempty,max=64"`
	Emotion   *string `json:"emotion" binding:"omitempty,max=128"`
	Content   *string `json:"content"`
	SortIndex *int    `json:"sort_index"`
}

// BulkSaveBlocksRequest 批量保存块请求
type BulkSaveBlocksRequest struct {
	Blocks []CreateBlockRequest `json:"blocks" binding:"required,dive"`
}

// ReorderScenesRequest 场排序请求
type ReorderScenesRequest struct {
	OrderedIDs []string `json:"ordered_ids" binding:"required"`
}

// ReorderBlocksRequest 块排序请求
type ReorderBlocksRequest struct {
	OrderedIDs []string `json:"ordered_ids" binding:"required"`
}

func (s *Service) verifyEpisode(episodeID, userID string) error {
	projectID, err := s.episodeReader.GetProjectIDByEpisode(episodeID)
	if err != nil {
		return err
	}
	return s.projectVerifier.Verify(projectID, userID)
}

// Create 创建场
func (s *Service) Create(episodeID, userID string, req CreateSceneRequest) (*SceneResponse, error) {
	if err := s.verifyEpisode(episodeID, userID); err != nil {
		return nil, err
	}
	count, _ := s.sceneStore.CountByEpisode(episodeID)
	sc := &Scene{
		EpisodeID:        episodeID,
		SceneID:          req.SceneID,
		Location:         req.Location,
		Time:             req.Time,
		InteriorExterior: req.InteriorExterior,
		SortIndex:        int(count),
	}
	sc.SetCharacters(req.Characters)
	if err := s.sceneStore.Create(sc); err != nil {
		return nil, err
	}
	blocks, _ := s.blockStore.ListByScene(sc.ID)
	return ptr(sc.ToResponse(blocks)), nil
}

// Get 获取场
func (s *Service) Get(sceneID, episodeID, userID string) (*SceneResponse, error) {
	if err := s.verifyEpisode(episodeID, userID); err != nil {
		return nil, err
	}
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return nil, err
	}
	if sc.EpisodeID != episodeID {
		return nil, pkg.ErrNotFound
	}
	blocks, _ := s.blockStore.ListByScene(sc.ID)
	return ptr(sc.ToResponse(blocks)), nil
}

// List 列出场
func (s *Service) List(episodeID, userID string) ([]SceneResponse, error) {
	if err := s.verifyEpisode(episodeID, userID); err != nil {
		return nil, err
	}
	scenes, err := s.sceneStore.ListByEpisode(episodeID)
	if err != nil {
		return nil, err
	}
	resp := make([]SceneResponse, len(scenes))
	for i, sc := range scenes {
		blocks, _ := s.blockStore.ListByScene(sc.ID)
		resp[i] = sc.ToResponse(blocks)
	}
	return resp, nil
}

// Update 更新场
func (s *Service) Update(sceneID, episodeID, userID string, req UpdateSceneRequest) (*SceneResponse, error) {
	if err := s.verifyEpisode(episodeID, userID); err != nil {
		return nil, err
	}
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return nil, err
	}
	if sc.EpisodeID != episodeID {
		return nil, pkg.ErrNotFound
	}
	if req.SceneID != nil {
		sc.SceneID = *req.SceneID
	}
	if req.Location != nil {
		sc.Location = *req.Location
	}
	if req.Time != nil {
		sc.Time = *req.Time
	}
	if req.InteriorExterior != nil {
		sc.InteriorExterior = *req.InteriorExterior
	}
	if req.Characters != nil {
		sc.SetCharacters(req.Characters)
	}
	if req.SortIndex != nil {
		sc.SortIndex = *req.SortIndex
	}
	if err := s.sceneStore.Update(sc); err != nil {
		return nil, err
	}
	blocks, _ := s.blockStore.ListByScene(sc.ID)
	return ptr(sc.ToResponse(blocks)), nil
}

// Delete 删除场
func (s *Service) Delete(sceneID, episodeID, userID string) error {
	if err := s.verifyEpisode(episodeID, userID); err != nil {
		return err
	}
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return err
	}
	if sc.EpisodeID != episodeID {
		return pkg.ErrNotFound
	}
	_ = s.blockStore.DeleteByScene(sceneID)
	return s.sceneStore.Delete(sceneID)
}

// Reorder 排序场
func (s *Service) Reorder(episodeID, userID string, req ReorderScenesRequest) error {
	if err := s.verifyEpisode(episodeID, userID); err != nil {
		return err
	}
	return s.sceneStore.ReorderByEpisode(episodeID, req.OrderedIDs)
}

// SaveBlocks 批量保存块（替换全场块）
func (s *Service) SaveBlocks(sceneID, episodeID, userID string, req BulkSaveBlocksRequest) ([]SceneBlock, error) {
	if err := s.verifyEpisode(episodeID, userID); err != nil {
		return nil, err
	}
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return nil, err
	}
	if sc.EpisodeID != episodeID {
		return nil, pkg.ErrNotFound
	}
	_ = s.blockStore.DeleteByScene(sceneID)
	blocks := make([]SceneBlock, len(req.Blocks))
	for i, b := range req.Blocks {
		blocks[i] = SceneBlock{
			SceneID:   sceneID,
			Type:      b.Type,
			Character: b.Character,
			Emotion:   b.Emotion,
			Content:   b.Content,
			SortIndex: i,
		}
	}
	if err := s.blockStore.BulkCreate(blocks); err != nil {
		return nil, err
	}
	return s.blockStore.ListByScene(sceneID)
}

// CreateBlock 创建块
func (s *Service) CreateBlock(sceneID, userID string, req CreateBlockRequest) (*SceneBlock, error) {
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return nil, err
	}
	if err := s.verifyEpisode(sc.EpisodeID, userID); err != nil {
		return nil, err
	}
	count, _ := s.blockStore.CountByScene(sceneID)
	b := &SceneBlock{
		SceneID:   sceneID,
		Type:      req.Type,
		Character: req.Character,
		Emotion:   req.Emotion,
		Content:   req.Content,
		SortIndex: int(count),
	}
	if err := s.blockStore.Create(b); err != nil {
		return nil, err
	}
	return b, nil
}

// UpdateBlock 更新块
func (s *Service) UpdateBlock(blockID, sceneID, userID string, req UpdateBlockRequest) (*SceneBlock, error) {
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return nil, err
	}
	if err := s.verifyEpisode(sc.EpisodeID, userID); err != nil {
		return nil, err
	}
	b, err := s.blockStore.FindByID(blockID)
	if err != nil {
		return nil, err
	}
	if b.SceneID != sceneID {
		return nil, pkg.ErrNotFound
	}
	if req.Type != nil {
		b.Type = *req.Type
	}
	if req.Character != nil {
		b.Character = *req.Character
	}
	if req.Emotion != nil {
		b.Emotion = *req.Emotion
	}
	if req.Content != nil {
		b.Content = *req.Content
	}
	if req.SortIndex != nil {
		b.SortIndex = *req.SortIndex
	}
	if err := s.blockStore.Update(b); err != nil {
		return nil, err
	}
	return b, nil
}

// DeleteBlock 删除块
func (s *Service) DeleteBlock(blockID, sceneID, userID string) error {
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return err
	}
	if err := s.verifyEpisode(sc.EpisodeID, userID); err != nil {
		return err
	}
	b, err := s.blockStore.FindByID(blockID)
	if err != nil {
		return err
	}
	if b.SceneID != sceneID {
		return pkg.ErrNotFound
	}
	return s.blockStore.Delete(blockID)
}

// ReorderBlocks 排序块
func (s *Service) ReorderBlocks(sceneID, userID string, req ReorderBlocksRequest) error {
	sc, err := s.sceneStore.FindByID(sceneID)
	if err != nil {
		return err
	}
	if err := s.verifyEpisode(sc.EpisodeID, userID); err != nil {
		return err
	}
	return s.blockStore.ReorderByScene(sceneID, req.OrderedIDs)
}

func ptr[T any](v T) *T { return &v }
