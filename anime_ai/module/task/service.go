package task

import (
	"context"
	"encoding/json"
	"time"

	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
)

// 有效的任务类型
var validTypes = map[string]bool{
	"image": true, "video": true, "script": true,
	"export": true, "package": true,
	// 素材库资源生成
	"voice_design": true, "voice_clone": true, "text": true,
}

// 有效的任务状态
var validStatuses = map[string]bool{
	"pending": true, "running": true, "completed": true,
	"failed": true, "cancelled": true,
}

// Service 任务业务逻辑层
type Service struct {
	data     Data
	verifier crossmodule.ProjectVerifier
}

// NewService 创建 Service 实例
func NewService(data Data, verifier crossmodule.ProjectVerifier) *Service {
	return &Service{data: data, verifier: verifier}
}

// Create 创建任务，验证项目权限
func (s *Service) Create(ctx context.Context, projectID, userID, typ, title, description string, config json.RawMessage) (*TaskDTO, error) {
	if err := s.verifier.Verify(projectID, userID); err != nil {
		return nil, err
	}
	if !validTypes[typ] {
		return nil, pkg.NewBizError("无效的任务类型: " + typ)
	}
	return s.data.Create(ctx, CreateParams{
		ProjectID:   projectID,
		UserID:      userID,
		Type:        typ,
		Title:       title,
		Description: description,
		Config:      config,
	})
}

// CreateForUser 创建无项目归属的任务（素材库生成等场景）
func (s *Service) CreateForUser(ctx context.Context, userID, typ, title, description string, config json.RawMessage) (*TaskDTO, error) {
	if !validTypes[typ] {
		return nil, pkg.NewBizError("无效的任务类型: " + typ)
	}
	return s.data.Create(ctx, CreateParams{
		UserID:      userID,
		Type:        typ,
		Title:       title,
		Description: description,
		Config:      config,
	})
}

// ListParams 列表查询参数
type ListParams struct {
	ProjectID string
	UserID    string
	Type      string
	Status    string
	Limit     int32
	Offset    int32
}

// List 按条件列出任务（支持 project_id、type、status 过滤和分页）
func (s *Service) List(ctx context.Context, p ListParams) ([]*TaskDTO, error) {
	if p.Limit <= 0 || p.Limit > 50 {
		p.Limit = 20
	}
	if p.Offset < 0 {
		p.Offset = 0
	}

	// 优先按 project_id 查询
	if p.ProjectID != "" {
		hasType := p.Type != ""
		hasStatus := p.Status != ""
		switch {
		case hasType && hasStatus:
			return s.data.ListByProjectTypeAndStatus(ctx, p.ProjectID, p.Type, p.Status, p.Limit, p.Offset)
		case hasType:
			return s.data.ListByProjectAndType(ctx, p.ProjectID, p.Type, p.Limit, p.Offset)
		case hasStatus:
			return s.data.ListByProjectAndStatus(ctx, p.ProjectID, p.Status, p.Limit, p.Offset)
		default:
			return s.data.ListByProject(ctx, p.ProjectID, p.Limit, p.Offset)
		}
	}

	// 无 project_id 时按 user_id 查询
	if p.UserID != "" {
		return s.data.ListByUser(ctx, p.UserID, p.Limit, p.Offset)
	}

	return nil, pkg.NewBizError("缺少 project_id 或 user_id 参数")
}

// Get 获取单个任务
func (s *Service) Get(ctx context.Context, id string) (*TaskDTO, error) {
	if id == "" {
		return nil, pkg.ErrNotFound
	}
	return s.data.GetByID(ctx, id)
}

// BatchGet 批量获取任务
func (s *Service) BatchGet(ctx context.Context, ids []string) ([]*TaskDTO, error) {
	if len(ids) == 0 {
		return nil, nil
	}
	return s.data.ListByIDs(ctx, ids)
}

// Cancel 取消任务（仅 pending/running 状态可取消）
func (s *Service) Cancel(ctx context.Context, id, userID string) (*TaskDTO, error) {
	t, err := s.data.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if t.IsFinished() {
		return nil, pkg.NewBizError("任务已结束，无法取消")
	}
	return s.data.Cancel(ctx, id)
}

// BatchCancel 批量取消任务
func (s *Service) BatchCancel(ctx context.Context, ids []string, userID string) error {
	if len(ids) == 0 {
		return pkg.NewBizError("任务 ID 列表不能为空")
	}
	return s.data.BatchCancel(ctx, ids)
}

// UpdateProgress Worker 调用：更新任务进度
func (s *Service) UpdateProgress(ctx context.Context, id string, progress int32) (*TaskDTO, error) {
	if progress < 0 || progress > 100 {
		return nil, pkg.NewBizError("进度值必须在 0-100 之间")
	}
	return s.data.UpdateProgress(ctx, id, progress)
}

// UpdateStatus Worker 调用：更新任务状态
func (s *Service) UpdateStatus(ctx context.Context, id, status string, errorMsg *string) (*TaskDTO, error) {
	if !validStatuses[status] {
		return nil, pkg.NewBizError("无效的任务状态: " + status)
	}
	var startedAt, completedAt *time.Time
	now := time.Now()
	if status == "running" {
		startedAt = &now
	}
	if status == "completed" || status == "failed" {
		completedAt = &now
	}
	return s.data.UpdateStatus(ctx, id, status, errorMsg, startedAt, completedAt)
}

// TaskRecorder Worker 可使用的任务记录接口
type TaskRecorder interface {
	RecordStart(ctx context.Context, id string) error
	RecordProgress(ctx context.Context, id string, progress int32) error
	RecordComplete(ctx context.Context, id string, result json.RawMessage) error
	RecordFailed(ctx context.Context, id string, errMsg string) error
}

// NewTaskRecorder 基于 Service 创建 TaskRecorder
func NewTaskRecorder(svc *Service) TaskRecorder {
	return &taskRecorderImpl{svc: svc}
}

type taskRecorderImpl struct {
	svc *Service
}

func (r *taskRecorderImpl) RecordStart(ctx context.Context, id string) error {
	_, err := r.svc.UpdateStatus(ctx, id, "running", nil)
	return err
}

func (r *taskRecorderImpl) RecordProgress(ctx context.Context, id string, progress int32) error {
	_, err := r.svc.UpdateProgress(ctx, id, progress)
	return err
}

func (r *taskRecorderImpl) RecordComplete(ctx context.Context, id string, result json.RawMessage) error {
	if result != nil {
		if _, err := r.svc.data.UpdateResult(ctx, id, result); err != nil {
			return err
		}
	}
	_, err := r.svc.UpdateStatus(ctx, id, "completed", nil)
	return err
}

func (r *taskRecorderImpl) RecordFailed(ctx context.Context, id string, errMsg string) error {
	_, err := r.svc.UpdateStatus(ctx, id, "failed", &errMsg)
	return err
}
