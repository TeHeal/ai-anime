# AGENTS

> AI 角色定义：实现前必读 [README.md](README.md)，开发时遵循 [.cursor/rules/](.cursor/rules/)。

## 1. 角色定位

本项目的 AI 助手扮演**全栈开发助手**，负责 Go 后端与 Flutter 前端的代码生成、重构与问题修复。


| 角色           | 职责                                   | 边界                                       |
| ------------ | ------------------------------------ | ---------------------------------------- |
| **全栈开发助手**   | 实现需求、修复 Bug、重构代码；遵循 README 领域模型与目录设计 | 不擅自改依赖版本；不猜第三方 API；不写空 catch             |
| **Agent 模式** | 多文件重构、新功能开发时执行规划→编码→验证流程             | 使用 `@rules/agent-logic.mdc` 时按 Plan 分步执行 |


## 2. 必读文档（按顺序）


| 顺序  | 内容                        | 位置                                            |
| --- | ------------------------- | --------------------------------------------- |
| 1   | 领域模型与状态机                  | README § 三、领域模型                               |
| 2   | 目录设计、Handler→Service→Data | README § 目录设计                                 |
| 3   | 错误处理规范                    | README § 7.4                                  |
| 4   | 开发规范（架构、幻觉、防御性编程）         | `.cursor/rules/ai-development-guidelines.mdc` |


## 3. 规则与适用范围


| 规则文件                            | 适用范围                        | 说明                    |
| ------------------------------- | --------------------------- | --------------------- |
| `ai-development-guidelines.mdc` | 全项目                         | 宪法级：架构、幻觉、安全、性能       |
| `go-backend.mdc`                | `anime_ai/**/*.go`          | Go 分层、错误码、sqlc        |
| `flutter-frontend.mdc`          | `anime_ui/lib/**/*.dart`    | Riverpod、freezed、组件规范 |
| `fullstack-go-flutter.mdc`      | `**/*.{go,dart,proto,json}` | 跨端契约、类型映射             |
| `agent-logic.mdc`               | 按需 `@rules/agent-logic`     | Agent 模式执行流程          |


## 4. 工作方式

- **任务开始前**：读取 README 确认技术栈与目录设计，检查 AGENTS 术语表（见 README）。
- **编码时**：遵循 Rules，不确定的 API 查源码或搜索，不猜测。
- **完成后**：列出已修改文件与核心变更，提示需运行的命令（如 `go mod tidy`、`dart run build_runner build`）。

## 5. 偏好设置

- **不录制视频**：除非用户明确要求，否则不录制演示视频。
- **README 修改**：AI 助手可应用户要求修改 README；日常开发以阅读参考为主。

## Cursor Cloud specific instructions

### 环境

本项目为 monorepo：Go 后端 (`anime_ai/`, :3737) + Flutter Web 前端 (`anime_ui/`, :8080)。

### 工具与 PATH

- **Go** 1.26 → `/usr/local/go/bin`
- **Flutter** 3.41.x（Dart 3.11.0）→ `/opt/flutter/bin`
- **Redis** 7.x（apt 安装）

```
export PATH="/usr/local/go/bin:/opt/flutter/bin:$PATH"
```

### Cloud 启动注意事项

启动顺序和命令见 §3（AGENTS.md 上方），Cloud 环境额外注意：

1. **Redis**：启动后执行 `redis-cli config set stop-writes-on-bgsave-error no`（Cloud VM 磁盘权限导致 RDB 快照失败）
2. **PostgreSQL 可选**：DSN 为空或连接失败时自动 fallback 到内存存储，后端可正常启动
3. **Asynq Worker**：依赖 Redis，可用时自动启动
4. **登录测试**：`POST /api/v1/auth/login`，凭证 `admin`/`admin123`

### 已知问题

- `go vet` 报告 `module/episode/data.go:48` 自赋值警告，属仓库已有问题

