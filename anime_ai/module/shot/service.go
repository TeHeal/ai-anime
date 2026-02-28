package shot

import (
	"errors"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// Service 镜头业务逻辑层
type Service struct {
	store           ShotStore
	projectVerifier crossmodule.ProjectVerifier
}

// NewService 创建镜头服务
func NewService(store ShotStore, projectVerifier crossmodule.ProjectVerifier) *Service {
	return &Service{
		store:           store,
		projectVerifier: projectVerifier,
	}
}

// CreateShotRequest 创建镜头请求，ID 使用 string（UUID）
type CreateShotRequest struct {
	SegmentID   *string `json:"segment_id"`
	SceneID     *string `json:"scene_id"`
	Prompt      string  `json:"prompt"`
	StylePrompt string  `json:"style_prompt"`
	Duration    int     `json:"duration"`
}

// UpdateShotRequest 更新镜头请求
type UpdateShotRequest struct {
	Prompt         *string `json:"prompt"`
	StylePrompt    *string `json:"style_prompt"`
	Duration       *int    `json:"duration"`
	SegmentID      *string `json:"segment_id"`
	SceneID        *string `json:"scene_id"`
	CameraType     *string `json:"camera_type"`
	CameraAngle    *string `json:"camera_angle"`
	Dialogue       *string `json:"dialogue"`
	Voice          *string `json:"voice"`
	LipSync        *string `json:"lip_sync"`
	CharacterName  *string `json:"character_name"`
	CharacterID    *string `json:"character_id"`
	Emotion        *string `json:"emotion"`
	VoiceName      *string `json:"voice_name"`
	Transition     *string `json:"transition"`
	AudioDesign    *string `json:"audio_design"`
	Priority       *string `json:"priority"`
	NegativePrompt *string `json:"negative_prompt"`
}

// BulkCreateShotRequest 批量创建镜头请求
type BulkCreateShotRequest struct {
	Shots []CreateShotRequest `json:"shots" binding:"required,min=1"`
}

func (s *Service) verifyProject(projectID, userID string) error {
	if s.projectVerifier != nil {
		if err := s.projectVerifier.Verify(projectID, userID); err != nil {
			if errors.Is(err, pkg.ErrNotFound) {
				return fmt.Errorf("项目不存在: %w", err)
			}
			return err
		}
	}
	return nil
}

// Create 创建镜头
func (s *Service) Create(projectID, userID string, req CreateShotRequest) (*Shot, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	count, _ := s.store.CountByProject(projectID)
	dur := req.Duration
	if dur <= 0 {
		dur = 5
	}
	sh := &Shot{
		ProjectID:   projectID,
		SegmentID:   req.SegmentID,
		SceneID:     req.SceneID,
		SortIndex:   int(count),
		Prompt:      req.Prompt,
		StylePrompt: req.StylePrompt,
		Duration:    dur,
		Status:      StatusPending,
	}
	if err := s.store.Create(sh); err != nil {
		return nil, err
	}
	return sh, nil
}

// BulkCreate 批量创建镜头
func (s *Service) BulkCreate(projectID, userID string, req BulkCreateShotRequest) ([]Shot, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	count, _ := s.store.CountByProject(projectID)
	shots := make([]Shot, len(req.Shots))
	for i, r := range req.Shots {
		dur := r.Duration
		if dur <= 0 {
			dur = 5
		}
		shots[i] = Shot{
			ProjectID:   projectID,
			SegmentID:   r.SegmentID,
			SceneID:     r.SceneID,
			SortIndex:   int(count) + i,
			Prompt:      r.Prompt,
			StylePrompt: r.StylePrompt,
			Duration:    dur,
			Status:      StatusPending,
		}
	}
	if err := s.store.BulkCreate(shots); err != nil {
		return nil, err
	}
	return shots, nil
}

// List 列出镜头
func (s *Service) List(projectID, userID string, reviewStatus string) ([]Shot, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	if reviewStatus != "" {
		return s.store.ListByProjectFiltered(projectID, reviewStatus)
	}
	return s.store.ListByProject(projectID)
}

// Get 获取镜头
func (s *Service) Get(shotID, userID string) (*Shot, error) {
	sh, err := s.store.FindByID(shotID)
	if err != nil {
		return nil, fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(sh.ProjectID, userID); err != nil {
		return nil, err
	}
	return sh, nil
}

// Update 更新镜头
func (s *Service) Update(shotID, userID string, req UpdateShotRequest) (*Shot, error) {
	sh, err := s.store.FindByID(shotID)
	if err != nil {
		return nil, fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(sh.ProjectID, userID); err != nil {
		return nil, err
	}
	applyUpdate(sh, req)
	if err := s.store.Update(sh); err != nil {
		return nil, err
	}
	return sh, nil
}

func applyUpdate(sh *Shot, req UpdateShotRequest) {
	if req.Prompt != nil {
		sh.Prompt = *req.Prompt
	}
	if req.StylePrompt != nil {
		sh.StylePrompt = *req.StylePrompt
	}
	if req.Duration != nil && *req.Duration > 0 {
		sh.Duration = *req.Duration
	}
	if req.SegmentID != nil {
		sh.SegmentID = req.SegmentID
	}
	if req.SceneID != nil {
		sh.SceneID = req.SceneID
	}
	if req.CameraType != nil {
		sh.CameraType = *req.CameraType
	}
	if req.CameraAngle != nil {
		sh.CameraAngle = *req.CameraAngle
	}
	if req.Dialogue != nil {
		sh.Dialogue = *req.Dialogue
	}
	if req.Voice != nil {
		sh.Voice = *req.Voice
	}
	if req.LipSync != nil {
		sh.LipSync = *req.LipSync
	}
	if req.CharacterName != nil {
		sh.CharacterName = *req.CharacterName
	}
	if req.CharacterID != nil {
		sh.CharacterID = req.CharacterID
	}
	if req.Emotion != nil {
		sh.Emotion = *req.Emotion
	}
	if req.VoiceName != nil {
		sh.VoiceName = *req.VoiceName
	}
	if req.Transition != nil {
		sh.Transition = *req.Transition
	}
	if req.AudioDesign != nil {
		sh.AudioDesign = *req.AudioDesign
	}
	if req.Priority != nil {
		sh.Priority = *req.Priority
	}
	if req.NegativePrompt != nil {
		sh.NegativePrompt = *req.NegativePrompt
	}
}

// Delete 删除镜头
func (s *Service) Delete(shotID, userID string) error {
	sh, err := s.store.FindByID(shotID)
	if err != nil {
		return fmt.Errorf("镜头不存在: %w", err)
	}
	if err := s.verifyProject(sh.ProjectID, userID); err != nil {
		return err
	}
	return s.store.Delete(shotID)
}

// Reorder 排序镜头
func (s *Service) Reorder(projectID, userID string, orderedIDs []string) error {
	if err := s.verifyProject(projectID, userID); err != nil {
		return err
	}
	return s.store.ReorderByProject(projectID, orderedIDs)
}

// BatchGenerate 批量生成镜头（占位，后续接 Worker）
// 执行前对每个 shot 加锁，被他人锁定时返回 status=locked（README 2.3）
func (s *Service) BatchGenerate(projectID, userID string, shotIDs []string) ([]GenerateResult, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	shots, err := s.store.BatchFindByIDs(shotIDs)
	if err != nil {
		return nil, err
	}
	shotMap := make(map[string]*Shot)
	for i := range shots {
		shotMap[shots[i].ID] = &shots[i]
	}
	results := make([]GenerateResult, len(shotIDs))
	for i, id := range shotIDs {
		if sh, ok := shotMap[id]; ok && sh.ProjectID != projectID {
			results[i] = GenerateResult{ShotID: id, Status: "error", Error: "镜头不属于该项目"}
			continue
		}
		if err := s.store.TryLockShot(id, userID); err != nil {
			if errors.Is(err, pkg.ErrLocked) {
				results[i] = GenerateResult{ShotID: id, Status: "locked", Error: "该镜头正在被他人执行"}
				continue
			}
			results[i] = GenerateResult{ShotID: id, Status: "error", Error: err.Error()}
			continue
		}
		results[i] = GenerateResult{ShotID: id, Status: "queued", TaskIDs: []string{}}
	}
	return results, nil
}

// GenerateResult 生成入队结果（占位）
type GenerateResult struct {
	ShotID  string   `json:"shot_id"`
	TaskIDs []string `json:"task_ids"`
	Status  string   `json:"status"`
	Error   string   `json:"error,omitempty"`
}

// BatchComposite 批量合成（占位，后续接 Worker）
func (s *Service) BatchComposite(projectID, userID string, shotIDs []string) ([]CompositeResult, error) {
	if err := s.verifyProject(projectID, userID); err != nil {
		return nil, err
	}
	results := make([]CompositeResult, len(shotIDs))
	for i, id := range shotIDs {
		results[i] = CompositeResult{ShotID: id, Status: "queued", TaskIDs: []string{}}
	}
	return results, nil
}

// CompositeResult 合成入队结果（占位）
type CompositeResult struct {
	ShotID  string   `json:"shot_id"`
	TaskIDs []string `json:"task_ids"`
	Status  string   `json:"status"`
	Error   string   `json:"error,omitempty"`
}
