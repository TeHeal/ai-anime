package script

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/module/episode"
	"github.com/TeHeal/ai-anime/anime_ai/module/scene"
	"github.com/TeHeal/ai-anime/anime_ai/module/script/parser"
	"github.com/TeHeal/ai-anime/anime_ai/pub/auth"
	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider"
	"github.com/TeHeal/ai-anime/anime_ai/pub/provider/llm"
)

// DummyProjectVerifier 占位实现，始终通过验证
type DummyProjectVerifier struct{}

func (DummyProjectVerifier) Verify(projectID, userID string) error { return nil }

// Service 脚本业务逻辑层
type Service struct {
	store          SegmentStore
	verifier       crossmodule.ProjectVerifier
	memberResolver crossmodule.ProjectMemberResolver
	llmSvc         *llm.LLMService
	episodeSvc     *episode.Service
	sceneSvc       *scene.Service
}

// NewService 创建脚本服务
func NewService(store SegmentStore, verifier crossmodule.ProjectVerifier) *Service {
	return NewServiceWithResolver(store, verifier, nil)
}

// NewServiceWithResolver 创建脚本服务（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(store SegmentStore, verifier crossmodule.ProjectVerifier, memberResolver crossmodule.ProjectMemberResolver) *Service {
	if verifier == nil {
		verifier = DummyProjectVerifier{}
	}
	return &Service{store: store, verifier: verifier, memberResolver: memberResolver}
}

// SetLLMService 注入 LLM 服务
func (s *Service) SetLLMService(svc *llm.LLMService) {
	s.llmSvc = svc
}

// SetEpisodeSceneServices 注入集、场服务，用于确认导入时创建 episode/scene/block
func (s *Service) SetEpisodeSceneServices(epSvc *episode.Service, scSvc *scene.Service) {
	s.episodeSvc = epSvc
	s.sceneSvc = scSvc
}

// checkScriptEdit 校验脚本编辑权限（projectIDStr/userIDStr 为 string，支持 UUID）
func (s *Service) checkScriptEdit(projectIDStr, userIDStr string) error {
	if s.memberResolver == nil {
		return nil
	}
	info, err := s.memberResolver.Resolve(projectIDStr, userIDStr)
	if err != nil {
		return err
	}
	if info.IsOwner {
		return nil
	}
	if !auth.CanDo(info.JobRoles, auth.ActionScriptEdit) {
		return fmt.Errorf("%w: 当前工种不允许编辑脚本", pkg.ErrForbidden)
	}
	return nil
}

// CreateSegmentRequest 创建分段请求
type CreateSegmentRequest struct {
	Content   string `json:"content" binding:"max=300"`
	SortIndex int    `json:"sort_index"`
}

// UpdateSegmentRequest 更新分段请求
type UpdateSegmentRequest struct {
	Content   *string `json:"content" binding:"omitempty,max=300"`
	SortIndex *int    `json:"sort_index"`
}

// BulkCreateSegmentRequest 批量创建分段请求
type BulkCreateSegmentRequest struct {
	Segments []CreateSegmentRequest `json:"segments" binding:"required,dive"`
}

// ReorderSegmentsRequest 排序请求
type ReorderSegmentsRequest struct {
	OrderedIDs []string `json:"ordered_ids" binding:"required"`
}

// Create 创建分段
func (s *Service) Create(projectIDStr, userIDStr string, req CreateSegmentRequest) (*Segment, error) {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	seg := &Segment{
		ProjectID: projectIDStr,
		SortIndex: req.SortIndex,
		Content:   req.Content,
	}
	if err := s.store.Create(seg); err != nil {
		return nil, err
	}
	return seg, nil
}

// BulkCreate 批量创建分段（先清空项目下已有分段）
func (s *Service) BulkCreate(projectIDStr, userIDStr string, req BulkCreateSegmentRequest) ([]Segment, error) {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	_ = s.store.DeleteByProject(projectIDStr)
	segments := make([]Segment, len(req.Segments))
	for i, r := range req.Segments {
		segments[i] = Segment{
			ProjectID: projectIDStr,
			SortIndex: i,
			Content:   r.Content,
		}
	}
	if err := s.store.BulkCreate(segments); err != nil {
		return nil, err
	}
	return s.store.ListByProject(projectIDStr)
}

// List 按项目列出分段
func (s *Service) List(projectIDStr, userIDStr string) ([]Segment, error) {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	return s.store.ListByProject(projectIDStr)
}

