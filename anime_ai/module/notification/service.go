package notification

// Service 通知业务逻辑
type Service struct {
	store Store
}

// NewService 创建通知服务
func NewService(store Store) *Service {
	return &Service{store: store}
}

// Send 发送通知
func (s *Service) Send(userID, projectID, nType, title, content, refType, refID string) (*Notification, error) {
	n := &Notification{
		UserID:    userID,
		ProjectID: projectID,
		Type:      nType,
		Title:     title,
		Content:   content,
		RefType:   refType,
		RefID:     refID,
	}
	return s.store.Create(n)
}

// List 列出用户通知
func (s *Service) List(userID string, limit, offset int) ([]*Notification, error) {
	return s.store.ListByUser(userID, limit, offset)
}

// CountUnread 获取未读数量
func (s *Service) CountUnread(userID string) (int64, error) {
	return s.store.CountUnread(userID)
}

// MarkRead 标记单条已读
func (s *Service) MarkRead(id, userID string) error {
	return s.store.MarkRead(id, userID)
}

// MarkAllRead 标记全部已读
func (s *Service) MarkAllRead(userID string) error {
	return s.store.MarkAllRead(userID)
}
