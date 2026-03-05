// Package migrate 提供 golang-migrate 数据库迁移能力
package migrate

import (
	"database/sql"
	"fmt"
	"path/filepath"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/jackc/pgx/v5/stdlib"
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

// DownAll 回滚所有已执行的迁移（回到空库状态）
func DownAll(dsn string, migrationsDir string) error {
	if dsn == "" {
		return fmt.Errorf("DSN 为空，跳过回滚")
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

	for {
		if err := m.Steps(-1); err != nil {
			if err == migrate.ErrNoChange || err == migrate.ErrNilVersion {
				break
			}
			return fmt.Errorf("回滚迁移失败: %w", err)
		}
	}
	return nil
}

// Reset 清空 public schema 后重新执行所有迁移，相当于重新生成数据库结构
func Reset(dsn string, migrationsDir string) error {
	if dsn == "" {
		return fmt.Errorf("DSN 为空，跳过重置")
	}
	// 使用 pgx 驱动连接（与项目一致），postgres:// DSN 可直接使用
	db, err := sql.Open("pgx", dsn)
	if err != nil {
		return fmt.Errorf("连接数据库失败: %w", err)
	}
	defer db.Close()

	_, err = db.Exec("DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO public;")
	if err != nil {
		return fmt.Errorf("清空 schema 失败: %w", err)
	}
	return Up(dsn, migrationsDir)
}
