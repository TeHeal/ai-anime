# 数据库迁移

## 本地开发环境配置

### Redis

```bash
# Ubuntu/Debian 安装
sudo apt-get install redis-server

# 启动（安装后通常已自动启动）
sudo systemctl start redis-server
sudo systemctl enable redis-server  # 开机自启

# 验证
redis-cli ping  # 应返回 PONG
```

### PostgreSQL

```bash
# Ubuntu/Debian 安装
sudo apt-get install postgresql postgresql-contrib

# 创建专用用户和数据库（推荐，避免使用 postgres 超级用户）
sudo -u postgres psql -c "CREATE USER ai_anime WITH PASSWORD 'ai_anime_dev' CREATEDB;"
sudo -u postgres createdb -O ai_anime ai_anime

# 应用 schema（从 anime_ai 目录执行）
cd anime_ai
PGPASSWORD=ai_anime_dev psql -h localhost -U ai_anime -d ai_anime -f sch/schema.sql
```

config.yaml 中配置：

```yaml
db:
  host: localhost
  port: 5432
  user: ai_anime
  password: "ai_anime_dev"  # 或使用 APP_DB_PASSWORD 环境变量
  dbname: ai_anime
```

---

## 应用 Schema

执行 `sch/schema.sql` 创建 PostgreSQL 表结构。

### 方式一：psql 命令行

```bash
# 创建数据库（若不存在）
createdb -U postgres ai_anime

# 应用 schema
psql -U postgres -d ai_anime -f sch/schema.sql
```

### 增量迁移（已有数据库）

若已应用过 schema.sql，可单独执行增量迁移：

```bash
# 领域模型补充表（Notification、ReviewRecord、Schedule、CompositeTask、AssetVersion、ProviderUsage）
psql -U "$DB_USER" -d "$DB_NAME" -f migration/20250228_add_domain_tables.sql
```

### 方式二：apply_schema.sh

```bash
#!/bin/bash
# 从 anime_ai 目录执行
DB_NAME="${DB_NAME:-ai_anime}"
DB_USER="${DB_USER:-postgres}"
psql -U "$DB_USER" -d "$DB_NAME" -f sch/schema.sql
```

保存为 `migration/apply_schema.sh` 并执行：

```bash
chmod +x migration/apply_schema.sh
cd anime_ai
./migration/apply_schema.sh
```

### 环境变量

- `DB_NAME`：数据库名，默认 `ai_anime`
- `DB_USER`：数据库用户，默认 `postgres`

### 配置连接

应用启动时从 `config.yaml` 或环境变量读取 DSN，例如：

```yaml
db:
  host: localhost
  port: 5432
  user: postgres
  password: your_password
  dbname: ai_anime
```

或使用完整 DSN：

```yaml
db:
  dsn: postgres://user:password@localhost:5432/ai_anime?sslmode=disable
```

### 种子数据（可选）

首次部署时，需在 `users` 表中创建管理员账号。可通过 SQL 或应用首次登录时自动创建。

```sql
-- 插入管理员（密码需预先哈希）
INSERT INTO users (username, password_hash, display_name, role)
VALUES ('admin', '<bcrypt_hash>', 'admin', 'admin');
```

密码哈希可使用 Go：`pkg.HashPassword("admin123")`。
