package organization

import (
	"context"
	"fmt"

	"anime_ai/pub/pkg"
	"anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// Data 组织数据访问层接口
type Data interface {
	CreateOrg(ctx context.Context, name, avatarURL, plan, ownerID string) (*Org, error)
	GetOrgByID(ctx context.Context, id string) (*Org, error)
	ListOrgsByUser(ctx context.Context, userID string) ([]Org, error)
	UpdateOrg(ctx context.Context, id string, name, avatarURL, plan *string) (*Org, error)
	AddMember(ctx context.Context, orgID, userID, role string) (*OrgMember, error)
	ListMembers(ctx context.Context, orgID string) ([]OrgMember, error)
	RemoveMember(ctx context.Context, orgID, userID string) error
	GetMember(ctx context.Context, orgID, userID string) (*OrgMember, error)
}

// Org 组织 DTO
type Org struct {
	ID        string `json:"id"`
	CreatedAt string `json:"createdAt"`
	UpdatedAt string `json:"updatedAt"`
	Name      string `json:"name"`
	AvatarURL string `json:"avatarUrl"`
	Plan      string `json:"plan"`
	OwnerID   string `json:"ownerId"`
}

// OrgMember 组织成员 DTO
type OrgMember struct {
	ID          string `json:"id"`
	CreatedAt   string `json:"createdAt"`
	OrgID       string `json:"orgId"`
	UserID      string `json:"userId"`
	Role        string `json:"role"`
	JoinedAt    string `json:"joinedAt"`
	Username    string `json:"username"`
	DisplayName string `json:"displayName"`
}

// DBData 基于 sqlc 的 PostgreSQL 实现
type DBData struct {
	q *db.Queries
}

// NewDBData 创建 DBData 实例
func NewDBData(q *db.Queries) *DBData {
	return &DBData{q: q}
}

func toOrg(o db.Organization) *Org {
	return &Org{
		ID:        pkg.UUIDString(o.ID),
		CreatedAt: o.CreatedAt.Time.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt: o.UpdatedAt.Time.Format("2006-01-02T15:04:05Z07:00"),
		Name:      o.Name,
		AvatarURL: textStr(o.AvatarUrl),
		Plan:      textStr(o.Plan),
		OwnerID:   pkg.UUIDString(o.OwnerID),
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

// CreateOrg 创建组织
func (d *DBData) CreateOrg(ctx context.Context, name, avatarURL, plan, ownerID string) (*Org, error) {
	uid := pkg.ParseUUID(ownerID)
	if !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的用户 ID", pkg.ErrBadRequest)
	}
	o, err := d.q.CreateOrganization(ctx, db.CreateOrganizationParams{
		Name:      name,
		AvatarUrl: nilIfEmpty(avatarURL),
		Plan:      nilIfEmpty(plan),
		OwnerID:   uid,
	})
	if err != nil {
		return nil, fmt.Errorf("创建组织失败: %w", err)
	}
	return toOrg(o), nil
}

// GetOrgByID 根据 ID 获取组织
func (d *DBData) GetOrgByID(ctx context.Context, id string) (*Org, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的组织 ID", pkg.ErrBadRequest)
	}
	o, err := d.q.GetOrgByID(ctx, uid)
	if err != nil {
		return nil, fmt.Errorf("%w: 组织不存在", pkg.ErrNotFound)
	}
	return toOrg(o), nil
}

// ListOrgsByUser 获取用户所属组织列表
func (d *DBData) ListOrgsByUser(ctx context.Context, userID string) ([]Org, error) {
	uid := pkg.ParseUUID(userID)
	if !uid.Valid {
		return nil, nil
	}
	rows, err := d.q.ListOrgsByUser(ctx, uid)
	if err != nil {
		return nil, fmt.Errorf("查询用户组织列表失败: %w", err)
	}
	out := make([]Org, len(rows))
	for i, r := range rows {
		out[i] = *toOrg(r)
	}
	return out, nil
}

// UpdateOrg 更新组织信息
func (d *DBData) UpdateOrg(ctx context.Context, id string, name, avatarURL, plan *string) (*Org, error) {
	uid := pkg.ParseUUID(id)
	if !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的组织 ID", pkg.ErrBadRequest)
	}
	params := db.UpdateOrganizationParams{ID: uid}
	if name != nil {
		params.Name = pgtype.Text{String: *name, Valid: true}
	}
	if avatarURL != nil {
		params.AvatarUrl = pgtype.Text{String: *avatarURL, Valid: true}
	}
	if plan != nil {
		params.Plan = pgtype.Text{String: *plan, Valid: true}
	}
	o, err := d.q.UpdateOrganization(ctx, params)
	if err != nil {
		return nil, fmt.Errorf("%w: 组织不存在或更新失败", pkg.ErrNotFound)
	}
	return toOrg(o), nil
}

