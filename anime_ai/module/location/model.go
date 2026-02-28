package location

import "time"

// Location 场景资产实体
// API 响应使用 camelCase 以兼容前端
type Location struct {
	ID                  string    `json:"id"`
	ProjectID           string    `json:"projectId"`
	CreatedAt           time.Time `json:"createdAt"`
	UpdatedAt           time.Time `json:"updatedAt"`
	Name                string    `json:"name"`
	Time                string    `json:"time"`
	InteriorExterior    string    `json:"interiorExterior"`
	Atmosphere          string    `json:"atmosphere"`
	ColorTone           string    `json:"colorTone"`
	Layout              string    `json:"layout"`
	Style               string    `json:"style"`
	StyleOverride       bool      `json:"styleOverride"`
	StyleNote           string    `json:"styleNote"`
	ImageURL            string    `json:"imageUrl"`
	ReferenceImagesJSON string    `json:"referenceImagesJson"`
	TaskID              string    `json:"taskId"`
	ImageStatus         string    `json:"imageStatus"`
	Status              string    `json:"status"`
	Source              string    `json:"source"`
}
