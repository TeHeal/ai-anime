package resource

import (
	"anime_ai/pub/pkg"
	"context"
	"sync"

	"github.com/google/uuid"
)

// MemData 内存实现（无 DB 时使用）
type MemData struct {
	mu   sync.RWMutex
	byID map[string]*Resource
}

// NewMemData 创建 MemData
func NewMemData() *MemData {
	return &MemData{byID: make(map[string]*Resource)}
}

func (d *MemData) Create(ctx context.Context, r *Resource) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	r.ID = uuid.New().String()
	d.byID[r.ID] = r
	return nil
}

func (d *MemData) GetByIDAndUser(ctx context.Context, id, userID string) (*Resource, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()
	r, ok := d.byID[id]
	if !ok || r.UserID != userID {
		return nil, pkg.ErrNotFound
	}
	cp := *r
	return &cp, nil
}

func (d *MemData) List(ctx context.Context, userID string, opts ListDataOpts) ([]Resource, int64, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()
	var out []Resource
	for _, r := range d.byID {
		if r.UserID != userID {
			continue
		}
		if opts.Modality != "" && r.Modality != opts.Modality {
			continue
		}
		if opts.LibraryType != "" && r.LibraryType != opts.LibraryType {
			continue
		}
		out = append(out, *r)
	}
	total := int64(len(out))
	// 简单分页
	start := int(opts.Offset)
	if start < 0 {
		start = 0
	}
	end := start + int(opts.Limit)
	if opts.Limit <= 0 {
		end = len(out)
	}
	if start >= len(out) {
		return nil, total, nil
	}
	if end > len(out) {
		end = len(out)
	}
	return out[start:end], total, nil
}

func (d *MemData) Update(ctx context.Context, r *Resource) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	old, ok := d.byID[r.ID]
	if !ok || old.UserID != r.UserID {
		return pkg.ErrNotFound
	}
	d.byID[r.ID] = r
	return nil
}

func (d *MemData) SoftDelete(ctx context.Context, id, userID string) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	r, ok := d.byID[id]
	if !ok || r.UserID != userID {
		return pkg.ErrNotFound
	}
	delete(d.byID, id)
	return nil
}

func (d *MemData) CountByLibraryType(ctx context.Context, userID, modality string) (map[string]int64, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()
	out := make(map[string]int64)
	for _, r := range d.byID {
		if r.UserID != userID {
			continue
		}
		if modality != "" && r.Modality != modality {
			continue
		}
		out[r.LibraryType]++
	}
	return out, nil
}
