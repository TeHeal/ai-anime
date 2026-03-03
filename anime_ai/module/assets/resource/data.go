package resource

import "context"

// Data 素材库数据访问接口
type Data interface {
	Create(ctx context.Context, r *Resource) error
	GetByIDAndUser(ctx context.Context, id, userID string) (*Resource, error)
	List(ctx context.Context, userID string, opts ListDataOpts) ([]Resource, int64, error)
	Update(ctx context.Context, r *Resource) error
	SoftDelete(ctx context.Context, id, userID string) error
	CountByLibraryType(ctx context.Context, userID, modality string) (map[string]int64, error)
}

// ListDataOpts 列表查询选项
type ListDataOpts struct {
	Modality    string
	LibraryType string
	TagsOverlap []byte // JSON 数组，如 ["a","b"]，用于 && 重叠筛选
	Offset      int32
	Limit       int32
}
