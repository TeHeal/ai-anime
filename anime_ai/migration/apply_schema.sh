#!/bin/bash
# 应用 PostgreSQL schema
# 从 anime_ai 目录执行：./migration/apply_schema.sh

set -e
DB_NAME="${DB_NAME:-ai_anime}"
DB_USER="${DB_USER:-postgres}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA="${SCRIPT_DIR}/../sch/schema.sql"

if [ ! -f "$SCHEMA" ]; then
  echo "schema.sql 不存在: $SCHEMA"
  exit 1
fi

echo "应用 schema 到 $DB_NAME (用户: $DB_USER)..."
psql -U "$DB_USER" -d "$DB_NAME" -f "$SCHEMA"
echo "完成"
