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
| 5   | 设计系统（颜色、文字、圆角、间距、ScreenUtil） | `docs/设计系统.md`                             |


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
- **编码时**：遵循 Rules；Flutter 新组件必须使用设计令牌（`AppColors`、`RadiusTokens`、`Spacing`、`AppTextStyles`）与 flutter_screenutil 的 `.w`/`.h`/`.sp`/`.r`，详见 `docs/设计系统.md`。
- **完成后**：列出已修改文件与核心变更，提示需运行的命令（如 `go mod tidy`、`dart run build_runner build`）。

## 5. 偏好设置

- **不录制视频**：除非用户明确要求，否则不录制演示视频。
- **README 修改**：AI 助手可应用户要求修改 README；日常开发以阅读参考为主。

## Cursor Cloud specific instructions

### Services overview

| Service | Directory | Stack | Notes |
|---------|-----------|-------|-------|
| Flutter frontend (Web) | `anime_ui/` | Flutter 3.41 / Dart 3.11 | Riverpod + freezed |
| Go backend API | `anime_ai/` | Go 1.26, Gin, sqlc, pgx | Requires PostgreSQL + Redis at runtime |

### Common commands

- **Flutter lint**: `cd anime_ui && flutter analyze`
- **Flutter build (web)**: `cd anime_ui && flutter build web --no-tree-shake-icons`
- **Flutter dev**: `cd anime_ui && flutter run -d chrome` (requires display)
- **Go lint**: `cd anime_ai && go vet ./...` (pre-existing self-assignment warning in `module/episode/data.go:48`)
- **Go build**: `cd anime_ai && go build ./...`
- **Go test**: `cd anime_ai && go test ./...`
- **Go run**: `cd anime_ai && make run` (needs DB/Redis config via env vars)

### Gotchas

- Flutter analyze reports only `info`-level issues (37 as of setup); **0 errors** is the baseline.
- Go `vet` has a pre-existing self-assignment warning (`ep.ProjectIDStr`) — this is not introduced by agent changes.
- Entity IDs (Episode, Scene, etc.) are **UUID strings** (`String?` in Dart, `string`/`uuid.UUID` in Go). Never use `int` for entity IDs in UI code.
- After modifying freezed/json_serializable models run: `cd anime_ui && dart run build_runner build --delete-conflicting-outputs`.
- The Go backend requires environment variables for DB connection (`DATABASE_URL`), Redis, and external AI provider keys to start. Without these, `make run` will fail at startup.

