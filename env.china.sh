#!/usr/bin/env bash
# 中国国内源配置（Go + Flutter）
# 使用方式：source env.china.sh  或  . ./env.china.sh
# 也可在 r.sh 启动时自动加载（若本文件存在）

# Go 模块代理（七牛云 goproxy.cn）
export GOPROXY=https://goproxy.cn,direct

# Flutter / Dart Pub 镜像（CFUG 官方维护）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# sqlc 等 Go 安装工具（go install 默认到 $HOME/go/bin）
export PATH="${HOME}/go/bin:${PATH}"
