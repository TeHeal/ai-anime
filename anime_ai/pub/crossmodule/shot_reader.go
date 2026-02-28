package crossmodule

// ShotReader 读取/更新镜头信息，供 shot_image 模块使用
// 由 shot 模块实现并注入
// ID 使用 string（UUID），与 sch/db pgtype.UUID 互转
type ShotReader interface {
	GetShot(shotID string) (projectID string, imageURL string, reviewStatus string, err error)
	UpdateShotImage(shotID string, imageURL string) error
	UpdateShotReview(shotID string, status, comment string) error
	BatchUpdateShotReview(shotIDs []string, status string) error
}
