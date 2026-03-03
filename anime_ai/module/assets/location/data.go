package location

// Store 场景资产数据访问接口
type Store interface {
	Create(loc *Location) error
	GetByID(id, projectID string) (*Location, error)
	ListByProject(projectID string) ([]Location, error)
	Update(loc *Location) error
	UpdateImage(id, projectID, imageURL, taskID, imageStatus string) error
	Delete(id, projectID string) error
}
