package notification

import (
	"context"
	"encoding/json"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Data 通知数据访问层
type Data interface {
	Create(ctx context.Context, userID string, typ, title, body, linkURL string, meta interface{}) (*Notification, error)
	List(ctx context.Context, userID string, limit, offset int32) ([]Notification, error)
	CountUnread(ctx context.Context, userID string) (int64, error)
	MarkAsRead(ctx context.Context, id, userID string) error
	MarkAllAsRead(ctx context.Context, userID string) error
}

// DBData 基于 sqlc 的 PostgreSQL 实现
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData 实例
func NewDBData(q *db.Queries) *DBData {
	return &DBData{q: q}
}

// Notification 通知 DTO
type Notification struct {
	ID        string
	CreatedAt string
	Type      string
	Title     string
	Body      string
	LinkURL   string
	ReadAt    string
}

func toNotification(n db.Notification) Notification {
	return Notification{
		ID:        pkg.UUIDString(n.ID),
		CreatedAt: n.CreatedAt.Time.Format("2006-01-02T15:04:05Z07:00"),
		Type:      n.Type,
		Title:     n.Title,
		Body:      textStr(n.Body),
		LinkURL:   textStr(n.LinkUrl),
		ReadAt:    pgTimeStr(n.ReadAt),
	}
}

func textStr(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

func pgTimeStr(t pgtype.Timestamptz) string {
	if !t.Valid {
		return ""
	}
	return t.Time.Format("2006-01-02T15:04:05Z07:00")
}

// Create 创建通知
func (d *DBData) Create(ctx context.Context, userID string, typ, title, body, linkURL string, meta interface{}) (*Notification, error) {
	uid := pkg.ParseUUID(userID)
	if !uid.Valid {
		return nil, nil // 无效 userID 时静默跳过
	}
	metaJSON := []byte("{}")
	if meta != nil {
		if b, err := json.Marshal(meta); err == nil {
			metaJSON = b
		}
	}
	arg := db.CreateNotificationParams{
		UserID:   uid,
		Type:     typ,
		Title:    title,
		Body:     body,
		LinkUrl:  pgtype.Text{String: linkURL, Valid: linkURL != ""},
		MetaJson: metaJSON,
	}
	n, err := d.q.CreateNotification(ctx, arg)
	if err != nil {
		return nil, err
	}
	out := toNotification(n)
	return &out, nil
}

// List 分页列表
func (d *DBData) List(ctx context.Context, userID string, limit, offset int32) ([]Notification, error) {
	uid := pkg.ParseUUID(userID)
	if !uid.Valid {
		return nil, nil
	}
	if limit <= 0 {
		limit = 50
	}
	arg := db.ListNotificationsByUserParams{UserID: uid, Offset: offset, Limit: limit}
	list, err := d.q.ListNotificationsByUser(ctx, arg)
	if err != nil {
		return nil, err
	}
	out := make([]Notification, len(list))
	for i := range list {
		out[i] = toNotification(list[i])
	}
	return out, nil
}

// CountUnread 未读数量
func (d *DBData) CountUnread(ctx context.Context, userID string) (int64, error) {
	uid := pkg.ParseUUID(userID)
	if !uid.Valid {
		return 0, nil
	}
	return d.q.CountUnreadByUser(ctx, uid)
}

// MarkAsRead 标记单条已读
func (d *DBData) MarkAsRead(ctx context.Context, id, userID string) error {
	uid := pkg.ParseUUID(userID)
	idUUID := pkg.ParseUUID(id)
	if !uid.Valid || !idUUID.Valid {
		return nil
	}
	return d.q.MarkAsRead(ctx, db.MarkAsReadParams{ID: idUUID, UserID: uid})
}

// MarkAllAsRead 全部已读
func (d *DBData) MarkAllAsRead(ctx context.Context, userID string) error {
	uid := pkg.ParseUUID(userID)
	if !uid.Valid {
		return nil
	}
	return d.q.MarkAllAsReadByUser(ctx, uid)
}
