package prop

// Store 道具资产数据访问接口
type Store interface {
	Create(p *Prop) error
	GetByID(id, projectID string) (*Prop, error)
	ListByProject(projectID string) ([]Prop, error)
	Update(p *Prop) error
	Delete(id, projectID string) error
}
