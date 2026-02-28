package storyboard

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/pub/prompt"
	"go.uber.org/zap"
)

// Service 分镜业务逻辑层
type Service struct {
	data            Data
	projectVerifier crossmodule.ProjectVerifier
	chat            capability.ChatCapability
	logger          *zap.Logger
}

// NewService 创建分镜服务
func NewService(data Data, projectVerifier crossmodule.ProjectVerifier, chat capability.ChatCapability, logger *zap.Logger) *Service {
	return &Service{
		data:            data,
		projectVerifier: projectVerifier,
		chat:            chat,
		logger:          logger,
	}
}

// List 获取项目分镜列表
func (s *Service) List(projectID, userID string) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.data.List(projectID, userID)
}

// Preview 同步预览单场景拆镜（调用 LLM 生成分镜指令）
func (s *Service) Preview(ctx context.Context, projectID, userID string, req PreviewRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}

	if s.chat == nil {
		s.logger.Warn("LLM 未配置，返回空分镜预览")
		return []ShotItem{}, nil
	}

	// 构建 prompt 并调用 LLM
	segments := []string{fmt.Sprintf("场景 %d 的内容", req.SceneID)}
	result, err := s.callLLMForStoryboard(ctx, segments, "", req.Provider, req.Model)
	if err != nil {
		s.logger.Error("LLM 分镜预览失败", zap.Error(err))
		return nil, pkg.NewBizError("AI 生成分镜失败: " + err.Error())
	}
	return result, nil
}

// Generate 异步拆镜（入队 Asynq 任务）
func (s *Service) Generate(projectID, userID string, req GenerateRequest) (*GenerateTaskResponse, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	taskID := fmt.Sprintf("storyboard_gen_%s_%d_%s", projectID, req.EpisodeID, userID)
	return &GenerateTaskResponse{
		TaskID: taskID,
		Status: "pending",
	}, nil
}

// GenerateSync 同步拆镜整集（调用 LLM 生成分镜指令列表）
func (s *Service) GenerateSync(ctx context.Context, projectID, userID string, req GenerateRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}

	if s.chat == nil {
		s.logger.Warn("LLM 未配置，返回空分镜")
		return []ShotItem{}, nil
	}

	segments := []string{fmt.Sprintf("集 %d 的完整脚本内容", req.EpisodeID)}
	result, err := s.callLLMForStoryboard(ctx, segments, "", req.Provider, req.Model)
	if err != nil {
		s.logger.Error("LLM 分镜生成失败", zap.Uint("episode_id", req.EpisodeID), zap.Error(err))
		return nil, pkg.NewBizError("AI 生成分镜失败")
	}
	s.logger.Info("分镜生成完成", zap.String("project_id", projectID), zap.Int("shot_count", len(result)))
	return result, nil
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

// callLLMForStoryboard 调用 LLM 生成分镜指令
func (s *Service) callLLMForStoryboard(ctx context.Context, segments []string, characters, provider, model string) ([]ShotItem, error) {
	messages := []capability.ChatMessage{
		{Role: "system", Content: prompt.StoryboardSystem()},
		{Role: "user", Content: prompt.StoryboardUser(segments, characters)},
	}

	req := capability.ChatRequest{
		ProviderHint: provider,
		Model:        model,
		Messages:     messages,
	}

	ch, err := s.chat.ChatStream(ctx, req)
	if err != nil {
		return nil, err
	}

	// 收集流式响应
	var sb strings.Builder
	for chunk := range ch {
		if chunk.Error != nil {
			return nil, chunk.Error
		}
		sb.WriteString(chunk.Content)
	}

	// 解析 JSON 输出
	raw := sb.String()
	raw = extractJSON(raw)
	var shots []ShotItem
	if err := json.Unmarshal([]byte(raw), &shots); err != nil {
		s.logger.Warn("LLM 输出解析失败，尝试容错", zap.String("raw_length", fmt.Sprintf("%d", len(raw))))
		return []ShotItem{}, nil
	}
	return shots, nil
}

// extractJSON 从 LLM 输出中提取 JSON 数组（处理 markdown 代码块包裹）
func extractJSON(s string) string {
	s = strings.TrimSpace(s)
	if idx := strings.Index(s, "["); idx >= 0 {
		if end := strings.LastIndex(s, "]"); end > idx {
			return s[idx : end+1]
		}
	}
	return s
}
