package auth

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/pkg"
	"github.com/TeHeal/ai-anime/anime_ai/sch/db"
	"github.com/jackc/pgx/v5/pgtype"
)

// DBUserStore 基于 sqlc 的 PostgreSQL 实现
type DBUserStore struct {
	q *db.Queries
}

// NewDBUserStore 创建 DBUserStore
func NewDBUserStore(queries *db.Queries) *DBUserStore {
	return &DBUserStore{q: queries}
}

func (s *DBUserStore) FindByUsername(username string) (*User, error) {
	ctx := context.Background()
	row, err := s.q.GetUserByUsername(ctx, username)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return dbUserToUser(&row), nil
}

func (s *DBUserStore) FindByID(id string) (*User, error) {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(id)
	if !idUUID.Valid {
		return nil, pkg.ErrNotFound
	}
	row, err := s.q.GetUserByID(ctx, idUUID)
	if err != nil {
		return nil, pkg.ErrNotFound
	}
	return dbUserToUser(&row), nil
}

func (s *DBUserStore) Update(user *User) error {
	ctx := context.Background()
	idUUID := pkg.StrToUUID(user.IDStr)
	if !idUUID.Valid {
		return pkg.ErrNotFound
	}
	arg := db.UpdateUserParams{
		ID:           idUUID,
		PasswordHash: pgtype.Text{String: user.PasswordHash, Valid: true},
		DisplayName:  pgtype.Text{String: user.DisplayName, Valid: true},
		Role:         pgtype.Text{String: user.Role, Valid: true},
	}
	_, err := s.q.UpdateUser(ctx, arg)
	return err
}

func dbUserToUser(row *db.User) *User {
	u := &User{
		IDStr:        pkg.UUIDToStr(row.ID),
		Username:     row.Username,
		PasswordHash: row.PasswordHash,
		Role:         row.Role,
	}
	if row.DisplayName.Valid {
		u.DisplayName = row.DisplayName.String
	}
	return u
}
