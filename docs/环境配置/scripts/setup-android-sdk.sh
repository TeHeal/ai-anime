#!/usr/bin/env bash
# 为 Flutter 安装 Android SDK（仅命令行工具，无需 Android Studio）
# 用法: bash scripts/setup-android-sdk.sh
# 需要 sudo 权限安装 openjdk；若已安装 Java，可: SKIP_APT=1 bash scripts/setup-android-sdk.sh

set -e

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
TMP_ZIP="${TMPDIR:-/tmp}/cmdline-tools.zip"

if [[ "${SKIP_APT}" != "1" ]]; then
  echo "==> 安装 OpenJDK 最新版本（default-jdk，Android 构建所需）..."
  sudo apt-get update -qq
  sudo apt-get install -y default-jdk
else
  echo "==> 跳过 apt 安装（SKIP_APT=1），假定已安装 Java。"
  if ! command -v java &>/dev/null; then
    echo "错误: 未找到 java，请先安装: sudo apt-get install -y default-jdk" >&2
    exit 1
  fi
fi

echo "==> 创建 Android SDK 目录: $ANDROID_SDK_ROOT"
mkdir -p "$ANDROID_SDK_ROOT"
cd "$ANDROID_SDK_ROOT"

if [[ -d "cmdline-tools/latest" ]]; then
  echo "    已存在 cmdline-tools/latest，跳过下载。"
else
  echo "==> 下载 Android 命令行工具..."
  curl -L -o "$TMP_ZIP" "$CMDLINE_TOOLS_URL"
  echo "==> 解压并整理目录结构..."
  unzip -q -o "$TMP_ZIP"
  rm -f "$TMP_ZIP"
  # 解压后可能是当前目录下的 bin/lib/source.properties，或在一个子目录中
  if [[ -d "cmdline-tools" && -f "cmdline-tools/bin/sdkmanager" ]]; then
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/bin cmdline-tools/lib cmdline-tools/source.properties cmdline-tools/latest/ 2>/dev/null || true
    mv cmdline-tools/NOTICE.txt cmdline-tools/latest/ 2>/dev/null || true
  elif [[ -f "bin/sdkmanager" ]]; then
    mkdir -p cmdline-tools/latest
    mv bin lib source.properties cmdline-tools/latest/ 2>/dev/null || true
    mv NOTICE.txt cmdline-tools/latest/ 2>/dev/null || true
  else
    # 可能解压到 commandlinetools-xxx 目录
    SUB=$(find . -maxdepth 1 -type d -name 'cmdline-tools' -o -type d -name 'commandlinetools-*' 2>/dev/null | head -1)
    if [[ -n "$SUB" ]]; then
      mkdir -p cmdline-tools/latest
      mv "$SUB"/* cmdline-tools/latest/ 2>/dev/null || true
      rm -rf "$SUB"
    else
      echo "错误: 解压后未找到 bin/sdkmanager，请检查 zip 结构。" >&2
      exit 1
    fi
  fi
fi

export ANDROID_SDK_ROOT
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

echo "==> 接受 SDK 许可..."
yes | sdkmanager --licenses || true

echo "==> 解析最新 build-tools 与 platform 版本..."
# 只从「Available packages」段解析，避免选到已安装/过旧/不可用项；platform 按 API 级别数字排序取最大
LIST=$(sdkmanager --list 2>/dev/null)
AVAILABLE=$(echo "$LIST" | sed -n '/[Aa]vailable [Pp]ackages:/,/Installed [Pp]ackages/p' | head -n -1 | sed '1,3d')
BUILD_TOOLS=$(echo "$AVAILABLE" | grep -oE 'build-tools;[0-9]+\.[0-9]+\.[0-9]+' | grep -v obsolete | sort -V -t';' -k2 | tail -1)
# platforms;android-N：按 N 数字排序取最新（-t'-' 时 N 在第 2 段）
PLATFORM=$(echo "$AVAILABLE" | grep -oE 'platforms;android-[0-9]+' | grep -v obsolete | sort -t'-' -k2 -n | tail -1)
if [[ -z "$BUILD_TOOLS" ]]; then BUILD_TOOLS="build-tools;34.0.0"; fi
if [[ -z "$PLATFORM" ]]; then PLATFORM="platforms;android-34"; fi
echo "    将安装: platform-tools, $BUILD_TOOLS, $PLATFORM"

echo "==> 安装 platform-tools、build-tools 与 Android 平台（均为当前最新）..."
sdkmanager --install "platform-tools"
if ! sdkmanager --install "$BUILD_TOOLS" 2>/dev/null; then
  echo "    $BUILD_TOOLS 不可用，尝试 build-tools;35.0.0、34.0.0..."
  sdkmanager --install "build-tools;35.0.0" 2>/dev/null || sdkmanager --install "build-tools;34.0.0"
fi
if ! sdkmanager --install "$PLATFORM" 2>/dev/null; then
  echo "    $PLATFORM 不可用，尝试 platforms;android-35、android-34..."
  sdkmanager --install "platforms;android-35" 2>/dev/null || sdkmanager --install "platforms;android-34"
fi

echo "==> 配置 Flutter 使用此 Android SDK..."
if command -v flutter &>/dev/null; then
  flutter config --android-sdk "$ANDROID_SDK_ROOT"
else
  echo "    未找到 flutter 命令（当前 PATH 中无 flutter），已跳过 config。"
  echo "    环境变量已写入 ~/.profile，新终端中若已配置 Flutter，将自动使用此 SDK。"
  echo "    若需手动绑定，请执行: flutter config --android-sdk $ANDROID_SDK_ROOT"
fi

echo "==> 写入环境变量到 ~/.profile（若尚未存在）..."
PROFILE="$HOME/.profile"
if ! grep -q 'ANDROID_SDK_ROOT' "$PROFILE" 2>/dev/null; then
  echo '' >> "$PROFILE"
  echo '# Android SDK for Flutter' >> "$PROFILE"
  echo "export ANDROID_SDK_ROOT=\"$ANDROID_SDK_ROOT\"" >> "$PROFILE"
  echo 'export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' >> "$PROFILE"
  echo "    已追加到 $PROFILE，新终端将自动生效。"
else
  echo "    $PROFILE 中已有 ANDROID_SDK_ROOT，未重复写入。"
fi

echo ""
echo "==> 完成。请在本终端执行: source $PROFILE && flutter doctor"
echo "    或新开终端运行: flutter doctor"