// AddMember 添加组织成员
func (d *DBData) AddMember(ctx context.Context, orgID, userID, role string) (*OrgMember, error) {
	oid := pkg.ParseUUID(orgID)
	uid := pkg.ParseUUID(userID)
	if !oid.Valid || !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的 ID", pkg.ErrBadRequest)
	}
	m, err := d.q.AddOrgMember(ctx, db.AddOrgMemberParams{
		OrgID:  oid,
		UserID: uid,
		Role:   nilIfEmpty(role),
	})
	if err != nil {
		return nil, fmt.Errorf("添加成员失败: %w", err)
	}
	return &OrgMember{
		ID:        pkg.UUIDString(m.ID),
		CreatedAt: m.CreatedAt.Time.Format("2006-01-02T15:04:05Z07:00"),
		OrgID:     pkg.UUIDString(m.OrgID),
		UserID:    pkg.UUIDString(m.UserID),
		Role:      m.Role,
		JoinedAt:  pgTimeStr(m.JoinedAt),
	}, nil
}

// ListMembers 列出组织成员
func (d *DBData) ListMembers(ctx context.Context, orgID string) ([]OrgMember, error) {
	oid := pkg.ParseUUID(orgID)
	if !oid.Valid {
		return nil, fmt.Errorf("%w: 无效的组织 ID", pkg.ErrBadRequest)
	}
	rows, err := d.q.ListOrgMembers(ctx, oid)
	if err != nil {
		return nil, fmt.Errorf("查询成员列表失败: %w", err)
	}
	out := make([]OrgMember, len(rows))
	for i, r := range rows {
		out[i] = OrgMember{
			ID:          pkg.UUIDString(r.ID),
			CreatedAt:   r.CreatedAt.Time.Format("2006-01-02T15:04:05Z07:00"),
			OrgID:       pkg.UUIDString(r.OrgID),
			UserID:      pkg.UUIDString(r.UserID),
			Role:        r.Role,
			JoinedAt:    pgTimeStr(r.JoinedAt),
			Username:    r.Username,
			DisplayName: textStr(r.DisplayName),
		}
	}
	return out, nil
}

// RemoveMember 移除组织成员
func (d *DBData) RemoveMember(ctx context.Context, orgID, userID string) error {
	oid := pkg.ParseUUID(orgID)
	uid := pkg.ParseUUID(userID)
	if !oid.Valid || !uid.Valid {
		return fmt.Errorf("%w: 无效的 ID", pkg.ErrBadRequest)
	}
	return d.q.RemoveOrgMember(ctx, db.RemoveOrgMemberParams{
		OrgID:  oid,
		UserID: uid,
	})
}

// GetMember 查询单个组织成员
func (d *DBData) GetMember(ctx context.Context, orgID, userID string) (*OrgMember, error) {
	oid := pkg.ParseUUID(orgID)
	uid := pkg.ParseUUID(userID)
	if !oid.Valid || !uid.Valid {
		return nil, fmt.Errorf("%w: 无效的 ID", pkg.ErrBadRequest)
	}
	m, err := d.q.GetOrgMember(ctx, db.GetOrgMemberParams{
		OrgID:  oid,
		UserID: uid,
	})
	if err != nil {
		return nil, fmt.Errorf("%w: 成员不存在", pkg.ErrNotFound)
	}
	return &OrgMember{
		ID:       pkg.UUIDString(m.ID),
		OrgID:    pkg.UUIDString(m.OrgID),
		UserID:   pkg.UUIDString(m.UserID),
		Role:     m.Role,
		JoinedAt: pgTimeStr(m.JoinedAt),
	}, nil
}

// nilIfEmpty 空字符串返回 nil（用于 sqlc narg 参数）
func nilIfEmpty(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}
