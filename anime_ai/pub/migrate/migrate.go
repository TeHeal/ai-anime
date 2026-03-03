// Package migrate 提供 golang-migrate 数据库迁移能力
package migrate

import (
	"fmt"
	"path/filepath"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

// Up 执行所有待执行的迁移，dsn 为 PostgreSQL 连接串
func Up(dsn string, migrationsDir string) error {
	if dsn == "" {
		return fmt.Errorf("DSN 为空，跳过迁移")
	}
	absPath, err := filepath.Abs(migrationsDir)
	if err != nil {
		return fmt.Errorf("解析迁移目录失败: %w", err)
	}
	sourceURL := "file://" + absPath
	m, err := migrate.New(sourceURL, dsn)
	if err != nil {
		return fmt.Errorf("初始化 migrate 失败: %w", err)
	}
	defer m.Close()

	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("执行迁移失败: %w", err)
	}
	return nil
}
