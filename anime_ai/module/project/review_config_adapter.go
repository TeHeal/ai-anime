package project

import (
	"anime_ai/pub/crossmodule"
)

// NewReviewConfigReader 基于 Data 创建审核配置读取器，实现 crossmodule.ReviewConfigReader
func NewReviewConfigReader(data Data) crossmodule.ReviewConfigReader {
	return &reviewConfigReaderImpl{data: data}
}

type reviewConfigReaderImpl struct {
	data Data
}

// GetStageReviewMode 获取项目指定阶段的审核模式
func (r *reviewConfigReaderImpl) GetStageReviewMode(projectID, stage string) (string, error) {
	p, err := r.data.FindByIDOnly(projectID)
	if err != nil {
		return ReviewModeHumanOnly, err
	}
	cfg := p.GetReviewConfig()
	switch stage {
	case crossmodule.StageScript:
		return cfg.Script.Mode, nil
	case crossmodule.StageShotImage:
		return cfg.ShotImage.Mode, nil
	case crossmodule.StageShotVideo:
		return cfg.ShotVideo.Mode, nil
	default:
		return ReviewModeHumanOnly, nil
	}
}
