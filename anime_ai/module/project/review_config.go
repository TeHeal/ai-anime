package project

import "encoding/json"

// 审核模式常量（README §2.2：仅人工 / 仅 AI / 人工+AI）
const (
	ReviewModeHumanOnly = "human_only"
	ReviewModeAIOnly    = "ai_only"
	ReviewModeHumanAI   = "human_and_ai"
)

// StageReviewConfig 单阶段审核配置
type StageReviewConfig struct {
	Mode string `json:"mode"` // human_only, ai_only, human_and_ai
	// AI 审核使用的模型（ai_only 或 human_and_ai 时生效）
	AIModel string `json:"aiModel,omitempty"`
	// AI 审核的自定义提示词（可选）
	AIPrompt string `json:"aiPrompt,omitempty"`
	// AI 自动通过阈值（0-100，ai_only 模式下 AI 置信度高于此值自动通过）
	AutoApproveThreshold int `json:"autoApproveThreshold,omitempty"`
}

// ReviewConfig 项目级审核配置（README §2.2 审核方式可配置）
// 每步可配置：仅人工 / 仅 AI / 人工+AI（AI 初筛+人工终审）
type ReviewConfig struct {
	Script    StageReviewConfig `json:"script"`
	ShotImage StageReviewConfig `json:"shotImage"`
	ShotVideo StageReviewConfig `json:"shotVideo"`
}

// DefaultReviewConfig 默认审核配置：全部使用人工审核
func DefaultReviewConfig() ReviewConfig {
	return ReviewConfig{
		Script:    StageReviewConfig{Mode: ReviewModeHumanOnly},
		ShotImage: StageReviewConfig{Mode: ReviewModeHumanOnly},
		ShotVideo: StageReviewConfig{Mode: ReviewModeHumanOnly},
	}
}

// ValidReviewMode 校验审核模式是否合法
func ValidReviewMode(mode string) bool {
	return mode == ReviewModeHumanOnly || mode == ReviewModeAIOnly || mode == ReviewModeHumanAI
}

// GetReviewConfig 从项目 PropsJSON 中解析审核配置
// 审核配置存储在 props 的 "review_config" 字段中
func (p *Project) GetReviewConfig() ReviewConfig {
	if p.PropsJSON == "" {
		return DefaultReviewConfig()
	}
	var wrapper map[string]json.RawMessage
	if err := json.Unmarshal([]byte(p.PropsJSON), &wrapper); err != nil {
		return DefaultReviewConfig()
	}
	raw, ok := wrapper["review_config"]
	if !ok {
		return DefaultReviewConfig()
	}
	var cfg ReviewConfig
	if err := json.Unmarshal(raw, &cfg); err != nil {
		return DefaultReviewConfig()
	}
	return cfg
}

// SetReviewConfig 将审核配置写入项目 PropsJSON
func (p *Project) SetReviewConfig(cfg ReviewConfig) {
	var wrapper map[string]json.RawMessage
	if p.PropsJSON != "" {
		if err := json.Unmarshal([]byte(p.PropsJSON), &wrapper); err != nil {
			wrapper = make(map[string]json.RawMessage)
		}
	} else {
		wrapper = make(map[string]json.RawMessage)
	}
	data, _ := json.Marshal(cfg)
	wrapper["review_config"] = data
	out, _ := json.Marshal(wrapper)
	p.PropsJSON = string(out)
}
