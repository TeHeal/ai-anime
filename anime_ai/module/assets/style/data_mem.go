package style

import (
	"sync"

	"anime_ai/pub/pkg"
	"github.com/google/uuid"
)

// MemData 内存实现（无 DB 时使用）
type MemData struct {
	mu     sync.RWMutex
	styles map[string]*Style
}

// NewMemData 创建 MemData
func NewMemData() *MemData {
	return &MemData{styles: make(map[string]*Style)}
}

func (d *MemData) ListByProject(projectID string) ([]*Style, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()
	var out []*Style
	for _, s := range d.styles {
		if s.ProjectID == projectID {
			out = append(out, s)
		}
	}
	return out, nil
}

func (d *MemData) GetByID(id, projectID string) (*Style, error) {
	d.mu.RLock()
	defer d.mu.RUnlock()
	s, ok := d.styles[id]
	if !ok || s.ProjectID != projectID {
		return nil, pkg.ErrNotFound
	}
	return s, nil
}

func (d *MemData) Create(s *Style) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	if s.ID == "" {
		s.ID = uuid.New().String()
	}
	d.styles[s.ID] = s
	return nil
}

func (d *MemData) Update(s *Style) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	if _, ok := d.styles[s.ID]; !ok {
		return pkg.ErrNotFound
	}
	d.styles[s.ID] = s
	return nil
}

func (d *MemData) Delete(id, projectID string) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	s, ok := d.styles[id]
	if !ok || s.ProjectID != projectID {
		return pkg.ErrNotFound
	}
	delete(d.styles, id)
	return nil
}

func (d *MemData) ClearProjectDefault(projectID string) error {
	d.mu.Lock()
	defer d.mu.Unlock()
	for _, s := range d.styles {
		if s.ProjectID == projectID {
			s.IsProjectDefault = false
		}
	}
	return nil
}

func (d *MemData) SetProjectDefault(id, projectID string) error {
	_ = d.ClearProjectDefault(projectID)
	d.mu.Lock()
	defer d.mu.Unlock()
	if s, ok := d.styles[id]; ok && s.ProjectID == projectID {
		s.IsProjectDefault = true
	}
	return nil
}

func (d *MemData) ApplyAll(styleID, projectID, styleName string) (int, error) {
	return 0, nil
}
