#!/usr/bin/env bash
# 初始化 PostgreSQL 数据库
# 用法：./scripts/init_db.sh（需 sudo 权限创建用户和数据库）

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

DB_USER="yikai"
DB_NAME="ai_anime"
DB_PASSWORD="mayikai"

echo "=== 初始化数据库 ==="

# 1. 创建用户（若已存在会报错，可忽略）
echo "[1] 创建用户 $DB_USER..."
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' CREATEDB;" 2>/dev/null || echo "    用户已存在，跳过"

# 2. 创建数据库（若已存在会报错，可忽略）
echo "[2] 创建数据库 $DB_NAME..."
sudo -u postgres createdb -O "$DB_USER" "$DB_NAME" 2>/dev/null || echo "    数据库已存在，跳过"

# 3. 应用 schema
echo "[3] 应用 schema..."
export PGPASSWORD="$DB_PASSWORD"
psql -h localhost -U "$DB_USER" -d "$DB_NAME" -f sch/schema.sql

echo ""
echo "=== 初始化完成 ==="
echo "可运行 ./scripts/check_db.sh 验证"
