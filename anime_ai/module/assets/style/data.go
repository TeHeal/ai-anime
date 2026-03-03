package style

// Data 风格数据访问接口
type Data interface {
	ListByProject(projectID string) ([]*Style, error)
	GetByID(id, projectID string) (*Style, error)
	Create(s *Style) error
	Update(s *Style) error
	Delete(id, projectID string) error
	ClearProjectDefault(projectID string) error
	SetProjectDefault(id, projectID string) error
	// ApplyAll 批量应用风格到角色/场景/道具，返回更新数量
	ApplyAll(styleID, projectID, styleName string) (int, error)
}
