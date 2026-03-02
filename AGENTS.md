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

| Service | Directory | Port | Stack |
|---------|-----------|------|-------|
| Go backend API | `anime_ai/` | 3737 | Go 1.26, Gin, sqlc, pgx |
| Flutter frontend (Web) | `anime_ui/` | 8080 | Flutter 3.41 / Dart 3.11, Riverpod + freezed |
| PostgreSQL | — | 5432 | DB: `ai_anime`, User: `ai_anime` / `ai_anime_dev` |
| Redis | — | 6379 | Asynq 异步任务队列 |

### Starting services

```bash
# 1. Start PostgreSQL and Redis (must be running before backend)
sudo service postgresql start
redis-server --daemonize yes

# 2. Start backend (reads config from anime_ai/config.yaml)
cd anime_ai && go run .

# 3. Start frontend (connect to backend API)
cd anime_ui && flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3737/api/v1
```

Default admin login: `admin` / `admin123`.

### Common commands

See README § 开发与部署（启动命令）and `anime_ai/Makefile` for full list. Key commands:

- **Go**: `go build ./...`, `go test ./...`, `go vet ./...`
- **Flutter**: `flutter analyze`, `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`

### Gotchas

- The Go backend has **graceful degradation**: without PostgreSQL it falls back to in-memory stores, without Redis async workers are disabled. For full-feature testing, both must be running.
- Backend config is in `anime_ai/config.yaml` (gitignored). A template is at `config.yaml.example`. Environment variable overrides use `APP_*` prefix (e.g., `APP_DB_PASSWORD`).
- Entity IDs (Episode, Scene, etc.) are **UUID strings** (`String?` in Dart, `string`/`uuid.UUID` in Go). Never use `int` for entity IDs in UI code.
- `go vet` has a pre-existing self-assignment warning in `module/episode/data.go:48` — not a new issue.
- **Flutter `initState` rule**: Never call `MediaQuery.of(context)`, `Theme.of(context)`, `Breakpoints.isNarrowContext(context)`, or any `InheritedWidget` accessor inside `initState()` or field initializers. Use `didChangeDependencies()` or `build()` instead.
- After modifying freezed/json_serializable models: `cd anime_ui && dart run build_runner build --delete-conflicting-outputs`.
- sqlc queries use `COALESCE(..., '{}'::jsonb)` for JSONB defaults. Always include `::jsonb` cast when adding new COALESCE defaults for JSONB columns.
- Database schema: `anime_ai/sch/schema.sql` (full) + `anime_ai/migration/` (incremental). Apply schema first, then migrations in date order.

### LLM integration

- **LLMService** (`pub/provider/llm/service.go`): unified entry point for all LLM calls. Auto-routes to first available provider by priority: DeepSeek → Kimi → Doubao. Supports `Chat` (sync), `ChatStream` (SSE), and `ChatWithJSON` (sync, JSON response format).
- **Script AI Assist** (`module/script/service.go` → `StreamAssist`): calls LLM via streaming SSE for expand/refine/continueWrite actions. Requires `llm.deepseek_key` (or another key) in config to function; returns clear "LLM 未配置" error otherwise.
- **Storyboard GenerateSync** (`module/storyboard/service.go`): reads episode scenes/blocks via `crossmodule.SceneBlockReader`, sends prompt to LLM, parses structured JSON shot list. Also handles markdown code block cleanup.
- **Prompt templates** in `pub/provider/llm/prompts.go`: `GetScriptAssistSystemPrompt()`, `BuildScriptAssistUserPrompt()`, `GetStoryboardSystemPrompt()`, `BuildStoryboardUserPrompt()`.
- LLM providers use `pub/provider/llm/openai_compat.go` (raw HTTP SSE) — NOT the `pub/adapters/openai/chat.go` (openai-go SDK). Both exist for different use cases (provider layer vs. capability/mesh layer).

### Video generation (Seedance)

- **SeedanceProvider** (`pub/provider/video/seedance.go`): complete implementation of Volcengine Ark Content Generation API. Supports all generation modes: text-to-video, first-frame I2V, first+last-frame I2V, reference-images I2V (1~4 images), and draft-to-final.
- **VideoRequest** (`pub/capability/video.go`): expanded with `Mode`, `ContentItems`, video spec fields (resolution/ratio/duration/frames/seed/camera_fixed/watermark), audio generation, draft mode, offline inference (`service_tier: flex`), return-last-frame (for continuous video generation), and webhook callback.
- **Frontend config** (`module/shots/page/provider.dart`): `CompositeConfig` includes `videoGenMode`, `videoResolution`, `videoRatio`, `videoDuration`, `videoSeed`, `generateAudio`, `draftMode`, `serviceTier`, `continuousMode` and other Seedance-specific parameters.
- Model alias resolution: short names like `seedance-1.5-pro` auto-resolve to full Ark model IDs like `doubao-seedance-1-5-pro-251215`.

