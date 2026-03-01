package script

import (
	"context"
	"fmt"

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

// checkScriptEdit 校验脚本编辑权限（projectID/userID 为 uint）
func (s *Service) checkScriptEdit(projectID, userID uint) error {
	if s.memberResolver == nil {
		return nil
	}
	projectIDStr := pkg.UUIDString(pkg.UintToUUID(projectID))
	userIDStr := pkg.UUIDString(pkg.UintToUUID(userID))
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
func (s *Service) Create(projectID, userID uint, req CreateSegmentRequest) (*Segment, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return nil, err
	}
	seg := &Segment{
		ProjectID: projectID,
		SortIndex: req.SortIndex,
		Content:   req.Content,
	}
	if err := s.store.Create(seg); err != nil {
		return nil, err
	}
	return seg, nil
}

// BulkCreate 批量创建分段（先清空项目下已有分段）
func (s *Service) BulkCreate(projectID, userID uint, req BulkCreateSegmentRequest) ([]Segment, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return nil, err
	}
	_ = s.store.DeleteByProject(projectID)
	segments := make([]Segment, len(req.Segments))
	for i, r := range req.Segments {
		segments[i] = Segment{
			ProjectID: projectID,
			SortIndex: i,
			Content:   r.Content,
		}
	}
	if err := s.store.BulkCreate(segments); err != nil {
		return nil, err
	}
	return s.store.ListByProject(projectID)
}

// List 按项目列出分段
func (s *Service) List(projectID, userID uint) ([]Segment, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}
	return s.store.ListByProject(projectID)
}

// Update 更新分段
func (s *Service) Update(id string, projectID, userID uint, req UpdateSegmentRequest) (*Segment, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return nil, err
	}
	seg, err := s.store.FindByID(id)
	if err != nil {
		return nil, err
	}
	if seg.ProjectID != projectID {
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
func (s *Service) Delete(id string, projectID, userID uint) error {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return err
	}
	seg, err := s.store.FindByID(id)
	if err != nil {
		return err
	}
	if seg.ProjectID != projectID {
		return pkg.ErrNotFound
	}
	return s.store.Delete(id)
}

// Reorder 排序分段
func (s *Service) Reorder(projectID, userID uint, req ReorderSegmentsRequest) error {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return err
	}
	return s.store.ReorderByProject(projectID, req.OrderedIDs)
}

// --- 脚本解析（占位）---

// ParseResult 解析结果占位结构，后续对接 script_parser 时替换
type ParseResult struct {
	Script interface{} `json:"script"`
	Issues []string    `json:"issues"`
}

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
func (s *Service) SubmitParse(projectID, userID uint, req ScriptParseRequest) (*ParseTask, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return nil, err
	}
	taskID := fmt.Sprintf("script_parse_%d_%d", projectID, userID)
	return &ParseTask{TaskID: taskID, Status: "pending"}, nil
}

// ParseSync 同步解析（占位：返回空结构）
func (s *Service) ParseSync(ctx context.Context, projectID, userID uint, req ScriptParseRequest) (*ParseResult, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return nil, err
	}
	_ = ctx
	return &ParseResult{Script: nil, Issues: []string{}}, nil
}

// GetPreview 获取解析预览（占位）
func (s *Service) GetPreview(projectID, userID uint) (*ParseResult, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}
	return nil, fmt.Errorf("解析结果不存在或未完成")
}

// ScriptConfirmRequest 确认导入请求（占位）
type ScriptConfirmRequest struct {
	Episodes []interface{} `json:"episodes" binding:"required"`
}

// Confirm 确认导入解析结果（占位：暂不写入 episode/scene/block）
func (s *Service) Confirm(projectID, userID uint, req ScriptConfirmRequest) error {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return err
	}
	if err := s.checkScriptEdit(projectID, userID); err != nil {
		return err
	}
	_ = req
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
