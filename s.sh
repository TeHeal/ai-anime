#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT_DIR/.run-logs"

API_PORT="${API_PORT:-3737}"
UI_PORT="${UI_PORT:-8080}"

kill_by_port() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    local pids
    pids="$(lsof -ti tcp:"$port" || true)"
    if [[ -n "$pids" ]]; then
      echo "  停止端口 $port 上的进程: $pids"
      echo "$pids" | xargs -r kill -9 || true
    fi
  fi
}

echo "正在停止前后端..."

# 1. 尝试通过 PID 文件停止
if [[ -f "$LOG_DIR/backend.pid" ]]; then
  pid=$(cat "$LOG_DIR/backend.pid")
  if kill -0 "$pid" 2>/dev/null; then
    echo "  停止后端 (pid=$pid)"
    kill -9 "$pid" 2>/dev/null || true
  fi
  rm -f "$LOG_DIR/backend.pid"
fi

if [[ -f "$LOG_DIR/frontend.pid" ]]; then
  pid=$(cat "$LOG_DIR/frontend.pid")
  if kill -0 "$pid" 2>/dev/null; then
    echo "  停止前端 (pid=$pid)"
    kill -9 "$pid" 2>/dev/null || true
  fi
  rm -f "$LOG_DIR/frontend.pid"
fi

# 2. pkill 兜底
pkill -f "go run" 2>/dev/null || true
pkill -f "flutter run -d web-server" 2>/dev/null || true
pkill -f "flutter run -d chrome" 2>/dev/null || true

# 3. 按端口清理
kill_by_port "$API_PORT"
kill_by_port "$UI_PORT"

echo "完成。"
