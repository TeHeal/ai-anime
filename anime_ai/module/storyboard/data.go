package storyboard

import (
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
)

// Data 分镜数据访问层，封装 project.storyboard_json 读写，使用 string ID 以兼容 PostgreSQL UUID
type Data interface {
	List(projectID, userID string) ([]ShotItem, error)
	Save(projectID, userID string, shots []ShotItem) error
}

// MemData 基于 ProjectStoryboardAccess 的实现
type MemData struct {
	access crossmodule.ProjectStoryboardAccess
}

// NewMemData 创建分镜 Data 实例
func NewMemData(access crossmodule.ProjectStoryboardAccess) *MemData {
	return &MemData{access: access}
}

// List 获取项目分镜列表
func (d *MemData) List(projectID, userID string) ([]ShotItem, error) {
	raw, err := d.access.GetStoryboardJSON(projectID, userID)
	if err != nil {
		return nil, err
	}
	if raw == "" || raw == "{}" {
		return []ShotItem{}, nil
	}
	var shots []ShotItem
	if err := json.Unmarshal([]byte(raw), &shots); err != nil {
		return []ShotItem{}, nil
	}
	return shots, nil
}

// Save 保存分镜到 project.storyboard_json
func (d *MemData) Save(projectID, userID string, shots []ShotItem) error {
	if shots == nil {
		shots = []ShotItem{}
	}
	raw, err := json.Marshal(shots)
	if err != nil {
		return err
	}
	return d.access.UpdateStoryboardJSON(projectID, userID, string(raw))
}
