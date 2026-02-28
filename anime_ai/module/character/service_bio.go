package character

import (
	"context"
	"fmt"
)

// ExtractBioRequest 提取小传请求
type ExtractBioRequest struct {
	SceneIDs []string `json:"scene_ids"`
}

// UpdateBio 更新小传
func (s *Service) UpdateBio(charID string, userID uint, bio string) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	c.Bio = bio
	if err := s.data.UpdateCharacter(c); err != nil {
		return nil, err
	}
	return c, nil
}

// ExtractBio 从剧本提取小传（占位：直接返回角色）
func (s *Service) ExtractBio(ctx context.Context, projectID uint, charID string, userID uint, req ExtractBioRequest) (*Character, error) {
	_ = ctx
	_ = projectID
	_ = req
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	// 占位：不实际调用 LLM
	return c, nil
}

// RegenerateBio 重新生成小传（占位）
func (s *Service) RegenerateBio(ctx context.Context, charID string, userID uint, req ExtractBioRequest) (*Character, error) {
	return s.ExtractBio(ctx, 0, charID, userID, req)
}
