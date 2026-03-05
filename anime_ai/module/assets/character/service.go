package character

import (
	"context"
	"fmt"
	"strconv"

	"anime_ai/pub/auth"
	"anime_ai/pub/crossmodule"
	"anime_ai/pub/pkg"
)

// Service 角色业务逻辑层
type Service struct {
	data               Data
	projectVerifier    crossmodule.ProjectVerifier
	memberResolver     crossmodule.ProjectMemberResolver
	frozenAssetChecker crossmodule.FrozenAssetChecker
}

// NewService 创建 Service 实例
func NewService(data Data, projectVerifier crossmodule.ProjectVerifier) *Service {
	return NewServiceWithResolver(data, projectVerifier, nil)
}

// NewServiceWithResolver 创建 Service 实例（含成员解析器，用于工种权限校验）
func NewServiceWithResolver(data Data, projectVerifier crossmodule.ProjectVerifier, memberResolver crossmodule.ProjectMemberResolver) *Service {
	return &Service{
		data:            data,
		projectVerifier: projectVerifier,
		memberResolver:  memberResolver,
	}
}

// SetFrozenAssetChecker 注入资产冻结检查器（assets 锁定后禁止修改已纳入版本的角色）
func (s *Service) SetFrozenAssetChecker(c crossmodule.FrozenAssetChecker) {
	s.frozenAssetChecker = c
}

// CreateCharacterRequest 创建角色请求
type CreateCharacterRequest struct {
	ProjectID            *string `json:"project_id"`
	Name                 string  `json:"name" binding:"required"`
	AliasJSON            string `json:"alias_json"`
	Appearance           string `json:"appearance"`
	Style                string `json:"style"`
	StyleOverride        bool   `json:"style_override"`
	Personality          string `json:"personality"`
	VoiceHint            string `json:"voice_hint"`
	Emotions             string `json:"emotions"`
	Scenes               string `json:"scenes"`
	Gender               string `json:"gender"`
	AgeGroup             string `json:"age_group"`
	VoiceID              string `json:"voice_id"`
	VoiceName            string `json:"voice_name"`
	ImageURL             string `json:"image_url"`
	ReferenceImagesJSON  string `json:"reference_images_json"`
	Shared               bool   `json:"shared"`
	Importance           string `json:"importance"`
	Consistency          string `json:"consistency"`
	RoleType             string `json:"role_type"`
	TagsJSON             string `json:"tags_json"`
	PropsJSON            string `json:"props_json"`
	Bio                  string `json:"bio"`
	BioFragmentsJSON     string `json:"bio_fragments_json"`
	ImageGenOverrideJSON string `json:"image_gen_override_json"`
}

// UpdateCharacterRequest 更新角色请求
type UpdateCharacterRequest struct {
	Name                 *string `json:"name"`
	AliasJSON            *string `json:"alias_json"`
	Appearance           *string `json:"appearance"`
	Style                *string `json:"style"`
	StyleOverride        *bool   `json:"style_override"`
	Personality          *string `json:"personality"`
	VoiceHint            *string `json:"voice_hint"`
	Emotions             *string `json:"emotions"`
	Scenes               *string `json:"scenes"`
	Gender               *string `json:"gender"`
	AgeGroup             *string `json:"age_group"`
	VoiceID              *string `json:"voice_id"`
	VoiceName            *string `json:"voice_name"`
	ImageURL             *string `json:"image_url"`
	ReferenceImagesJSON  *string `json:"reference_images_json"`
	Shared               *bool   `json:"shared"`
	Status               *string `json:"status"`
	Source               *string `json:"source"`
	Importance           *string `json:"importance"`
	Consistency          *string `json:"consistency"`
	RoleType             *string `json:"role_type"`
	TagsJSON             *string `json:"tags_json"`
	PropsJSON            *string `json:"props_json"`
	Bio                  *string `json:"bio"`
	BioFragmentsJSON     *string `json:"bio_fragments_json"`
	ImageGenOverrideJSON *string `json:"image_gen_override_json"`
}

