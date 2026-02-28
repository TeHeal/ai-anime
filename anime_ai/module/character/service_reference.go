package character

import (
	"encoding/json"
	"fmt"
)

// ReferenceImage 参考图结构
type ReferenceImage struct {
	Angle   string                 `json:"angle"`
	URL     string                 `json:"url"`
	TaskID  string                 `json:"taskId"`
	Status  string                 `json:"status"`
	GenMeta map[string]interface{} `json:"genMeta,omitempty"`
}

// AddReferenceImageRequest 添加参考图请求
type AddReferenceImageRequest struct {
	Angle   string                 `json:"angle" binding:"required"`
	URL     string                 `json:"url" binding:"required"`
	GenMeta map[string]interface{} `json:"genMeta"`
}

func (s *Service) getReferenceImages(c *Character) []ReferenceImage {
	var imgs []ReferenceImage
	if c.ReferenceImagesJSON != "" {
		_ = json.Unmarshal([]byte(c.ReferenceImagesJSON), &imgs)
	}
	return imgs
}

func (s *Service) saveReferenceImages(c *Character, imgs []ReferenceImage) error {
	data, _ := json.Marshal(imgs)
	c.ReferenceImagesJSON = string(data)
	if len(imgs) > 0 && c.ImageURL == "" {
		c.ImageURL = imgs[0].URL
		c.ImageStatus = "completed"
	}
	return s.data.UpdateCharacter(c)
}

// AddReferenceImage 添加参考图
func (s *Service) AddReferenceImage(charID string, userID uint, req AddReferenceImageRequest) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	imgs := s.getReferenceImages(c)
	imgs = append(imgs, ReferenceImage{
		Angle:   req.Angle,
		URL:     req.URL,
		Status:  "confirmed",
		GenMeta: req.GenMeta,
	})
	if err := s.saveReferenceImages(c, imgs); err != nil {
		return nil, err
	}
	return c, nil
}

// DeleteReferenceImage 删除参考图
func (s *Service) DeleteReferenceImage(charID string, userID uint, idx int) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	imgs := s.getReferenceImages(c)
	if idx < 0 || idx >= len(imgs) {
		return nil, fmt.Errorf("参考图索引越界")
	}
	imgs = append(imgs[:idx], imgs[idx+1:]...)
	if err := s.saveReferenceImages(c, imgs); err != nil {
		return nil, err
	}
	return c, nil
}
