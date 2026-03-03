# 数据库迁移

> **已迁移至 golang-migrate**：请使用 `migrations/` 目录，详见 [migrations/README.md](../migrations/README.md)。应用启动时会自动执行迁移。

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
sudo -u postgres psql -c "CREATE USER yikai WITH PASSWORD 'mayikai' CREATEDB;"
sudo -u postgres createdb -O yikai ai_anime

# 初始化数据库（从 anime_ai 目录执行）
cd anime_ai
./scripts/init_db.sh
# 或手动：go run ./cmd/migrate
```

config.yaml 中配置：

```yaml
db:
  host: localhost
  port: 5432
  user: yikai
  password: "mayikai"  # 或使用 APP_DB_PASSWORD 环境变量
  dbname: ai_anime
```

---

## 应用 Schema（golang-migrate）

应用启动时自动执行迁移。手动执行见 [migrations/README.md](../migrations/README.md)。

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
