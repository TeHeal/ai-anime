#!/usr/bin/env bash
#
# Ubuntu 新系统开发环境一键安装脚本（用户目录优先）
# 安装：Cursor、Go、Flutter、Fcitx5+中州韵(Rime)，以及 Go/Flutter 开发必要依赖
#
# 用法:
#   bash scripts/setup-ubuntu-dev.sh [选项]
#   bash scripts/setup-ubuntu-dev.sh --skip-cursor --skip-rime   # 跳过可选组件
#
# 选项:
#   --install-dir DIR   安装根目录，默认为 $HOME/App（Go/Flutter/Cursor 在其下）
#   --skip-cursor       不安装 Cursor
#   --skip-go           不安装 Go
#   --skip-flutter      不安装 Flutter
#   --skip-rime         不安装 Fcitx5+Rime
#   --skip-ssh          不安装/不启用 SSH 服务自启动
#   --skip-remote-desktop  不安装/不启用远程桌面(xrdp)自启动
#   --skip-sysdeps      不安装系统依赖（仅装已有脚本需要的包时用）
#   --dry-run           只打印将要执行的步骤，不实际安装
#
# 需要 sudo 的步骤：系统依赖、Fcitx5+Rime。Go/Flutter/Cursor 安装到用户目录无需 root。
#
set -e

# ------------------------- 参数与常量 -------------------------
INSTALL_DIR="${HOME}/App"
DEV_DIR="${HOME}/Dev"
SKIP_CURSOR=false
SKIP_GO=false
SKIP_FLUTTER=false
SKIP_RIME=false
SKIP_SSH=false
SKIP_REMOTE_DESKTOP=false
SKIP_SYSDEPS=false
DRY_RUN=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

for arg in "$@"; do
  case "$arg" in
    --install-dir=*) INSTALL_DIR="${arg#*=}" ;;
    --install-dir) shift; INSTALL_DIR="${1:-$INSTALL_DIR}" ;;
    --skip-cursor)  SKIP_CURSOR=true ;;
    --skip-go)      SKIP_GO=true ;;
    --skip-flutter) SKIP_FLUTTER=true ;;
    --skip-rime)    SKIP_RIME=true ;;
    --skip-ssh)     SKIP_SSH=true ;;
    --skip-remote-desktop) SKIP_REMOTE_DESKTOP=true ;;
    --skip-sysdeps) SKIP_SYSDEPS=true ;;
    --dry-run)      DRY_RUN=true ;;
    -h|--help)
      head -30 "$(dirname "$0")/../docs/环境配置.md" 2>/dev/null || sed -n '1,35p' "$0"
      exit 0
      ;;
  esac
done

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  GO_ARCH=amd64; CURSOR_ARCH=x64 ;;
  aarch64|arm64) GO_ARCH=arm64; CURSOR_ARCH=arm64 ;;
  *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

# 安装路径（用户目录）；展开 ~ 并转为绝对路径，并创建 App/Dev 目录
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"
DEV_DIR="${DEV_DIR:-$HOME/Dev}"
mkdir -p "$INSTALL_DIR" "$DEV_DIR"
INSTALL_DIR="$(cd "$INSTALL_DIR" 2>/dev/null && pwd || echo "$INSTALL_DIR")"
GO_ROOT="${INSTALL_DIR}/go"
FLUTTER_ROOT="${INSTALL_DIR}/flutter"
CURSOR_APPIMAGE="${INSTALL_DIR}/bin/cursor.AppImage"