// Create 创建角色
func (s *Service) Create(userID uint, req CreateCharacterRequest) (*Character, error) {
	userIDStr := pkg.UUIDString(pkg.UintToUUID(userID))
	var projectIDStr *string
	if req.ProjectID != nil && *req.ProjectID != "" {
		projectIDStr = req.ProjectID
		if err := s.checkAssetEditForProject(*req.ProjectID, userIDStr); err != nil {
			return nil, err
		}
	}
	c := &Character{
		UserID:               userIDStr,
		ProjectID:            projectIDStr,
		Name:                 req.Name,
		AliasJSON:            req.AliasJSON,
		Appearance:           req.Appearance,
		Style:                req.Style,
		StyleOverride:        req.StyleOverride,
		Personality:          req.Personality,
		VoiceHint:            req.VoiceHint,
		Emotions:             req.Emotions,
		Scenes:               req.Scenes,
		Gender:               req.Gender,
		AgeGroup:             req.AgeGroup,
		VoiceID:              req.VoiceID,
		VoiceName:            req.VoiceName,
		ImageURL:             req.ImageURL,
		ReferenceImagesJSON:  req.ReferenceImagesJSON,
		Shared:               req.Shared,
		Importance:           req.Importance,
		Consistency:          req.Consistency,
		RoleType:             req.RoleType,
		TagsJSON:             req.TagsJSON,
		PropsJSON:            req.PropsJSON,
		Bio:                  req.Bio,
		BioFragmentsJSON:     req.BioFragmentsJSON,
		ImageGenOverrideJSON: req.ImageGenOverrideJSON,
	}
	if err := s.data.CreateCharacter(c); err != nil {
		return nil, err
	}
	return c, nil
}

// CreateSkeleton 创建骨架角色（剧本导入后从场数据提取，status=skeleton）
func (s *Service) CreateSkeleton(projectIDStr, userIDStr, name string) (*Character, error) {
	if err := s.checkAssetEditForProject(projectIDStr, userIDStr); err != nil {
		return nil, err
	}
	projID := projectIDStr
	// 将 userIDStr 统一为 UUID 格式：若为数字则转确定性 UUID，否则原样使用
	normalizedUID := normalizeUserID(userIDStr)
	c := &Character{
		UserID:    normalizedUID,
		ProjectID: &projID,
		Name:      name,
		Status:    CharacterStatusSkeleton,
		Source:    CharacterSourceSkeleton,
	}
	if err := s.data.CreateCharacter(c); err != nil {
		return nil, err
	}
	return c, nil
}

// Get 获取角色详情（需权限）
func (s *Service) Get(id string, userID uint) (*Character, error) {
	c, err := s.data.FindCharacterByID(id)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) && !c.Shared {
		return nil, fmt.Errorf("无权访问此角色")
	}
	return c, nil
}

// ListByProject 按项目列出角色（需验证项目归属）
func (s *Service) ListByProject(projectIDStr, userIDStr string) ([]Character, error) {
	if s.projectVerifier != nil {
		if err := s.projectVerifier.Verify(projectIDStr, userIDStr); err != nil {
			return nil, err
		}
	}
	return s.data.ListCharactersByProject(projectIDStr)
}

// ListConfirmedCharacterIDs 列出项目内已确认角色的 ID（供跨模块 collector 使用，不校验用户权限）
func (s *Service) ListConfirmedCharacterIDs(ctx context.Context, projectID string) ([]string, error) {
	_ = ctx // 预留，Data 层当前无 context
	chars, err := s.data.ListCharactersByProject(projectID)
	if err != nil {
		return nil, err
	}
	var ids []string
	for _, ch := range chars {
		if ch.Status == CharacterStatusConfirmed && ch.ID != "" {
			ids = append(ids, ch.ID)
		}
	}
	return ids, nil
}

