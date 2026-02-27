#!/usr/bin/env bash
# ============================================================
# AI 漫剧工厂 — Debian 12.6 部署包构建脚本
# 在项目根目录执行: ./build_deploy.sh
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$SCRIPT_DIR/anime_ai"
UI_DIR="$SCRIPT_DIR/anime_ui"
OUT_DIR="$SCRIPT_DIR/deploy"
DIST_NAME="anime-deploy"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

echo "╔══════════════════════════════════════════╗"
echo "║     AI 漫剧工厂 — 构建 Debian 部署包     ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 检测目标架构（Debian 12.6 一般为 amd64）
ARCH="${ARCH:-$(uname -m)}"
if [[ "$ARCH" == "x86_64" ]]; then
  ARCH="amd64"
fi
echo "目标架构: linux/$ARCH"

# 创建输出目录
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/backend" "$OUT_DIR/frontend"

# ── 1. 构建 Go 后端 ─────────────────────────────────────────
echo "[1/3] 构建后端 (linux/$ARCH)..."
cd "$API_DIR"

if [[ "${DOCKER_BUILD:-0}" == "1" ]]; then
  echo "  使用 Docker 构建（Debian 兼容）..."
  docker run --rm -v "$API_DIR:/src" -v "$OUT_DIR:/out" -w /src -e CGO_ENABLED=1 -e GOOS=linux -e GOARCH=$ARCH \
    golang:1.22-bookworm sh -c "apt-get update -qq && apt-get install -y -qq gcc libc6-dev >/dev/null && go build -o /out/backend/server ."
else
  if ! command -v go &>/dev/null; then
    echo "错误: 未找到 go 命令。可设置 DOCKER_BUILD=1 使用 Docker 构建"
    exit 1
  fi
  CGO_ENABLED=1 GOOS=linux GOARCH=$ARCH go build -o "$OUT_DIR/backend/server" .
fi
echo "  ✓ 后端构建完成"

# ── 2. 构建 Flutter 前端 ─────────────────────────────────────
echo "[2/3] 构建前端 (Web)..."
cd "$UI_DIR"
if ! command -v flutter &>/dev/null; then
  echo "错误: 未找到 flutter 命令，请安装 Flutter SDK"
  exit 1
fi

# 生产环境使用相对路径，由 Nginx 反代 /api/ 到后端
flutter pub get
flutter build web \
  --release \
  --dart-define=API_BASE_URL=/api/v1 \
  --dart-define=SERVER_ORIGIN=

# 复制构建产物
cp -r "$UI_DIR/build/web" "$OUT_DIR/frontend/"
echo "  ✓ 前端构建完成"

# ── 3. 组装部署目录 ────────────────────────────────────────
echo "[3/3] 组装部署包..."
cd "$SCRIPT_DIR"

# 后端配置与数据目录
cp "$API_DIR/config.yaml.example" "$OUT_DIR/backend/config.yaml.example"
cp "$API_DIR/feature_flags.yaml" "$OUT_DIR/backend/"
cp "$API_DIR/route_policy.yaml" "$OUT_DIR/backend/"

# 若无 config.yaml 则从 example 复制（首次部署）
if [[ ! -f "$OUT_DIR/backend/config.yaml" ]]; then
  cp "$OUT_DIR/backend/config.yaml.example" "$OUT_DIR/backend/config.yaml"
  echo "  ⚠ 已生成 config.yaml，部署前请修改其中的 secret 和 API 密钥"
fi

mkdir -p "$OUT_DIR/backend/data/uploads"
chmod +x "$OUT_DIR/backend/server"

# 复制安装脚本和 README
cp "$SCRIPT_DIR/deploy_packages/install.sh" "$OUT_DIR/"
cp "$SCRIPT_DIR/deploy_packages/README.md" "$OUT_DIR/"

echo "  ✓ 部署目录已就绪"
echo ""

# ── 4. 打包 ────────────────────────────────────────────────
echo "打包..."
TARBALL="$SCRIPT_DIR/${DIST_NAME}-${TIMESTAMP}.tar.gz"
cd "$OUT_DIR"
tar czf "$TARBALL" --transform 's,^,deploy/,' .
cd "$SCRIPT_DIR"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║              构建完成！                  ║"
echo "╠══════════════════════════════════════════╣"
echo "║  部署包: $TARBALL"
echo "║                                          ║"
echo "║  在 Debian 12.6 上部署:                  ║"
echo "║    1. scp *.tar.gz user@server:/tmp     ║"
echo "║    2. tar xzf anime-deploy-*.tar.gz      ║"
echo "║    3. cd deploy && sudo bash install.sh ║"
echo "║    4. 编辑 /opt/anime/backend/config.yaml║"
echo "║    5. systemctl start redis-server      ║"
echo "║    6. systemctl start anime-api         ║"
echo "║    7. systemctl restart nginx           ║"
echo "╚══════════════════════════════════════════╝"
