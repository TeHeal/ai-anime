package main

import (
	"log"

	"anime_ai/pub/bootstrap"
	"anime_ai/pub/config"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("加载配置失败: %v", err)
	}

	app, err := bootstrap.New(cfg)
	if err != nil {
		log.Fatalf("启动失败: %v", err)
	}

	app.Run()
}
