// 独立迁移命令：go run ./cmd/migrate [up|down|reset]
// 从 anime_ai 目录执行，读取 config.yaml 中的 DB 配置
// 无参数或 up：执行迁移；down：回滚所有迁移；reset：回滚后重新执行（重新生成数据库）
package main

import (
	"log"
	"os"

	"anime_ai/pub/config"
	"anime_ai/pub/migrate"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("加载配置失败: %v", err)
	}
	dsn := cfg.DB.GetDSN()
	if dsn == "" {
		log.Fatal("DB DSN 为空，请配置 config.yaml 或环境变量")
	}
	dir := "migrations"
	action := "up"
	if len(os.Args) >= 2 {
		switch os.Args[1] {
		case "down", "reset", "up":
			action = os.Args[1]
		default:
			dir = os.Args[1]
		}
	}

	switch action {
	case "down":
		if err := migrate.DownAll(dsn, dir); err != nil {
			log.Fatalf("回滚失败: %v", err)
		}
		log.Println("回滚完成")
	case "reset":
		if err := migrate.Reset(dsn, dir); err != nil {
			log.Fatalf("重置数据库失败: %v", err)
		}
		log.Println("数据库已重新生成")
	default:
		if err := migrate.Up(dsn, dir); err != nil {
			log.Fatalf("迁移失败: %v", err)
		}
		log.Println("迁移完成")
	}
}
