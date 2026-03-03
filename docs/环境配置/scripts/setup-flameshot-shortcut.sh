#!/usr/bin/env bash
# 为 Flameshot 添加 GNOME 自定义快捷键（Ctrl+Shift+A 启动 flameshot gui）
# 用法: bash scripts/setup-flameshot-shortcut.sh
# 无需 sudo，仅修改当前用户 gsettings。
# 适用于 GNOME 桌面（Ubuntu 默认）；若使用 KDE 等，请在系统设置里手动添加。

set -e

BINDING="${1:-<Primary><Shift>A}"
KEY_NAME="Flameshot"
COMMAND="flameshot gui"

if ! command -v flameshot &>/dev/null; then
  echo "未检测到 flameshot，请先安装: sudo apt install flameshot"
  exit 1
fi

# 获取当前自定义快捷键列表
CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || true)
# 找到下一个可用的 customN
BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom"
N=0
while echo "$CURRENT" | grep -q "custom${N}"; do
  N=$((N + 1))
done
KEY_PATH="${BASE}${N}/"

# 若当前为空，列表形式为 @as []，需要构造为 ['path']
if [[ "$CURRENT" == "@as []" || -z "$CURRENT" ]]; then
  NEW_LIST="['$KEY_PATH']"
else
  # 去掉末尾 ]，加上 , 'path']
  NEW_LIST="${CURRENT%\]}, '$KEY_PATH']"
fi

echo "==> 添加自定义快捷键: $KEY_NAME -> $COMMAND (绑定: Ctrl+Shift+A)"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" name "$KEY_NAME"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" command "$COMMAND"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH" binding "$BINDING"

echo "==> 已设置完成。按 Ctrl+Shift+A 可启动 Flameshot 区域截图。"
