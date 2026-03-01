package storyboard

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/llm"
)

// Service 分镜业务逻辑层
type Service struct {
	data             Data
	projectVerifier  crossmodule.ProjectVerifier
	memberResolver   crossmodule.ProjectMemberResolver
	llmSvc           *llm.LLMService
	episodeStore     EpisodeReader
	sceneBlockReader crossmodule.SceneBlockReader
}

// EpisodeReader 集数据读取接口（只需用到的方法，避免引入 episode 包循环依赖）
type EpisodeReader interface {
	FindByID(id string) (EpisodeInfo, error)
}

// EpisodeInfo 集摘要信息
type EpisodeInfo struct {
	ID    string
	Title string
}

// NewService 创建分镜服务
func NewService(data Data, projectVerifier crossmodule.ProjectVerifier) *Service {
	return NewServiceWithResolver(data, projectVerifier, nil)
}

// NewServiceWithResolver 创建分镜服务（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(data Data, projectVerifier crossmodule.ProjectVerifier, memberResolver crossmodule.ProjectMemberResolver) *Service {
	return &Service{
		data:            data,
		projectVerifier: projectVerifier,
		memberResolver:  memberResolver,
	}
}

// SetLLMService 注入 LLM 服务
func (s *Service) SetLLMService(svc *llm.LLMService) {
	s.llmSvc = svc
}

// SetEpisodeReader 注入集数据读取器
func (s *Service) SetEpisodeReader(reader EpisodeReader) {
	s.episodeStore = reader
}

// SetSceneBlockReader 注入场景/块数据读取器
func (s *Service) SetSceneBlockReader(reader crossmodule.SceneBlockReader) {
	s.sceneBlockReader = reader
}

// List 获取项目分镜列表
func (s *Service) List(projectID, userID string) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	return s.data.List(projectID, userID)
}

// Preview 同步预览单场景拆镜
func (s *Service) Preview(ctx context.Context, projectID, userID string, req PreviewRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAction(projectID, userID, auth.ActionGenerate); err != nil {
		return nil, err
	}
	if s.llmSvc == nil || !s.llmSvc.Available() {
		return nil, fmt.Errorf("LLM 未配置：请在 config.yaml 中设置 llm.deepseek_key 等 API Key")
	}
	if s.sceneBlockReader == nil {
		return nil, fmt.Errorf("场景数据读取器未配置")
	}

	blocks, err := s.sceneBlockReader.ListBlocksByScene(req.SceneID)
	if err != nil {
		return nil, fmt.Errorf("读取场景内容块失败: %w", err)
	}
	scene := llm.SceneForPrompt{
		ID: 0,
		Blocks: make([]llm.BlockForPrompt, len(blocks)),
	}
	for i, b := range blocks {
		scene.Blocks[i] = llm.BlockForPrompt{Type: b.Type, Character: b.Character, Content: b.Content}
	}

	userPrompt := llm.BuildStoryboardUserPrompt("预览", []llm.SceneForPrompt{scene})
	result, err := s.llmSvc.ChatWithJSON(ctx, llm.GetStoryboardSystemPrompt(), userPrompt)
	if err != nil {
		return nil, fmt.Errorf("LLM 调用失败: %w", err)
	}

	shots, err := parseStoryboardJSON(result)
	if err != nil {
		return nil, fmt.Errorf("解析分镜结果失败: %w", err)
	}
	return shots, nil
}

// Generate 异步拆镜（占位：返回占位任务，后续接 Worker）
func (s *Service) Generate(projectID, userID string, req GenerateRequest) (*GenerateTaskResponse, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAction(projectID, userID, auth.ActionGenerate); err != nil {
		return nil, err
	}
	// 占位：后续入队 Asynq 任务，由 Worker 执行
	taskID := fmt.Sprintf("storyboard_gen_%s_%d_%s", projectID, req.EpisodeID, userID)
	return &GenerateTaskResponse{
		TaskID: taskID,
		Status: "pending",
	}, nil
}

