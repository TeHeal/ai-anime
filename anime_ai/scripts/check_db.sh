#!/usr/bin/env bash
# 数据库连接检查脚本
# 用法：从 anime_ai 目录执行 ./scripts/check_db.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-yikai}"
DB_NAME="${DB_NAME:-ai_anime}"
DB_PASSWORD="${APP_DB_PASSWORD:-mayikai}"

echo "=== 数据库检查 ==="
echo "连接: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"
echo ""

# 1. 检查 PostgreSQL 是否可达
echo "[1] PostgreSQL 服务..."
if pg_isready -h "$DB_HOST" -p "$DB_PORT" >/dev/null 2>&1; then
  echo "    ✓ PostgreSQL 运行中"
else
  echo "    ✗ PostgreSQL 不可达，请确认已安装并启动: sudo systemctl start postgresql"
  exit 1
fi

# 2. 尝试连接（使用 config 中的密码）
echo "[2] 连接测试..."
export PGPASSWORD="$DB_PASSWORD"
if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" >/dev/null 2>&1; then
  echo "    ✓ 连接成功"
else
  echo "    ✗ 连接失败"
  echo ""
  echo "可能原因："
  echo "  1. 用户 $DB_USER 或数据库 $DB_NAME 不存在"
  echo "  2. 密码错误（config.yaml 中配置为 mayikai）"
  echo ""
  echo "初始化步骤（需 sudo）："
  echo "  sudo -u postgres psql -c \"CREATE USER yikai WITH PASSWORD 'mayikai' CREATEDB;\""
  echo "  sudo -u postgres createdb -O yikai ai_anime"
  echo "  PGPASSWORD=mayikai psql -h localhost -U yikai -d ai_anime -f sch/schema.sql"
  exit 1
fi

# 3. 检查表是否存在
echo "[3] 表结构..."
TABLES=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT count(*) FROM information_schema.tables 
  WHERE table_schema='public' AND table_name='users';
" 2>/dev/null | tr -d ' ')
if [ "$TABLES" = "1" ]; then
  echo "    ✓ users 表已存在"
else
  echo "    ✗ users 表不存在，请执行 schema:"
  echo "      PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sch/schema.sql"
  exit 1
fi

# 4. 检查用户数量
echo "[4] 用户数据..."
USER_COUNT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT count(*) FROM users WHERE deleted_at IS NULL;
" 2>/dev/null | tr -d ' ')
echo "    当前用户数: $USER_COUNT"

if [ "$USER_COUNT" = "0" ]; then
  echo ""
  echo "提示：无用户数据。若使用内存存储，应用会创建引导用户 admin/admin123；"
  echo "若使用 PostgreSQL，需通过 API 注册或手动插入用户。"
fi

echo ""
echo "=== 检查完成 ==="
