package character

import (
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/crossmodule"
	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
)

// Service 角色业务逻辑层
type Service struct {
	data           Data
	projectVerifier crossmodule.ProjectVerifier
}

// NewService 创建 Service 实例
func NewService(data Data, projectVerifier crossmodule.ProjectVerifier) *Service {
	return &Service{data: data, projectVerifier: projectVerifier}
}

// CreateCharacterRequest 创建角色请求
type CreateCharacterRequest struct {
	ProjectID            *uint  `json:"project_id"`
	Name                 string `json:"name" binding:"required"`
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
	uidStr := pkg.UUIDString(pkg.UintToUUID(userID))
	var projectIDStr *string
	if req.ProjectID != nil {
		s := pkg.UUIDString(pkg.UintToUUID(*req.ProjectID))
		projectIDStr = &s
	}
	c := &Character{
		UserID:               uidStr,
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
func (s *Service) ListByProject(projectID, userID uint) ([]Character, error) {
	if s.projectVerifier != nil {
		if err := s.projectVerifier.Verify(pkg.UUIDString(pkg.UintToUUID(projectID)), pkg.UUIDString(pkg.UintToUUID(userID))); err != nil {
			return nil, err
		}
	}
	return s.data.ListCharactersByProject(projectID)
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
	c.Status = CharacterStatusConfirmed
	if err := s.data.UpdateCharacter(c); err != nil {
		return nil, err
	}
	return c, nil
}

// BatchConfirm 批量确认
func (s *Service) BatchConfirm(ids []string, userID uint) error {
	for _, id := range ids {
		c, err := s.data.FindCharacterByID(id)
		if err != nil {
			continue
		}
		if !userIDMatches(c.UserID, userID) {
			continue
		}
		c.Status = CharacterStatusConfirmed
		_ = s.data.UpdateCharacter(c)
	}
	return nil
}

// userIDMatches 判断角色 UserID 是否匹配给定 userID（uint）
func userIDMatches(userIDStr string, userID uint) bool {
	return userIDStr == pkg.UUIDString(pkg.UintToUUID(userID)) ||
		userIDStr == fmt.Sprintf("%d", userID)
}

// BatchSetStyle 批量设置风格
func (s *Service) BatchSetStyle(ids []string, userID uint, style string) (int, error) {
	count := 0
	for _, id := range ids {
		c, err := s.data.FindCharacterByID(id)
		if err != nil {
			continue
		}
		if !userIDMatches(c.UserID, userID) {
			continue
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
	count := 0
	for _, id := range ids {
		c, err := s.data.FindCharacterByID(id)
		if err != nil {
			continue
		}
		if !userIDMatches(c.UserID, userID) {
			continue
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
