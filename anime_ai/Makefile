.PHONY: run build test test-integration tidy clean

run:
	go run .

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