// Update 更新分段
func (s *Service) Update(id string, projectIDStr, userIDStr string, req UpdateSegmentRequest) (*Segment, error) {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	seg, err := s.store.FindByID(id)
	if err != nil {
		return nil, err
	}
	if seg.ProjectID != projectIDStr {
		return nil, pkg.ErrNotFound
	}
	if req.Content != nil {
		seg.Content = *req.Content
	}
	if req.SortIndex != nil {
		seg.SortIndex = *req.SortIndex
	}
	if err := s.store.Update(seg); err != nil {
		return nil, err
	}
	return seg, nil
}

// Delete 删除分段
func (s *Service) Delete(id string, projectIDStr, userIDStr string) error {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return err
	}
	seg, err := s.store.FindByID(id)
	if err != nil {
		return err
	}
	if seg.ProjectID != projectIDStr {
		return pkg.ErrNotFound
	}
	return s.store.Delete(id)
}

// Reorder 排序分段
func (s *Service) Reorder(projectIDStr, userIDStr string, req ReorderSegmentsRequest) error {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return err
	}
	return s.store.ReorderByProject(projectIDStr, req.OrderedIDs)
}

// --- 脚本解析 ---

// ScriptParseRequest 解析请求
type ScriptParseRequest struct {
	Content    string `json:"content" binding:"required"`
	FormatHint string `json:"format_hint" binding:"omitempty,oneof=standard unknown"`
}

// ParseTask 解析任务占位
type ParseTask struct {
	TaskID string `json:"task_id"`
	Status string `json:"status"`
}

// SubmitParse 提交异步解析任务（占位：直接返回模拟 task_id）
func (s *Service) SubmitParse(projectIDStr, userIDStr string, req ScriptParseRequest) (*ParseTask, error) {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	taskID := fmt.Sprintf("script_parse_%s_%s", projectIDStr, userIDStr)
	return &ParseTask{TaskID: taskID, Status: "pending"}, nil
}

// ParseSync 同步解析：预处理 → 正则解析 →（可选）LLM 辅助 → 校验
func (s *Service) ParseSync(ctx context.Context, projectIDStr, userIDStr string, req ScriptParseRequest) (*parser.ParseResult, error) {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	hint := parser.FormatStandard
	if req.FormatHint == "unknown" {
		hint = parser.FormatUnknown
	}
	var llmClient parser.LLMClient
	if s.llmSvc != nil && s.llmSvc.Available() {
		llmClient = NewLLMServiceAdapter(s.llmSvc)
	}
	return parser.Parse(ctx, req.Content, parser.ParseOptions{FormatHint: hint}, llmClient)
}

// GetPreview 获取解析预览（异步任务完成后调用，占位：当前仅支持同步解析）
func (s *Service) GetPreview(projectIDStr, userIDStr string) (*parser.ParseResult, error) {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	return nil, fmt.Errorf("解析结果不存在或未完成")
}

// ScriptConfirmRequest 确认导入请求
type ScriptConfirmRequest struct {
	Episodes []parser.ParsedEpisode `json:"episodes" binding:"required"`
}

