# sch 层：PostgreSQL Schema + sqlc

AI-Anime 的数据访问层，使用 PostgreSQL + sqlc 生成类型安全的 Go 代码。

## 目录结构

```
sch/
├── schema.sql      # 表定义（PostgreSQL）
├── sqlc.yaml       # sqlc 配置
├── queries/        # SQL 查询
│   ├── users.sql
│   ├── projects.sql
│   ├── episodes.sql
│   ├── scenes.sql
│   └── scene_blocks.sql
├── db/             # sqlc 生成的 Go 代码（勿手动编辑）
└── README.md
```

## 单文件行数例外说明

项目规范要求单文件 ≤600 行（README §4、ai-development-guidelines §7）。**sqlc 生成的 `db/*.sql.go` 文件为自动生成代码，不受此限制**。因查询集中、类型定义共享，部分生成文件（如 `shots.sql.go`、`characters.sql.go`）可能超过 600 行，属预期情况，无需拆分。

## 领域模型对应

| 表名 | 领域实体 | 说明 |
|------|----------|------|
| users | User | 用户 |
| organizations | Organization | 组织 |
| org_members | OrgMember | 组织成员 |
| teams | Team | 团队 |
| team_members | TeamMember | 团队成员 |
| projects | Project | 项目 |
| project_members | ProjectMember | 项目成员 |
| episodes | Episode | 集 |
| scenes | Scene | 场 |
| scene_blocks | SceneBlock | 内容块 |

## 安装 sqlc

若未安装 sqlc，可通过以下方式之一安装：

```bash
# 方式 1：go install（推荐）
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# 方式 2：go run（无需安装）
go run github.com/sqlc-dev/sqlc/cmd/sqlc@latest generate
```

安装后确保 `$GOPATH/bin` 或 `$HOME/go/bin` 在 PATH 中。

## 生成代码

在 `sch/` 目录下执行：

```bash
cd anime_ai/sch
sqlc generate
```

或使用 go run（无需安装 sqlc）：

```bash
cd anime_ai/sch
go run github.com/sqlc-dev/sqlc/cmd/sqlc@latest generate
```

## 应用 Schema

使用 psql 或迁移工具执行 `schema.sql`：

```bash
psql -U postgres -d ai_anime -f schema.sql
```

## 依赖

- PostgreSQL 13+（使用 `gen_random_uuid()`）
- Go 1.26+
- `github.com/jackc/pgx/v5`（sqlc 生成代码依赖）
