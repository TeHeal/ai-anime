#!/usr/bin/env bash
# Fcitx5 + Rime 安装与启用脚本（Ubuntu/Debian）
# 用法: bash scripts/setup-fcitx5-rime.sh
# 需要 sudo 权限安装包，最后一步会提示注销/重登。

set -e

echo "==> 更新并安装 Fcitx5、Rime 及前端..."
sudo apt-get update
sudo apt-get install -y \
  fcitx5 \
  fcitx5-frontend-gtk3 \
  fcitx5-frontend-gtk4 \
  fcitx5-frontend-qt5 \
  fcitx5-config-qt \
  fcitx5-rime \
  rime-data-luna-pinyin \
  rime-data-emoji

echo "==> 设置 Fcitx5 为默认输入法框架..."
im-config -n fcitx5

echo "==> 写入环境变量到 ~/.config/environment.d/fcitx5.conf（供 GNOME/Wayland 读取）..."
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/fcitx5.conf << 'ENVEOF'
# Fcitx5 输入法框架
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
ENVEOF

echo "==> 创建 Rime 用户配置目录并写入默认配置..."
RIME_DIR="${HOME}/.local/share/fcitx5/rime"
mkdir -p "$RIME_DIR"

if [[ -f "$(dirname "$0")/../config/rime/default.custom.yaml" ]]; then
  cp "$(dirname "$0")/../config/rime/default.custom.yaml" "$RIME_DIR/"
  echo "    已从 config/rime/default.custom.yaml 复制配置。"
else
  cat > "$RIME_DIR/default.custom.yaml" << 'RIMEEOF'
# Rime 默认方案与行为（Fcitx5）- 默认简体
patch:
  schema_list:
    - schema: luna_pinyin_simp   # 朙月拼音·简化字（简体）
    - schema: emoji
  menu:
    page_size: 6
  ascii_composer/switch_key:
    Shift_L: commit_code
    Shift_R: commit_code
RIMEEOF
  echo "    已写入内置 default.custom.yaml。"
fi

echo ""
echo "=== 安装完成 ==="
echo "1. 请【注销并重新登录】（或重启），使 Fcitx5 与环境变量生效。"
echo "2. 登录后若托盘无输入法图标，可运行: fcitx5 -d"
echo "3. 打开配置界面添加 Rime: fcitx5-configtool"
echo "   - 在「输入法」里点 + 添加「中州韵(Rime)」，可删除不需要的键盘。"
echo "4. 默认用 Ctrl+Space 切换中英文；左/右 Shift 可设为提交并切英文（已写在配置里）。"
echo "5. 首次使用 Rime 会花几秒部署，部署完成后即可输入中文。"