// checkAssetEditForProject 校验项目内资产编辑权限（projectIDStr/userIDStr 为字符串）
func (s *Service) checkAssetEditForProject(projectIDStr, userIDStr string) error {
	if s.memberResolver == nil {
		return nil
	}
	return s.checkAssetEdit(projectIDStr, userIDStr)
}

func (s *Service) checkAssetEdit(projectIDStr, userIDStr string) error {
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
	if !auth.CanDo(info.JobRoles, auth.ActionAssetEdit) {
		return fmt.Errorf("%w: 当前工种不允许编辑资产", pkg.ErrForbidden)
	}
	return nil
}

// ListLibrary 列出用户角色库（含共享）
func (s *Service) ListLibrary(userID uint) ([]Character, error) {
	return s.data.ListCharactersByUser(userID, true)
}

// Update 更新角色
func (s *Service) Update(id string, userID uint, req UpdateCharacterRequest) (*Character, error) {
	c, err := s.data.FindCharacterByID(id)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权修改此角色")
	}
	if c.ProjectID != nil && *c.ProjectID != "" {
		if err := s.checkAssetEdit(*c.ProjectID, pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
			return nil, err
		}
		if s.frozenAssetChecker != nil {
			inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(*c.ProjectID, "character", id)
			if err == nil && inFrozen {
				return nil, fmt.Errorf("%w: assets 阶段已锁定，该角色已纳入版本，无法修改", pkg.ErrPhaseLocked)
			}
		}
	}

	applyUpdate(c, req)
	if err := s.data.UpdateCharacter(c); err != nil {
		return nil, err
	}
	return c, nil
}

func applyUpdate(c *Character, req UpdateCharacterRequest) {
	if req.Name != nil {
		c.Name = *req.Name
	}
	if req.AliasJSON != nil {
		c.AliasJSON = *req.AliasJSON
	}
	if req.Appearance != nil {
		c.Appearance = *req.Appearance
	}
	if req.Style != nil {
		c.Style = *req.Style
	}
	if req.StyleOverride != nil {
		c.StyleOverride = *req.StyleOverride
	}
	if req.Personality != nil {
		c.Personality = *req.Personality
	}
	if req.VoiceHint != nil {
		c.VoiceHint = *req.VoiceHint
	}
	if req.Emotions != nil {
		c.Emotions = *req.Emotions
	}
	if req.Scenes != nil {
		c.Scenes = *req.Scenes
	}
	if req.Gender != nil {
		c.Gender = *req.Gender
	}
	if req.AgeGroup != nil {
		c.AgeGroup = *req.AgeGroup
	}
	if req.VoiceID != nil {
		c.VoiceID = *req.VoiceID
	}
	if req.VoiceName != nil {
		c.VoiceName = *req.VoiceName
	}
	if req.ImageURL != nil {
		c.ImageURL = *req.ImageURL
		if *req.ImageURL != "" {
			c.ImageStatus = "completed"
		}
	}
	if req.ReferenceImagesJSON != nil {
		c.ReferenceImagesJSON = *req.ReferenceImagesJSON
	}
	if req.Shared != nil {
		c.Shared = *req.Shared
	}
	if req.Status != nil {
		c.Status = *req.Status
	}
	if req.Source != nil {
		c.Source = *req.Source
	}
	if req.Importance != nil {
		c.Importance = *req.Importance
	}
	if req.Consistency != nil {
		c.Consistency = *req.Consistency
	}
	if req.RoleType != nil {
		c.RoleType = *req.RoleType
	}
	if req.TagsJSON != nil {
		c.TagsJSON = *req.TagsJSON
	}
	if req.PropsJSON != nil {
		c.PropsJSON = *req.PropsJSON
	}
	if req.Bio != nil {
		c.Bio = *req.Bio
	}
	if req.BioFragmentsJSON != nil {
		c.BioFragmentsJSON = *req.BioFragmentsJSON
	}
	if req.ImageGenOverrideJSON != nil {
		c.ImageGenOverrideJSON = *req.ImageGenOverrideJSON
	}
}

