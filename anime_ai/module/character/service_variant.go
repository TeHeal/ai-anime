package character

import (
	"encoding/json"
	"fmt"
)

// Variant 变体结构
type Variant struct {
	Label          string `json:"label"`
	EpisodeID      int    `json:"episode_id"`
	SceneID        string `json:"scene_id"`
	Appearance     string `json:"appearance"`
	ReferenceImage string `json:"reference_image"`
	Status         string `json:"status"`
}

// AddVariantRequest 添加变体请求
type AddVariantRequest struct {
	Label          string `json:"label" binding:"required"`
	EpisodeID      int    `json:"episode_id"`
	SceneID        string `json:"scene_id"`
	Appearance     string `json:"appearance"`
	ReferenceImage string `json:"reference_image"`
}

// UpdateVariantRequest 更新变体请求
type UpdateVariantRequest struct {
	Label          *string `json:"label"`
	Appearance     *string `json:"appearance"`
	ReferenceImage *string `json:"reference_image"`
	Status         *string `json:"status"`
}

func (s *Service) getVariants(c *Character) []Variant {
	var v []Variant
	if c.VariantsJSON != "" {
		_ = json.Unmarshal([]byte(c.VariantsJSON), &v)
	}
	return v
}

func (s *Service) saveVariants(c *Character, v []Variant) error {
	data, _ := json.Marshal(v)
	c.VariantsJSON = string(data)
	return s.data.UpdateCharacter(c)
}

// AddVariant 添加变体
func (s *Service) AddVariant(charID string, userID uint, req AddVariantRequest) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	variants := s.getVariants(c)
	variants = append(variants, Variant{
		Label:          req.Label,
		EpisodeID:      req.EpisodeID,
		SceneID:        req.SceneID,
		Appearance:     req.Appearance,
		ReferenceImage: req.ReferenceImage,
		Status:         "draft",
	})
	if err := s.saveVariants(c, variants); err != nil {
		return nil, err
	}
	return c, nil
}

// UpdateVariant 更新变体
func (s *Service) UpdateVariant(charID string, userID uint, idx int, req UpdateVariantRequest) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	variants := s.getVariants(c)
	if idx < 0 || idx >= len(variants) {
		return nil, fmt.Errorf("变体索引越界")
	}
	if req.Label != nil {
		variants[idx].Label = *req.Label
	}
	if req.Appearance != nil {
		variants[idx].Appearance = *req.Appearance
	}
	if req.ReferenceImage != nil {
		variants[idx].ReferenceImage = *req.ReferenceImage
	}
	if req.Status != nil {
		variants[idx].Status = *req.Status
	}
	if err := s.saveVariants(c, variants); err != nil {
		return nil, err
	}
	return c, nil
}

// DeleteVariant 删除变体
func (s *Service) DeleteVariant(charID string, userID uint, idx int) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	variants := s.getVariants(c)
	if idx < 0 || idx >= len(variants) {
		return nil, fmt.Errorf("变体索引越界")
	}
	variants = append(variants[:idx], variants[idx+1:]...)
	if err := s.saveVariants(c, variants); err != nil {
		return nil, err
	}
	return c, nil
}
