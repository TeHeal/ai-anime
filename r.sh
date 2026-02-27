#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$ROOT_DIR/anime_ai"
UI_DIR="$ROOT_DIR/anime_ui"
LOG_DIR="$ROOT_DIR/.run-logs"

API_PORT="${API_PORT:-3737}"
UI_PORT="${UI_PORT:-8080}"

mkdir -p "$LOG_DIR"

kill_by_port() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    local pids
    pids="$(lsof -ti tcp:"$port" || true)"
    if [[ -n "$pids" ]]; then
      echo "$pids" | xargs -r kill -9 || true
    fi
  fi
}

echo "[1/4] 停止前后端进程..."
pkill -f "go run" || true
pkill -f "flutter run -d web-server" || true
pkill -f "flutter run -d chrome" || true
kill_by_port "$API_PORT"
kill_by_port "$UI_PORT"

echo "[2/4] 启动后端 (port=$API_PORT)..."
(
  cd "$API_DIR"
  APP_APP_PORT="$API_PORT" nohup go run . > "$LOG_DIR/backend.log" 2>&1 &
  echo $! > "$LOG_DIR/backend.pid"
)

echo "[3/4] 等待后端健康检查..."
for i in {1..60}; do
  if curl -s "http://127.0.0.1:${API_PORT}/api/v1/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -s "http://127.0.0.1:${API_PORT}/api/v1/health" >/dev/null 2>&1; then
  echo "后端启动失败，请检查日志: $LOG_DIR/backend.log"
  exit 1
fi

echo "[4/4] 启动前端 (port=$UI_PORT)..."
(
  cd "$UI_DIR"
  nohup flutter run -d chrome --web-port "$UI_PORT" > "$LOG_DIR/frontend.log" 2>&1 &
  echo $! > "$LOG_DIR/frontend.pid"
)

echo "完成。"
echo "- 后端日志: $LOG_DIR/backend.log"
echo "- 前端日志: $LOG_DIR/frontend.log"
