package character

import "time"

// 角色状态常量
const (
	CharacterStatusDraft     = "draft"
	CharacterStatusConfirmed = "confirmed"
	CharacterStatusSkeleton  = "skeleton"
)

// 角色来源常量
const (
	CharacterSourceAutoExtract = "auto_extract"
	CharacterSourceProfile     = "profile_import"
	CharacterSourceLibrary     = "character_lib"
	CharacterSourceManual      = "manual"
	CharacterSourceSkeleton    = "skeleton"
)

// Character 角色实体（camelCase 以兼容 Flutter）
// ID 为 string（UUID 格式），与 sch/db pgtype.UUID 兼容
type Character struct {
	ID        string    `json:"id"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`

	UserID    string  `json:"userId"`
	ProjectID *string `json:"projectId"`
	Name      string  `json:"name"`

	AliasJSON           string `json:"aliasJson"`
	Appearance          string `json:"appearance"`
	Style               string `json:"style"`
	StyleID             *string `json:"styleId"`
	StyleOverride       bool   `json:"styleOverride"`
	Personality         string `json:"personality"`
	VoiceHint           string `json:"voiceHint"`
	Emotions            string `json:"emotions"`
	Scenes              string `json:"scenes"`
	Gender              string `json:"gender"`
	AgeGroup            string `json:"ageGroup"`
	VoiceID             string `json:"voiceId"`
	VoiceName           string `json:"voiceName"`
	ImageURL            string `json:"imageUrl"`
	ReferenceImagesJSON string `json:"referenceImagesJson"`
	TaskID              string `json:"taskId"`
	ImageStatus         string `json:"imageStatus"`
	Shared              bool   `json:"shared"`
	Status              string `json:"status"`
	Source              string `json:"source"`
	VariantsJSON        string `json:"variantsJson"`

	Importance          string `json:"importance"`
	Consistency         string `json:"consistency"`
	RoleType            string `json:"roleType"`
	TagsJSON            string `json:"tagsJson"`
	PropsJSON           string `json:"propsJson"`
	Bio                 string `json:"bio"`
	BioFragmentsJSON    string `json:"bioFragmentsJson"`
	ImageGenOverrideJSON string `json:"imageGenOverrideJson"`

	Version int `json:"version"`
}

// CharacterSnapshot 角色状态快照 — 记录角色在不同剧情阶段的外貌/心理/关系变化
// 快照仍用 MemData，ID 为 uint
type CharacterSnapshot struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	CharacterID string `json:"character_id"` // 对应 Character.ID
	ProjectID   string `json:"project_id"`   // 项目 ID 字符串（UUID）

	StartSceneID string `json:"start_scene_id"`
	EndSceneID   string `json:"end_scene_id"`
	TriggerEvent string `json:"trigger_event"`

	Costume       string `json:"costume"`
	Hairstyle     string `json:"hairstyle"`
	PhysicalMarks string `json:"physical_marks"`
	Accessories   string `json:"accessories"`

	MentalState string `json:"mental_state"`
	Demeanor    string `json:"demeanor"`

	RelationshipsJSON  string `json:"relationships_json"`
	ComposedAppearance string `json:"composed_appearance"`

	SortIndex int    `json:"sort_index"`
	Source    string `json:"source"` // human / ai / mixed
}
