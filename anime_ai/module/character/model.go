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

// Character 角色实体
// ID 为 string（UUID 格式），与 sch/db pgtype.UUID 兼容
type Character struct {
	ID        string    `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	UserID    string  `json:"user_id"`    // UUID 格式
	ProjectID *string `json:"project_id"`  // UUID 格式
	Name      string  `json:"name"`

	AliasJSON           string `json:"alias_json"`
	Appearance          string `json:"appearance"`
	Style               string `json:"style"`
	StyleID             *string `json:"style_id"`
	StyleOverride       bool   `json:"style_override"`
	Personality         string `json:"personality"`
	VoiceHint           string `json:"voice_hint"`
	Emotions            string `json:"emotions"`
	Scenes              string `json:"scenes"`
	Gender              string `json:"gender"`
	AgeGroup            string `json:"age_group"`
	VoiceID             string `json:"voice_id"`
	VoiceName           string `json:"voice_name"`
	ImageURL            string `json:"image_url"`
	ReferenceImagesJSON string `json:"reference_images_json"`
	TaskID              string `json:"task_id"`
	ImageStatus         string `json:"image_status"`
	Shared              bool   `json:"shared"`
	Status              string `json:"status"`
	Source              string `json:"source"`
	VariantsJSON        string `json:"variants_json"`

	Importance           string `json:"importance"`
	Consistency          string `json:"consistency"`
	RoleType             string `json:"role_type"`
	TagsJSON             string `json:"tags_json"`
	PropsJSON            string `json:"props_json"`
	Bio                  string `json:"bio"`
	BioFragmentsJSON     string `json:"bio_fragments_json"`
	ImageGenOverrideJSON  string `json:"image_gen_override_json"`

	Version int `json:"version"`
}

// CharacterSnapshot 角色状态快照 — 记录角色在不同剧情阶段的外貌/心理/关系变化
// 快照仍用 MemData，ID 为 uint
type CharacterSnapshot struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	CharacterID string `json:"character_id"` // 对应 Character.ID
	ProjectID   uint   `json:"project_id"`

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
