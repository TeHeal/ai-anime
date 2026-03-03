package prop

import "time"

// Prop 道具资产实体
// API 响应使用 camelCase 以兼容前端
type Prop struct {
	ID                  string    `json:"id"`
	ProjectID           string    `json:"projectId"`
	CreatedAt           time.Time `json:"createdAt"`
	UpdatedAt           time.Time `json:"updatedAt"`
	Name                string    `json:"name"`
	Appearance          string    `json:"appearance"`
	IsKeyProp           bool      `json:"isKeyProp"`
	Style               string    `json:"style"`
	StyleOverride       bool      `json:"styleOverride"`
	ReferenceImagesJSON string    `json:"referenceImagesJson"`
	ImageURL            string    `json:"imageUrl"`
	UsedByJSON          string    `json:"usedByJson"`
	ScenesJSON          string    `json:"scenesJson"`
	Status              string    `json:"status"`
	Source              string    `json:"source"`
}
