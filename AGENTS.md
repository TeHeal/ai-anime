# AGENTS
/home/yikai/Dev/ai-anime 是新版本目录， /home/yikai/Dev/anime是旧版本目录！ sudo 密码： yikai
> AI 助手必读：实现前先读 [README.md](README.md) 领域模型→目录设计→错误处理；开发时遵循 [.cursor/rules/ai-development-guidelines.mdc](.cursor/rules/ai-development-guidelines.mdc)。

## 1. 术语表（实现前必知）

| 术语 | 含义 |
|------|------|
| 剧本 | 集-场-块结构的故事文本 |
| 资产 | 角色、场景、道具、风格等资源 |
| 脚本 | 结构化镜头指令列表（Shot Script） |
| 镜图 | 每个镜头的关键帧图像 |
| 镜头 | 每个镜头的视频片段 |
| 成片 | 最终导出的视频 |

**核心流程**：剧本 → 资产 → 脚本(审核) → 镜图(审核) → 镜头(审核) → 成片 → 导出

**跨模块规则**：模块间禁止直接引用 Data；跨模块依赖通过接口，由 pub 编排；`module A → module B` 禁止。

## 2. 实现前必读（详见 README）

| 顺序 | 内容 | 位置 |
|------|------|------|
| 1 | 领域模型与状态机 | README §三、领域模型 |
| 2 | 目录设计、Handler→Service→Data | README §目录设计 |
| 3 | 错误处理规范 | README §8.4 |

## 3. 开发规范速查（详见 ai-development-guidelines）

- 新功能前先搜索已有实现、工具类、模型
- 不猜第三方 API，不确定时查源码/文档；不擅自改 go.mod/pubspec 依赖版本
- 处理空值、超时、查询为空、无效输入；异常必记日志，不写空 catch
- 单文件 ≤600 行
- 注释使用中文；敏感信息走配置/环境变量；SQL 防注入；接口鉴权

## 4. 服务与启动

| 服务 | 命令 | 端口 |
|------|------|------|
| Go 后端 | `cd anime_ai && go run .` 或 `air` | 3737 |
| Flutter 前端 | `flutter run -d web-server --web-port 8080` | 8080 |
| 前端连后端 | 需 `--dart-define=API_BASE_URL=http://localhost:3737/api/v1` | |
| Redis | `redis-server --daemonize yes`（异步任务依赖） | |
| 一键启停 | `r.sh` 启动 / `s.sh` 停止 | |

默认管理员：`admin` / `admin123`

## 5. 常用命令

- 后端：`anime_ai/Makefile`（run、build、test、tidy）
- Flutter 代码生成：`dart run build_runner build --delete-conflicting-outputs`（修改 freezed/json_serializable 模型后必跑）

## 6. 注意事项

- Go 1.26+ 必须（README 技术选型写 1.26）
- Flutter SDK ^3.11.0
- **禁止修改 README.md**：AI 助手不得修改该文件，仅可阅读参考。

## 7. Cursor 偏好

- **不录制视频**：除非用户明确要求，否则不录制演示视频。

## Cursor Cloud specific instructions

### 环境概览

本项目为 monorepo，包含 Go 后端 (`anime_ai/`) 和 Flutter Web 前端 (`anime_ui/`)。

| 组件 | 位置 | 端口 |
|------|------|------|
| Go 后端 | `anime_ai/` | 3737 |
| Flutter 前端 | `anime_ui/` | 8080 |
| Redis | 系统服务 | 6379 |

### 工具版本

- **Go**: 1.26（安装于 `/usr/local/go/bin`）
- **Flutter**: 3.41.x stable（安装于 `/opt/flutter/bin`，Dart SDK 3.11.0）
- **Redis**: 7.x（通过 apt 安装）

### PATH 设置

Cloud VM 中 Go 和 Flutter 需要在 PATH 中：
```
export PATH="/usr/local/go/bin:/opt/flutter/bin:$PATH"
```

### 启动服务

1. **Redis**: `redis-server --daemonize yes`
2. **后端**: `cd anime_ai && cp config.yaml.example config.yaml`（仅首次），然后 `go run .` 或 `air`
3. **前端**: `cd anime_ui && flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3737/api/v1`

### 已知问题

- `anime_ui/test/widget_test.dart` 引用了不存在的 `MyApp`（实际为 `AnimeApp`），导致 `flutter test` 和 `flutter analyze` 报错。这是仓库已有问题，非环境配置错误。
- 项目处于早期阶段，大部分模块仅包含占位 `doc.go` 文件。后端目前仅注册了 `/api/v1/health` 一个路由。
- PostgreSQL 尚未在 `go.mod` 中作为依赖引入，后端启动不需要数据库连接。

### 常用命令参考

见 §4（服务与启动）和 §5（常用命令）。后端 Makefile targets: `run`, `build`, `test`, `tidy`, `clean`。
