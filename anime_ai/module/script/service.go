package script

import (
	"context"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// DummyProjectVerifier 占位实现，始终通过验证
type DummyProjectVerifier struct{}

func (DummyProjectVerifier) Verify(projectID, userID string) error { return nil }

// Service 脚本业务逻辑层
type Service struct {
	store    SegmentStore
	verifier crossmodule.ProjectVerifier
}

// NewService 创建脚本服务
func NewService(store SegmentStore, verifier crossmodule.ProjectVerifier) *Service {
	if verifier == nil {
		verifier = DummyProjectVerifier{}
	}
	return &Service{store: store, verifier: verifier}
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

// ParseSync 同步解析（占位：返回空结构）
func (s *Service) ParseSync(ctx context.Context, projectID, userID uint, req ScriptParseRequest) (*ParseResult, error) {
	if err := s.verifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
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

// StreamAssist AI 流式辅助（占位：返回立即关闭的空 channel）
func (s *Service) StreamAssist(ctx context.Context, req ScriptAiRequest) (<-chan ChatChunk, error) {
	_ = s
	if req.Action == "" {
		return nil, fmt.Errorf("未知的 AI 操作")
	}
	ch := make(chan ChatChunk, 1)
	ch <- ChatChunk{Done: true}
	close(ch)
	return ch, nil
}
