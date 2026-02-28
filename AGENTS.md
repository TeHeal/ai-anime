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

1. **Redis**: `redis-server --daemonize yes`，然后执行 `redis-cli config set stop-writes-on-bgsave-error no`（Cloud VM 磁盘权限问题导致 RDB 快照失败）
2. **后端**: `cd anime_ai && go run .`（`config.yaml` 已提交在仓库中，无需手动复制）
3. **前端**: `cd anime_ui && flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3737/api/v1`

### 后端架构要点

- PostgreSQL 为可选依赖：DSN 为空或连接失败时自动 fallback 到内存存储，后端可正常启动和测试所有 API。
- Asynq Worker 依赖 Redis，Redis 可用时自动启动。
- 默认管理员 `admin`/`admin123`，登录接口 `POST /api/v1/auth/login`。

### 已知问题

- `go vet` 报告 `module/episode/data.go:48` 存在自赋值警告，属于仓库已有问题。

### 常用命令参考

见 §4（服务与启动）和 §5（常用命令）。后端 Makefile targets: `run`, `build`, `test`, `tidy`, `clean`。
