package character

import (
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// CreateSnapshotRequest 创建快照请求
type CreateSnapshotRequest struct {
	CharacterID        string `json:"character_id" binding:"required"`
	ProjectID          uint   `json:"project_id" binding:"required"`
	StartSceneID       string `json:"start_scene_id"`
	EndSceneID         string `json:"end_scene_id"`
	TriggerEvent       string `json:"trigger_event"`
	Costume            string `json:"costume"`
	Hairstyle          string `json:"hairstyle"`
	PhysicalMarks      string `json:"physical_marks"`
	Accessories        string `json:"accessories"`
	MentalState        string `json:"mental_state"`
	Demeanor           string `json:"demeanor"`
	RelationshipsJSON  string `json:"relationships_json"`
	ComposedAppearance string `json:"composed_appearance"`
	SortIndex          int    `json:"sort_index"`
}

// UpdateSnapshotRequest 更新快照请求
type UpdateSnapshotRequest struct {
	StartSceneID       *string `json:"start_scene_id"`
	EndSceneID         *string `json:"end_scene_id"`
	TriggerEvent       *string `json:"trigger_event"`
	Costume            *string `json:"costume"`
	Hairstyle          *string `json:"hairstyle"`
	PhysicalMarks      *string `json:"physical_marks"`
	Accessories        *string `json:"accessories"`
	MentalState        *string `json:"mental_state"`
	Demeanor           *string `json:"demeanor"`
	RelationshipsJSON  *string `json:"relationships_json"`
	ComposedAppearance *string `json:"composed_appearance"`
	SortIndex          *int    `json:"sort_index"`
}

// CreateSnapshot 创建角色快照
func (s *Service) CreateSnapshot(userID uint, req CreateSnapshotRequest) (*CharacterSnapshot, error) {
	c, err := s.data.FindCharacterByID(req.CharacterID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	snap := &CharacterSnapshot{
		CharacterID:        req.CharacterID,
		ProjectID:          req.ProjectID,
		StartSceneID:       req.StartSceneID,
		EndSceneID:         req.EndSceneID,
		TriggerEvent:       req.TriggerEvent,
		Costume:            req.Costume,
		Hairstyle:          req.Hairstyle,
		PhysicalMarks:      req.PhysicalMarks,
		Accessories:        req.Accessories,
		MentalState:        req.MentalState,
		Demeanor:           req.Demeanor,
		RelationshipsJSON:  req.RelationshipsJSON,
		ComposedAppearance: req.ComposedAppearance,
		SortIndex:          req.SortIndex,
		Source:             "human",
	}
	if err := s.data.CreateSnapshot(snap); err != nil {
		return nil, err
	}
	return snap, nil
}

// GetSnapshot 获取快照
func (s *Service) GetSnapshot(id uint) (*CharacterSnapshot, error) {
	return s.data.FindSnapshotByID(id)
}

// UpdateSnapshot 更新快照
func (s *Service) UpdateSnapshot(id uint, req UpdateSnapshotRequest) (*CharacterSnapshot, error) {
	snap, err := s.data.FindSnapshotByID(id)
	if err != nil {
		return nil, err
	}
	applySnapshotUpdate(snap, req)
	snap.Source = "mixed"
	if err := s.data.UpdateSnapshot(snap); err != nil {
		return nil, err
	}
	return snap, nil
}

func applySnapshotUpdate(s *CharacterSnapshot, req UpdateSnapshotRequest) {
	if req.StartSceneID != nil {
		s.StartSceneID = *req.StartSceneID
	}
	if req.EndSceneID != nil {
		s.EndSceneID = *req.EndSceneID
	}
	if req.TriggerEvent != nil {
		s.TriggerEvent = *req.TriggerEvent
	}
	if req.Costume != nil {
		s.Costume = *req.Costume
	}
	if req.Hairstyle != nil {
		s.Hairstyle = *req.Hairstyle
	}
	if req.PhysicalMarks != nil {
		s.PhysicalMarks = *req.PhysicalMarks
	}
	if req.Accessories != nil {
		s.Accessories = *req.Accessories
	}
	if req.MentalState != nil {
		s.MentalState = *req.MentalState
	}
	if req.Demeanor != nil {
		s.Demeanor = *req.Demeanor
	}
	if req.RelationshipsJSON != nil {
		s.RelationshipsJSON = *req.RelationshipsJSON
	}
	if req.ComposedAppearance != nil {
		s.ComposedAppearance = *req.ComposedAppearance
	}
	if req.SortIndex != nil {
		s.SortIndex = *req.SortIndex
	}
}

// DeleteSnapshot 删除快照
func (s *Service) DeleteSnapshot(id uint) error {
	return s.data.DeleteSnapshot(id)
}

// ListSnapshotsByCharacter 按角色列出快照
func (s *Service) ListSnapshotsByCharacter(characterID string) ([]CharacterSnapshot, error) {
	return s.data.ListSnapshotsByCharacter(characterID)
}

// ListSnapshotsByProject 按项目列出快照
func (s *Service) ListSnapshotsByProject(projectID, userID uint) ([]CharacterSnapshot, error) {
	if s.projectVerifier != nil {
		if err := s.projectVerifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
			return nil, err
		}
	}
	return s.data.ListSnapshotsByProject(projectID)
}