# ------------------------- 工具函数 -------------------------
run() {
  if "$DRY_RUN"; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

maybe_sudo() {
  if "$DRY_RUN"; then
    echo "[dry-run] sudo $*"
  else
    sudo "$@"
  fi
}

ensure_dir() {
  run mkdir -p "$1"
}

# 在 ~/.profile 中追加 PATH 行（若尚未存在）
add_to_profile() {
  local line="$1"
  local marker="$2"
  if grep -qF "${marker}" "${HOME}/.profile" 2>/dev/null; then
    echo "    (已在 .profile 中存在: ${marker})"
    return
  fi
  if "$DRY_RUN"; then
    echo "[dry-run] 追加到 ~/.profile: $line"
    return
  fi
  echo "" >> "${HOME}/.profile"
  echo "# ${marker}" >> "${HOME}/.profile"
  echo "$line" >> "${HOME}/.profile"
  echo "    已写入 ~/.profile"
}

# ------------------------- 1. 系统依赖 -------------------------
install_sysdeps() {
  echo "==> 安装系统依赖（需要 sudo）..."
  maybe_sudo apt-get update -y
  maybe_sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    build-essential \
    pkg-config
  # 本项目后端可选：PostgreSQL 客户端、Redis 客户端（便于调试）
  if ! "$DRY_RUN"; then
    maybe_sudo apt-get install -y postgresql-client redis-tools 2>/dev/null || true
  else
    echo "[dry-run] 可选: postgresql-client redis-tools"
  fi
  echo "    系统依赖安装完成。"
}

# ------------------------- 2. 用户目录 App / Dev -----------------
ensure_user_dirs() {
  echo "==> 创建用户目录 ${INSTALL_DIR}（软件安装）与 ${DEV_DIR}（代码存放）..."
  ensure_dir "${INSTALL_DIR}"
  ensure_dir "${DEV_DIR}"
  if ! "$DRY_RUN"; then
    echo "    App: ${INSTALL_DIR}"
    echo "    Dev: ${DEV_DIR}"
  fi
  echo "    目录就绪。"
}

# ------------------------- 3. SSH 服务并自启动 --------------------
install_ssh() {
  echo "==> 安装并启用 SSH 服务（开机自启）（需要 sudo）..."
  maybe_sudo apt-get install -y openssh-server
  if ! "$DRY_RUN"; then
    maybe_sudo systemctl enable ssh 2>/dev/null || maybe_sudo systemctl enable openssh-server 2>/dev/null || true
    maybe_sudo systemctl start ssh 2>/dev/null || maybe_sudo systemctl start openssh-server 2>/dev/null || true
  else
    echo "[dry-run] systemctl enable ssh && systemctl start ssh"
  fi
  echo "    SSH 已安装并设为开机自启。"
}

# ------------------------- 4. 远程桌面(xrdp)并自启动 ---------------
install_remote_desktop() {
  echo "==> 安装并启用远程桌面(xrdp)（开机自启）（需要 sudo）..."
  maybe_sudo apt-get install -y xrdp
  if ! "$DRY_RUN"; then
    maybe_sudo systemctl enable xrdp
    maybe_sudo systemctl start xrdp
    maybe_sudo adduser "$USER" ssl-cert 2>/dev/null || true
  else
    echo "[dry-run] systemctl enable xrdp && systemctl start xrdp"
  fi
  echo "    xrdp 已安装并设为开机自启；可从 Windows「远程桌面」连接。"
}

# ------------------------- 5. Go（用户目录）---------------------
install_go() {
  echo "==> 安装 Go 到 ${GO_ROOT} ..."
  ensure_dir "${INSTALL_DIR}"
  local version
  version="$(curl -sL https://go.dev/VERSION?m=text 2>/dev/null | head -1 | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "go1.23.4")"
  # 若只有 go1.23 形式，补全为 go1.23.4 以便下载
  if [[ ! "$version" =~ ^go[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    version="go1.23.4"
  fi
  local tarball="${version}.linux-${GO_ARCH}.tar.gz"
  local url="https://go.dev/dl/${tarball}"
  local tmpdir="${TMPDIR:-/tmp}"
  local tgz="${tmpdir}/${tarball}"

  if [[ -x "${GO_ROOT}/bin/go" ]]; then
    echo "    已存在 ${GO_ROOT}，跳过下载。"
    run "${GO_ROOT}/bin/go" version
    add_to_profile "export PATH=\"\$PATH:${GO_ROOT}/bin\"" "Go (${GO_ROOT}/bin)"
    return
  fi

  echo "    下载 $version ..."
  run curl -sL -o "$tgz" "$url" || run wget -q -O "$tgz" "$url"
  echo "    解压到 ${GO_ROOT} ..."
  run rm -rf "${GO_ROOT}"
  run tar -C "${INSTALL_DIR}" -xzf "$tgz"
  run "${GO_ROOT}/bin/go" version
  add_to_profile "export PATH=\"\$PATH:${GO_ROOT}/bin\"" "Go (${GO_ROOT}/bin)"
  echo "    Go 安装完成。"
}

# ------------------------- 3. Flutter（用户目录）----------------
install_flutter() {
  echo "==> 安装 Flutter 到 ${FLUTTER_ROOT} ..."
  ensure_dir "${INSTALL_DIR}"
  if [[ -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
    echo "    已存在 ${FLUTTER_ROOT}，执行 git pull 更新到最新 stable ..."
    if ! "$DRY_RUN"; then
      (cd "${FLUTTER_ROOT}" && git fetch origin stable && git reset --hard origin/stable 2>/dev/null || true)
    fi
    add_to_profile "export PATH=\"\$PATH:${FLUTTER_ROOT}/bin\"" "Flutter (${FLUTTER_ROOT}/bin)"
    return
  fi
  if "$DRY_RUN"; then
    echo "[dry-run] git clone --depth 1 --branch stable https://github.com/flutter/flutter.git ${FLUTTER_ROOT}"
    add_to_profile "export PATH=\"\$PATH:${FLUTTER_ROOT}/bin\"" "Flutter (${FLUTTER_ROOT}/bin)"
    return
  fi
  run git clone --depth 1 --branch stable "https://github.com/flutter/flutter.git" "${FLUTTER_ROOT}"
  add_to_profile "export PATH=\"\$PATH:${FLUTTER_ROOT}/bin\"" "Flutter (${FLUTTER_ROOT}/bin)"
  echo "    首次运行 flutter 会下载 Dart SDK，请稍后执行: export PATH=\"\$PATH:${FLUTTER_ROOT}/bin\" && flutter doctor"
  echo "    Flutter 安装完成。"
}

# ------------------------- 4. Cursor（用户目录 AppImage）--------
install_cursor() {
  echo "==> 安装 Cursor 到 ${INSTALL_DIR}/bin ..."
  ensure_dir "$(dirname "$CURSOR_APPIMAGE")"
  # 使用官方 API 当前版本（可改为从参数或网页解析）
  local cursor_version="${CURSOR_VERSION:-2.5}"
  local url="https://api2.cursor.sh/updates/download/golden/linux-${CURSOR_ARCH}/cursor/${cursor_version}"

  if [[ -f "$CURSOR_APPIMAGE" ]]; then
    echo "    已存在 $CURSOR_APPIMAGE，跳过下载。"
    add_to_profile "export PATH=\"\$PATH:$(dirname "$CURSOR_APPIMAGE")\"" "Cursor (optional)"
    return
  fi

  echo "    下载 Cursor ${cursor_version} ..."
  run curl -sL -o "$CURSOR_APPIMAGE" "$url" || run wget -q -O "$CURSOR_APPIMAGE" "$url"
  run chmod +x "$CURSOR_APPIMAGE"
  add_to_profile "export PATH=\"\$PATH:$(dirname "$CURSOR_APPIMAGE")\"" "Cursor (optional)"
  echo "    启动方式: cursor.AppImage 或 $(dirname "$CURSOR_APPIMAGE")/cursor.AppImage"
  echo "    Cursor 安装完成。"
}

# ------------------------- 6. Fcitx5 + 中州韵 Rime --------------
install_rime() {
  echo "==> 安装 Fcitx5 + 中州韵(Rime)（需要 sudo）..."
  if [[ -f "$REPO_ROOT/scripts/setup-fcitx5-rime.sh" ]]; then
    if "$DRY_RUN"; then
      echo "[dry-run] bash $REPO_ROOT/scripts/setup-fcitx5-rime.sh"
    else
      bash "$REPO_ROOT/scripts/setup-fcitx5-rime.sh"
    fi
  else
    # 内联最小安装（无本项目 config 时）
    maybe_sudo apt-get update
    maybe_sudo apt-get install -y \
      fcitx5 fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 \
      fcitx5-config-qt fcitx5-rime rime-data-luna-pinyin rime-data-emoji
    if ! "$DRY_RUN"; then
      im-config -n fcitx5 2>/dev/null || true
      mkdir -p ~/.config/environment.d
      printf '%s\n' 'GTK_IM_MODULE=fcitx' 'QT_IM_MODULE=fcitx' 'XMODIFIERS=@im=fcitx' > ~/.config/environment.d/fcitx5.conf
      mkdir -p ~/.local/share/fcitx5/rime
      echo "patch:
  schema_list:
    - schema: luna_pinyin_simp
    - schema: emoji
  menu:
    page_size: 6" > ~/.local/share/fcitx5/rime/default.custom.yaml
    fi
    echo "    请注销/重登后使用 Fcitx5；在 fcitx5-configtool 中添加「中州韵(Rime)」。"
  fi
  echo "    Fcitx5 + Rime 安装完成。"
}

# ------------------------- 主流程 -------------------------
main() {
  echo "=============================================="
  echo "  Ubuntu 开发环境安装 (Go / Flutter / Cursor / Rime / SSH / 远程桌面)"
  echo "  软件安装目录: ${INSTALL_DIR}  代码目录: ${DEV_DIR}"
  echo "=============================================="

  "$SKIP_SYSDEPS" || install_sysdeps
  ensure_user_dirs
  "$SKIP_SSH"    || install_ssh
  "$SKIP_REMOTE_DESKTOP" || install_remote_desktop
  "$SKIP_GO"     || install_go
  "$SKIP_FLUTTER" || install_flutter
  "$SKIP_CURSOR" || install_cursor
  "$SKIP_RIME"   || install_rime

  echo ""
  echo "=== 安装完成 ==="
  echo "1. 软件安装目录: ${INSTALL_DIR}  代码目录: ${DEV_DIR}"
  echo "2. 执行以下命令使 PATH 生效: source ~/.profile"
  echo "3. 验证: go version && flutter doctor"
  echo "4. SSH 与 xrdp 已设为开机自启；Fcitx5/Rime 需【注销并重新登录】后生效。"
  echo "5. 详细说明见: docs/环境配置.md"
}

main
