package character

import (
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// GenerateCandidatesRequest 生成候选请求
type GenerateCandidatesRequest struct {
	Angle      string            `json:"angle"`
	VariantIdx *int              `json:"variantIdx"`
	Count      int               `json:"count"`
	Override   *GenParamOverride `json:"override"`
}

// GenParamOverride 生成参数覆盖
type GenParamOverride struct {
	Provider       string `json:"provider"`
	Model          string `json:"model"`
	Ratio          string `json:"ratio"`
	Quality        string `json:"quality"`
	PromptSuffix   string `json:"prompt_suffix"`
	NegativePrompt string `json:"negative_prompt"`
	Seed           int    `json:"seed"`
}

// GenerateCandidatesResponse 生成候选响应
type GenerateCandidatesResponse struct {
	TaskID string `json:"taskId"`
	Status string `json:"status"`
	Angle  string `json:"angle"`
	Count  int    `json:"count"`
}

// CandidateItem 候选项
type CandidateItem struct {
	Idx     int                    `json:"idx"`
	URL     string                 `json:"url"`
	GenMeta map[string]interface{} `json:"genMeta"`
}

// CandidatesResponse 候选列表响应
type CandidatesResponse struct {
	TaskID     string          `json:"taskId"`
	Status     string          `json:"status"`
	Candidates []CandidateItem `json:"candidates"`
}

// SelectCandidateRequest 选择候选请求
type SelectCandidateRequest struct {
	TaskID       string `json:"taskId" binding:"required"`
	CandidateIdx int    `json:"candidateIdx"`
	Action       string `json:"action" binding:"required"`
	Angle        string `json:"angle"`
}

// GenerateCandidates 生成形象候选（占位）
func (s *Service) GenerateCandidates(charID string, userID uint, req GenerateCandidatesRequest) (*GenerateCandidatesResponse, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, pkg.NewBizError("角色不存在")
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, pkg.NewBizError("无权操作此角色")
	}
	if c.Appearance == "" {
		return nil, pkg.NewBizError("请先填写角色外观描述")
	}
	angle := req.Angle
	if angle == "" {
		angle = "front"
	}
	count := req.Count
	if count <= 0 {
		count = 4
	}
	if count > 8 {
		count = 8
	}
	_ = req.VariantIdx
	_ = req.Override
	return &GenerateCandidatesResponse{
		TaskID: "placeholder-candidates-task",
		Status: "pending",
		Angle:  angle,
		Count:  count,
	}, nil
}

// GetCandidates 获取候选列表（占位）
func (s *Service) GetCandidates(taskID string, userID uint) (*CandidatesResponse, error) {
	_ = userID
	return &CandidatesResponse{
		TaskID:     taskID,
		Status:     "pending",
		Candidates: []CandidateItem{},
	}, nil
}

// SelectCandidate 选择候选（占位）
func (s *Service) SelectCandidate(charID string, userID uint, req SelectCandidateRequest) (*Character, error) {
	c, err := s.data.FindCharacterByID(charID)
	if err != nil {
		return nil, pkg.NewBizError("角色不存在")
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, pkg.NewBizError("无权操作此角色")
	}
	_ = req
	return c, nil
}
