# golang-migrate 数据库迁移

使用 [golang-migrate](https://github.com/golang-migrate/migrate) 管理 PostgreSQL 迁移。

## 自动迁移

应用启动时会自动执行待执行的迁移，无需手动操作。

## 手动执行

### 方式一：Go 命令（推荐）

```bash
cd anime_ai
go run ./cmd/migrate
```

需在 `config.yaml` 或环境变量中配置 DB 连接。

### 方式二：migrate CLI

```bash
# 安装 CLI
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# 执行迁移（从 anime_ai 目录）
cd anime_ai
migrate -path ./migrations -database "postgres://user:password@localhost:5432/ai_anime?sslmode=disable" up
```

### 常用命令

```bash
# 查看当前版本
migrate -path ./migrations -database $DSN version

# 回滚一步
migrate -path ./migrations -database $DSN down 1

# 已有数据库需从迁移 1 开始：标记版本 1 已应用（不执行），再执行后续迁移
migrate -path ./migrations -database $DSN force 1
migrate -path ./migrations -database $DSN up
```

## 已有数据库（手动应用过 schema.sql）

若数据库已通过 `psql -f sch/schema.sql` 或旧方式初始化，需先标记迁移版本，再执行增量迁移：

```bash
# 标记版本 1（init_schema）已应用，跳过执行
migrate -path ./migrations -database $DSN force 1

# 执行后续迁移（2-11）
migrate -path ./migrations -database $DSN up
```

## 新增迁移

1. 在 `migrations/` 下创建 `{version}_{name}.up.sql` 和 `{version}_{name}.down.sql`
2. 版本号递增，如 `000012_add_xxx.up.sql`
3. 同步更新 `sch/schema.sql`（sqlc 的 schema 来源）

## 目录说明

- `migrations/`：golang-migrate 迁移文件（up/down 对）
- `migration/`：旧版单文件迁移（已弃用，保留作参考）
- `sch/schema.sql`：完整 schema，供 sqlc 使用
