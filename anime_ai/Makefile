.PHONY: run build test test-integration migrate migrate-down migrate-reset tidy clean

run:
	go run .

# 执行数据库迁移（读取 config.yaml）
migrate:
	go run ./cmd/migrate

# 回滚所有迁移
migrate-down:
	go run ./cmd/migrate down

# 重新生成数据库（清空 public schema 后重新执行迁移）
migrate-reset:
	go run ./cmd/migrate reset

build:
	CGO_ENABLED=0 go build -o bin/server .

test:
	go test ./...

# 集成测试：需 PostgreSQL + Redis 已启动，会启动真实服务子进程并调用 API
test-integration:
	go test -tags=integration -v -run Integration -timeout 60s ./...

tidy:
	go mod tidy

clean:
	rm -rf bin/