// Confirm 确认角色
func (s *Service) Confirm(id string, userID uint) (*Character, error) {
	c, err := s.data.FindCharacterByID(id)
	if err != nil {
		return nil, fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, fmt.Errorf("无权操作此角色")
	}
	if c.ProjectID != nil && *c.ProjectID != "" {
		if err := s.checkAssetEdit(*c.ProjectID, pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
			return nil, err
		}
		if s.frozenAssetChecker != nil {
			inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(*c.ProjectID, "character", id)
			if err == nil && inFrozen {
				return nil, fmt.Errorf("%w: assets 阶段已锁定，该角色已纳入版本，无法确认", pkg.ErrPhaseLocked)
			}
		}
	}
	c.Status = CharacterStatusConfirmed
	if err := s.data.UpdateCharacter(c); err != nil {
		return nil, err
	}
	return c, nil
}

// BatchConfirm 批量确认，返回已更新的角色列表（与单条 Confirm 返回单条一致，前端直接合并 state，无需 refetch）
// 若传入非空 ids 但全部被跳过（权限/冻结等），返回业务错误便于前端提示
// 注意：内部调用 BatchConfirmWithUserStr，因 JWT 可能存 user_id 为 UUID 字符串，GetUint 会得 0 导致匹配失败
func (s *Service) BatchConfirm(ids []string, userID uint) ([]*Character, error) {
	userIDStr := pkg.UUIDString(pkg.UintToUUID(userID))
	if userIDStr == "" {
		userIDStr = pkg.UintToStr(userID)
	}
	return s.BatchConfirmWithUserStr(ids, userIDStr)
}

// BatchConfirmWithUserStr 批量确认（接收 userID 字符串，兼容 JWT 存 UUID 的场景）
func (s *Service) BatchConfirmWithUserStr(ids []string, userIDStr string) ([]*Character, error) {
	var out []*Character
	for _, id := range ids {
		c, err := s.data.FindCharacterByID(id)
		if err != nil {
			continue
		}
		if !userIDMatchesStr(c.UserID, userIDStr) {
			continue
		}
		if c.ProjectID != nil && *c.ProjectID != "" {
			if err := s.checkAssetEdit(*c.ProjectID, userIDStr); err != nil {
				continue
			}
			if s.frozenAssetChecker != nil {
				inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(*c.ProjectID, "character", id)
				if err == nil && inFrozen {
					continue
				}
			}
		}
		c.Status = CharacterStatusConfirmed
		if err := s.data.UpdateCharacter(c); err != nil {
			return out, fmt.Errorf("更新角色 %s 状态失败: %w", id, err)
		}
		out = append(out, c)
	}
	if len(ids) > 0 && len(out) == 0 {
		return nil, pkg.NewBizError("无角色可确认：请确认所选角色属于当前项目、您有编辑权限且资产未冻结")
	}
	return out, nil
}

// normalizeUserID 将 userIDStr 统一为 UUID 格式：若为纯数字则通过 UintToUUID 转为确定性 UUID，
// 否则原样返回。避免数字字符串存入 DB 后被 ParseUUID 回退为零 UUID 导致权限校验失败。
func normalizeUserID(userIDStr string) string {
	if n, err := strconv.ParseUint(userIDStr, 10, 64); err == nil {
		return pkg.UUIDString(pkg.UintToUUID(uint(n)))
	}
	return userIDStr
}

// userIDMatches 判断角色 UserID 是否匹配给定 userID（uint）
func userIDMatches(userIDStr string, userID uint) bool {
	return userIDStr == pkg.UUIDString(pkg.UintToUUID(userID)) ||
		userIDStr == fmt.Sprintf("%d", userID)
}

