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
func (s *Service) UpdateBio(charID string, userIDStr string, bio string) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatchesStr(c.UserID, userIDStr) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	if c.ProjectID != nil && *c.ProjectID != "" {
		if err := s.checkAssetEdit(*c.ProjectID, userIDStr); err != nil {
			return nil, err
		}
	}
	c.Bio = bio
	if err := s.data.UpdateCharacter(c); err != nil {
		return nil, err
	}
	return c, nil
}

// ExtractBio 从剧本提取小传（占位：直接返回角色）
func (s *Service) ExtractBio(ctx context.Context, projectIDStr, charID, userIDStr string, req ExtractBioRequest) (*Character, error) {
	_ = ctx
	_ = req
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatchesStr(c.UserID, userIDStr) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	if projectIDStr != "" {
		if err := s.checkAssetEditForProject(projectIDStr, userIDStr); err != nil {
			return nil, err
		}
	} else if c.ProjectID != nil && *c.ProjectID != "" {
		if err := s.checkAssetEdit(*c.ProjectID, userIDStr); err != nil {
			return nil, err
		}
	}
	// 占位：不实际调用 LLM
	return c, nil
}

// RegenerateBio 重新生成小传（占位）
func (s *Service) RegenerateBio(ctx context.Context, charID string, userIDStr string, req ExtractBioRequest) (*Character, error) {
	return s.ExtractBio(ctx, "", charID, userIDStr, req)
}
