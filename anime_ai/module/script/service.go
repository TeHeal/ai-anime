package script

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

// DummyProjectVerifier 占位实现，始终通过验证
type DummyProjectVerifier struct{}

func (DummyProjectVerifier) Verify(projectID, userID string) error { return nil }

// Service 脚本业务逻辑层
type Service struct {
	store    SegmentStore
	verifier crossmodule.ProjectVerifier
	chat     capability.ChatCapability
	logger   *zap.Logger
}

// NewService 创建脚本服务
func NewService(store SegmentStore, verifier crossmodule.ProjectVerifier, chat capability.ChatCapability, logger *zap.Logger) *Service {
	if verifier == nil {
		verifier = DummyProjectVerifier{}
	}
	return &Service{store: store, verifier: verifier, chat: chat, logger: logger}
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
	taskID := fmt.Sprintf("script_parse_%d_%d", projectID, userID)
	return &ParseTask{TaskID: taskID, Status: "pending"}, nil
}

// ParseSync 同步解析（调用 LLM 将剧本文本解析为脚本分段）
func (s *Service) ParseSync(ctx context.Context, projectID, userID uint, req ScriptParseRequest) (*ParseResult, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
		return nil, err
	}

	if s.chat == nil {
		if s.logger != nil {
			s.logger.Warn("LLM 未配置，返回空解析结果")
		}
		return &ParseResult{Script: nil, Issues: []string{"LLM 未配置"}}, nil
	}

	messages := []capability.ChatMessage{
		{Role: "system", Content: prompt.ScriptParseSystem()},
		{Role: "user", Content: prompt.ScriptParseUser(req.Content)},
	}
	chatReq := capability.ChatRequest{Messages: messages}
	ch, err := s.chat.ChatStream(ctx, chatReq)
	if err != nil {
		if s.logger != nil {
			s.logger.Error("LLM 脚本解析失败", zap.Error(err))
		}
		return nil, pkg.NewBizError("AI 解析失败")
	}

	var sb strings.Builder
	for chunk := range ch {
		if chunk.Error != nil {
			return nil, pkg.NewBizError("AI 解析中断: " + chunk.Error.Error())
		}
		sb.WriteString(chunk.Content)
	}

	// 解析 LLM 输出为分段列表
	raw := strings.TrimSpace(sb.String())
	if idx := strings.Index(raw, "["); idx >= 0 {
		if end := strings.LastIndex(raw, "]"); end > idx {
			raw = raw[idx : end+1]
		}
	}
	var parsed []struct {
		Content   string `json:"content"`
		SortIndex int    `json:"sort_index"`
	}
	if err := json.Unmarshal([]byte(raw), &parsed); err != nil {
		if s.logger != nil {
			s.logger.Warn("LLM 输出解析失败", zap.String("raw_length", fmt.Sprintf("%d", len(raw))))
		}
		return &ParseResult{Script: nil, Issues: []string{"AI 输出格式解析失败"}}, nil
	}

	return &ParseResult{Script: parsed, Issues: []string{}}, nil
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

// StreamAssist AI 流式辅助（调用 LLM 进行扩写/细化/补全/润色）
func (s *Service) StreamAssist(ctx context.Context, req ScriptAiRequest) (<-chan ChatChunk, error) {
	if req.Action == "" {
		return nil, pkg.NewBizError("未指定 AI 操作类型")
	}

	if s.chat == nil {
		ch := make(chan ChatChunk, 1)
		ch <- ChatChunk{Content: "LLM 未配置，无法执行 AI 辅助", Done: true}
		close(ch)
		return ch, nil
	}

	instruction := req.Action
	if req.BlockType != "" {
		instruction += "（块类型: " + req.BlockType + "）"
	}
	currentContent := req.BlockContent
	if req.SceneMeta != "" {
		currentContent = "场景信息: " + req.SceneMeta + "\n\n" + currentContent
	}
	if len(req.ContextBlocks) > 0 {
		currentContent += "\n\n上下文:\n" + strings.Join(req.ContextBlocks, "\n")
	}

	messages := []capability.ChatMessage{
		{Role: "system", Content: prompt.ScriptAssistSystem()},
		{Role: "user", Content: prompt.ScriptAssistUser(instruction, currentContent)},
	}
	chatReq := capability.ChatRequest{
		ProviderHint: req.Provider,
		Model:        req.Model,
		Messages:     messages,
	}

	llmCh, err := s.chat.ChatStream(ctx, chatReq)
	if err != nil {
		if s.logger != nil {
			s.logger.Error("AI 辅助调用失败", zap.String("action", req.Action), zap.Error(err))
		}
		return nil, pkg.NewBizError("AI 辅助调用失败")
	}

	// 转换为 script 包内的 ChatChunk 类型
	out := make(chan ChatChunk, 16)
	go func() {
		defer close(out)
		for chunk := range llmCh {
			sc := ChatChunk{Content: chunk.Content, Done: chunk.Done}
			if chunk.Error != nil {
				sc.Error = chunk.Error.Error()
			}
			out <- sc
		}
	}()
	return out, nil
}
