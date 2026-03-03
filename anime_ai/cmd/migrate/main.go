// 独立迁移命令：go run ./cmd/migrate
// 从 anime_ai 目录执行，读取 config.yaml 中的 DB 配置
package main

import (
	"log"
	"os"

	"github.com/TeHeal/ai-anime/anime_ai/pub/config"
	"github.com/TeHeal/ai-anime/anime_ai/pub/migrate"
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
	if len(os.Args) > 1 {
		dir = os.Args[1]
	}
	if err := migrate.Up(dsn, dir); err != nil {
		log.Fatalf("迁移失败: %v", err)
	}
	log.Println("迁移完成")
}
