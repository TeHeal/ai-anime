package project

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
)

// NewStoryboardAccess 基于 Data 创建分镜读写实现，供 storyboard 模块注入
func NewStoryboardAccess(data Data) crossmodule.ProjectStoryboardAccess {
	return &storyboardAccessImpl{data: data}
}

type storyboardAccessImpl struct {
	data Data
}

func (a *storyboardAccessImpl) GetStoryboardJSON(projectID, userID string) (string, error) {
	p, err := a.data.FindByID(projectID, userID)
	if err != nil {
		return "", err
	}
	if p.StoryboardJSON == "" {
		return "[]", nil
	}
	return p.StoryboardJSON, nil
}

func (a *storyboardAccessImpl) UpdateStoryboardJSON(projectID, userID string, json string) error {
	p, err := a.data.FindByID(projectID, userID)
	if err != nil {
		return err
	}
	p.StoryboardJSON = json
	return a.data.UpdateProject(p)
}
