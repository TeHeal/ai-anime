package bootstrap

import (
	"context"
	"log"

	"anime_ai/pub/migrate"
	"github.com/jackc/pgx/v5/pgxpool"
)

// initPGXPool 创建 pgxpool，连接失败时返回 error
func initPGXPool(dsn string) (*pgxpool.Pool, error) {
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return nil, err
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, err
	}
	return pool, nil
}

// runMigrations 执行数据库迁移
func runMigrations(dsn, migrationsPath string) {
	if err := migrate.Up(dsn, migrationsPath); err != nil {
		log.Printf("数据库迁移失败（继续启动）: %v", err)
	} else {
		log.Println("数据库迁移已执行")
	}
}