// userIDMatchesStr 判断角色 UserID 是否匹配给定 userIDStr（string，用于 GetUserIDStr 场景）
func userIDMatchesStr(fromChar, fromCtx string) bool {
	if fromChar == fromCtx {
		return true
	}
	// MemData 可能存 "1"，上下文为 UUID
	if u, err := strconv.ParseUint(fromChar, 10, 64); err == nil {
		return fromCtx == pkg.UUIDString(pkg.UintToUUID(uint(u)))
	}
	return false
}

// BatchSetStyle 批量设置风格
func (s *Service) BatchSetStyle(ids []string, userID uint, style string) (int, error) {
	userIDStr := pkg.UUIDString(pkg.UintToUUID(userID))
	count := 0
	for _, id := range ids {
		c, err := s.data.FindCharacterByID(id)
		if err != nil {
			continue
		}
		if !userIDMatches(c.UserID, userID) {
			continue
		}
		if c.ProjectID != nil && *c.ProjectID != "" {
			if err := s.checkAssetEdit(*c.ProjectID, userIDStr); err != nil {
				continue
			}
		}
		c.Style = style
		c.StyleOverride = false
		if err := s.data.UpdateCharacter(c); err == nil {
			count++
		}
	}
	return count, nil
}

// BatchAIComplete 批量 AI 补全（骨架/草稿 → 草稿）
func (s *Service) BatchAIComplete(ids []string, userID uint) (int, error) {
	userIDStr := pkg.UUIDString(pkg.UintToUUID(userID))
	count := 0
	for _, id := range ids {
		c, err := s.data.FindCharacterByID(id)
		if err != nil {
			continue
		}
		if !userIDMatches(c.UserID, userID) {
			continue
		}
		if c.ProjectID != nil && *c.ProjectID != "" {
			if err := s.checkAssetEdit(*c.ProjectID, userIDStr); err != nil {
				continue
			}
		}
		if c.Status != CharacterStatusSkeleton && c.Status != CharacterStatusDraft {
			continue
		}
		if c.Status == CharacterStatusSkeleton {
			c.Status = CharacterStatusDraft
		}
		if err := s.data.UpdateCharacter(c); err == nil {
			count++
		}
	}
	return count, nil
}

// Delete 删除角色
func (s *Service) Delete(id string, userID uint) error {
	c, err := s.data.FindCharacterByID(id)
	if err != nil {
		return fmt.Errorf("角色不存在: %w", err)
	}
	if !userIDMatches(c.UserID, userID) {
		return fmt.Errorf("无权删除此角色")
	}
	if c.ProjectID != nil && *c.ProjectID != "" {
		if err := s.checkAssetEdit(*c.ProjectID, pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
			return err
		}
		if s.frozenAssetChecker != nil {
			inFrozen, err := s.frozenAssetChecker.IsAssetInFrozenVersion(*c.ProjectID, "character", id)
			if err == nil && inFrozen {
				return fmt.Errorf("%w: assets 阶段已锁定，该角色已纳入版本，无法删除", pkg.ErrPhaseLocked)
			}
		}
	}
	return s.data.DeleteCharacter(id)
}

// GenerateImage 形象生成（占位：仅更新状态，不实际入队）
func (s *Service) GenerateImage(id string, userID uint, providerName, modelName string) (*Character, error) {
	c, err := s.data.FindCharacterByID(id)
	if err != nil {
		return nil, pkg.NewBizError("角色不存在")
	}
	if !userIDMatches(c.UserID, userID) {
		return nil, pkg.NewBizError("无权操作此角色")
	}
	if c.ProjectID != nil && *c.ProjectID != "" {
		if err := s.checkAssetEdit(*c.ProjectID, pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
			return nil, err
		}
	}
	if c.Appearance == "" {
		return nil, pkg.NewBizError("请先填写角色外观描述")
	}
	// 占位：不实际调用 worker，仅模拟入队成功
	_ = providerName
	_ = modelName
	c.TaskID = "placeholder-task-id"
	c.ImageStatus = "generating"
	_ = s.data.UpdateCharacterImage(id, c.ImageURL, c.TaskID, c.ImageStatus)
	return c, nil
}
