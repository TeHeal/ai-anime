package storyboard

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// Service 分镜业务逻辑层
type Service struct {
	data             Data
	projectVerifier  crossmodule.ProjectVerifier
}

// NewService 创建分镜服务
func NewService(data Data, projectVerifier crossmodule.ProjectVerifier) *Service {
	return &Service{
		data:            data,
		projectVerifier: projectVerifier,
	}
}

// List 获取项目分镜列表
func (s *Service) List(projectID, userID string) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.data.List(projectID, userID)
}

// Preview 同步预览单场景拆镜（占位：返回空列表，后续接 pub/mesh LLM）
func (s *Service) Preview(ctx context.Context, projectID, userID string, req PreviewRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	// 占位：后续调用 pub/mesh Chat 能力生成分镜
	_ = req
	return []ShotItem{}, nil
}

// Generate 异步拆镜（占位：返回占位任务，后续接 Worker）
func (s *Service) Generate(projectID, userID string, req GenerateRequest) (*GenerateTaskResponse, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	// 占位：后续入队 Asynq 任务，由 Worker 执行
	taskID := fmt.Sprintf("storyboard_gen_%s_%d_%s", projectID, req.EpisodeID, userID)
	return &GenerateTaskResponse{
		TaskID: taskID,
		Status: "pending",
	}, nil
}

// GenerateSync 同步拆镜整集（占位：返回空列表，后续接 pub/mesh）
func (s *Service) GenerateSync(ctx context.Context, projectID, userID string, req GenerateRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	// 占位：后续调用 LLM 生成
	_ = req
	return []ShotItem{}, nil
}

// Confirm 确认导入，保存分镜到 project.storyboard_json
func (s *Service) Confirm(projectID, userID string, req ConfirmRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if len(req.Shots) == 0 {
		return nil, pkg.NewBizError("分镜列表不能为空")
	}
	if err := s.data.Save(projectID, userID, req.Shots); err != nil {
		return nil, err
	}
	return req.Shots, nil
}