// GenerateSync 同步拆镜整集，调用 LLM 生成结构化分镜列表
func (s *Service) GenerateSync(ctx context.Context, projectID, userID string, req GenerateRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAction(projectID, userID, auth.ActionGenerate); err != nil {
		return nil, err
	}
	if s.llmSvc == nil || !s.llmSvc.Available() {
		return nil, fmt.Errorf("LLM 未配置：请在 config.yaml 中设置 llm.deepseek_key 等 API Key")
	}
	if s.sceneBlockReader == nil {
		return nil, fmt.Errorf("场景数据读取器未配置")
	}

	// 获取集标题
	episodeTitle := "未命名集"
	if s.episodeStore != nil {
		if ep, err := s.episodeStore.FindByID(req.EpisodeID); err == nil && ep.Title != "" {
			episodeTitle = ep.Title
		}
	}

	// 获取该集所有场景及内容块
	sceneInfos, err := s.sceneBlockReader.ListScenesByEpisode(req.EpisodeID)
	if err != nil {
		return nil, fmt.Errorf("读取场景列表失败: %w", err)
	}
	if len(sceneInfos) == 0 {
		return nil, pkg.NewBizError("该集没有场景数据，请先创建场景和内容块")
	}

	scenes := make([]llm.SceneForPrompt, 0, len(sceneInfos))
	for _, si := range sceneInfos {
		blocks, err := s.sceneBlockReader.ListBlocksByScene(si.ID)
		if err != nil {
			return nil, fmt.Errorf("读取场景 %s 内容块失败: %w", si.ID, err)
		}
		promptBlocks := make([]llm.BlockForPrompt, len(blocks))
		for j, b := range blocks {
			promptBlocks[j] = llm.BlockForPrompt{
				Type:      b.Type,
				Character: b.Character,
				Content:   b.Content,
			}
		}
		// 将 string ID 转为 uint（场景在 ShotItem 中用 uint scene_id）
		sceneIDUint := uint(0)
		if v, err := strconv.ParseUint(si.ID, 10, 64); err == nil {
			sceneIDUint = uint(v)
		}
		scenes = append(scenes, llm.SceneForPrompt{
			ID:               sceneIDUint,
			Location:         si.Location,
			Time:             si.Time,
			InteriorExterior: si.InteriorExterior,
			Characters:       si.Characters,
			Blocks:           promptBlocks,
		})
	}

	userPrompt := llm.BuildStoryboardUserPrompt(episodeTitle, scenes)
	result, err := s.llmSvc.ChatWithJSON(ctx, llm.GetStoryboardSystemPrompt(), userPrompt)
	if err != nil {
		return nil, fmt.Errorf("LLM 调用失败: %w", err)
	}

	shots, err := parseStoryboardJSON(result)
	if err != nil {
		return nil, fmt.Errorf("解析分镜结果失败: %w", err)
	}
	return shots, nil
}

// parseStoryboardJSON 解析 LLM 返回的 JSON 分镜数据，兼容 markdown 代码块包裹
func parseStoryboardJSON(raw string) ([]ShotItem, error) {
	cleaned := cleanJSONResponse(raw)
	var shots []ShotItem
	if err := json.Unmarshal([]byte(cleaned), &shots); err != nil {
		return nil, fmt.Errorf("JSON 解析失败（原始长度=%d）: %w", len(raw), err)
	}
	return shots, nil
}

// cleanJSONResponse 清理 LLM 返回的 JSON，去除 markdown 代码块标记等
func cleanJSONResponse(s string) string {
	s = trimMarkdownCodeBlock(s)
	// 去除首尾空白
	for len(s) > 0 && (s[0] == ' ' || s[0] == '\n' || s[0] == '\r' || s[0] == '\t') {
		s = s[1:]
	}
	for len(s) > 0 && (s[len(s)-1] == ' ' || s[len(s)-1] == '\n' || s[len(s)-1] == '\r' || s[len(s)-1] == '\t') {
		s = s[:len(s)-1]
	}
	return s
}

func trimMarkdownCodeBlock(s string) string {
	// 常见格式：```json\n...\n``` 或 ```\n...\n```
	if len(s) > 6 && s[:3] == "```" {
		// 找到第一个换行
		idx := 3
		for idx < len(s) && s[idx] != '\n' {
			idx++
		}
		if idx < len(s) {
			s = s[idx+1:]
		}
		// 去除结尾 ```
		if len(s) >= 3 && s[len(s)-3:] == "```" {
			s = s[:len(s)-3]
		}
	}
	return s
}

// Confirm 确认导入，保存分镜到 project.storyboard_json
func (s *Service) Confirm(projectID, userID string, req ConfirmRequest) ([]ShotItem, error) {
	if err := s.projectVerifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if err := s.checkAction(projectID, userID, auth.ActionScriptEdit); err != nil {
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

func (s *Service) checkAction(projectID, userID string, action auth.Action) error {
	if s.memberResolver == nil {
		return nil
	}
	info, err := s.memberResolver.Resolve(projectID, userID)
	if err != nil {
		return err
	}
	if info.IsOwner {
		return nil
	}
	if !auth.CanDo(info.JobRoles, action) {
		return fmt.Errorf("%w: 当前工种不允许执行此操作", pkg.ErrForbidden)
	}
	return nil
}