// Confirm 确认导入解析结果，将解析的集/场/块写入数据库
func (s *Service) Confirm(projectIDStr, userIDStr string, req ScriptConfirmRequest) error {
	if err := s.verifier.Verify(projectIDStr, userIDStr); err != nil {
		return err
	}
	if err := s.checkScriptEdit(projectIDStr, userIDStr); err != nil {
		return err
	}
	if s.episodeSvc == nil || s.sceneSvc == nil {
		return pkg.NewBizError("集/场服务未注入，无法执行导入")
	}
	if len(req.Episodes) == 0 {
		return pkg.NewBizError("没有可导入的集数据")
	}

	// 1. 删除项目下已有集（及其场、块）
	existingEps, err := s.episodeSvc.ListByProject(projectIDStr, userIDStr)
	if err != nil {
		return pkg.NewBizError("列出已有集失败: " + err.Error())
	}
	for _, ep := range existingEps {
		epID := ep.IDStr
		if epID == "" {
			epID = fmt.Sprintf("%d", ep.ID)
		}
		scenes, _ := s.sceneSvc.List(epID, userIDStr)
		for _, sc := range scenes {
			_ = s.sceneSvc.Delete(sc.ID, epID, userIDStr)
		}
		if err := s.episodeSvc.Delete(epID, projectIDStr, userIDStr); err != nil {
			return pkg.NewBizError("删除已有集失败: " + err.Error())
		}
	}

	// 2. 创建集 → 场 → 块
	for _, parsedEp := range req.Episodes {
		ep, err := s.episodeSvc.Create(projectIDStr, userIDStr, episode.CreateEpisodeRequest{
			Title: fmt.Sprintf("第%d集", parsedEp.EpisodeNum),
		})
		if err != nil {
			return pkg.NewBizError(fmt.Sprintf("创建第%d集失败: %v", parsedEp.EpisodeNum, err))
		}
		epID := ep.IDStr
		if epID == "" {
			epID = fmt.Sprintf("%d", ep.ID)
		}

		for _, parsedSc := range parsedEp.Scenes {
			scResp, err := s.sceneSvc.Create(epID, userIDStr, scene.CreateSceneRequest{
				SceneID:          parsedSc.SceneNum,
				Location:         parsedSc.Location,
				Time:             parsedSc.Time,
				InteriorExterior: parsedSc.IntExt,
				Characters:       parsedSc.Characters,
			})
			if err != nil {
				return pkg.NewBizError(fmt.Sprintf("创建场 %s 失败: %v", parsedSc.SceneNum, err))
			}

			if len(parsedSc.Blocks) > 0 {
				blocks := make([]scene.CreateBlockRequest, len(parsedSc.Blocks))
				for bIdx, pb := range parsedSc.Blocks {
					blocks[bIdx] = scene.CreateBlockRequest{
						Type:      string(pb.Type),
						Character: pb.Character,
						Emotion:   pb.Emotion,
						Content:   pb.Content,
					}
				}
				_, err = s.sceneSvc.SaveBlocks(scResp.ID, epID, userIDStr, scene.BulkSaveBlocksRequest{Blocks: blocks})
				if err != nil {
					return pkg.NewBizError(fmt.Sprintf("保存场 %s 的块失败: %v", parsedSc.SceneNum, err))
				}
			}
		}
	}
	return nil
}

// --- 脚本 AI 辅助（占位）---

// ScriptAiRequest AI 辅助请求
type ScriptAiRequest struct {
	Action        string   `json:"action" binding:"required"`
	BlockType     string   `json:"block_type"`
	BlockContent  string   `json:"block_content"`
	SceneMeta     string   `json:"scene_meta"`
	ContextBlocks []string `json:"context_blocks"`
	Provider      string   `json:"provider"`
	Model         string   `json:"model"`
}

// ChatChunk AI 流式响应块（占位，后续对接 pub/capability）
type ChatChunk struct {
	Content string
	Error   string
	Done    bool
}

// StreamAssist AI 流式辅助，调用 LLM 进行扩写/润色/续写
func (s *Service) StreamAssist(ctx context.Context, req ScriptAiRequest) (<-chan ChatChunk, error) {
	if req.Action == "" {
		return nil, fmt.Errorf("未知的 AI 操作")
	}
	if s.llmSvc == nil || !s.llmSvc.Available() {
		return nil, fmt.Errorf("LLM 未配置：请在 config.yaml 中设置 llm.deepseek_key 等 API Key")
	}

	systemPrompt := llm.GetScriptAssistSystemPrompt()
	userPrompt := llm.BuildScriptAssistUserPrompt(
		req.Action, req.BlockType, req.BlockContent, req.SceneMeta, req.ContextBlocks,
	)

	providerCh, err := s.llmSvc.ChatStream(ctx, req.Provider, req.Model, systemPrompt, userPrompt)
	if err != nil {
		return nil, fmt.Errorf("调用 LLM 失败: %w", err)
	}

	// 将 provider.ChatChunk 转为 script.ChatChunk
	ch := make(chan ChatChunk, 32)
	go func() {
		defer close(ch)
		for chunk := range providerCh {
			select {
			case <-ctx.Done():
				ch <- ChatChunk{Error: "请求已取消"}
				return
			default:
			}
			ch <- convertProviderChunk(chunk)
		}
	}()
	return ch, nil
}

func convertProviderChunk(c provider.ChatChunk) ChatChunk {
	if c.Error != "" {
		return ChatChunk{Error: c.Error}
	}
	if c.Done {
		return ChatChunk{Done: true}
	}
	return ChatChunk{Content: c.Content}
}
