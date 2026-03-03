#!/usr/bin/env bash
# 重置数据库：删除并重新创建，然后执行迁移
# 用法：./scripts/reset_db.sh（需 sudo 权限）
# 注意：会清空所有数据，请先停止正在连接数据库的应用（如 go run .）

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

DB_USER="yikai"
DB_NAME="ai_anime"
DB_PASSWORD="mayikai"

echo "=== 重置数据库 ==="

# 1. 终止所有到 ai_anime 的连接（否则无法 drop）
echo "[1] 终止现有连接..."
sudo -u postgres psql -d postgres -c "
  SELECT pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();
" 2>/dev/null || true

# 2. 删除数据库
echo "[2] 删除数据库 $DB_NAME..."
sudo -u postgres psql -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"

# 3. 创建数据库
echo "[3] 创建数据库 $DB_NAME..."
sudo -u postgres createdb -O "$DB_USER" "$DB_NAME"

# 4. 执行迁移
echo "[4] 执行数据库迁移..."
export APP_DB_USER="$DB_USER"
export APP_DB_PASSWORD="$DB_PASSWORD"
export APP_DB_HOST="localhost"
export APP_DB_DBNAME="$DB_NAME"
if command -v migrate &>/dev/null; then
  migrate -path ./migrations -database "postgres://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}?sslmode=disable" up
else
  go run ./cmd/migrate
fi

echo ""
echo "=== 重置完成 ==="
echo "可运行 ./scripts/check_db.sh 验证"
