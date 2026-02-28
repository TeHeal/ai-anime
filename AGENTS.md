# AGENTS

> 编码规范自动加载自 [ai-development-guidelines.mdc](.cursor/rules/ai-development-guidelines.mdc)，无需手动查阅。
> 产品规格（术语、领域模型、目录设计、需求）见 [README.md](README.md)。

## 1. 核心流程

**流水线**：剧本 → 资产 → 脚本(审核) → 镜图(审核) → 镜头(审核) → 成片 → 导出

**术语**：[README §术语表](README.md#术语表优先阅读)

**跨模块规则**（[详见 README](README.md#跨模块调用规则ai-须遵循)）：同级模块可引用 Service；禁止引用其他模块 Data；接口解耦可选；跨领域经 pub 编排。

## 2. 实现前——按需查阅

| 触发条件 | 必须执行 |
|----------|---------|
| 任何新功能 | 先搜索已有实现、工具类、模型 → 阅读 [README §领域模型](README.md#3-领域模型数据结构与状态机实现前须冻结) |
| 涉及新模块或目录 | 阅读 [README §目录设计](README.md#目录设计) |
| 涉及错误返回 | 阅读 [README §7.4 错误处理](README.md#74-错误处理规范) |
| 修改 freezed / json_serializable 模型后 | 必跑 `dart run build_runner build --delete-conflicting-outputs` |

## 3. 服务与启动

| 服务 | 命令 | 端口 |
|------|------|------|
| Go 后端 | `cd anime_ai && go run .` 或 `air` | 3737 |
| Flutter 前端 | `flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3737/api/v1` | 8080 |
| Redis | `redis-server --daemonize yes` | 6379 |
| 一键启停 | `r.sh` 启动 / `s.sh` 停止 | |

默认管理员：`admin` / `admin123`

Make targets（`anime_ai/Makefile`）：`run` `build` `test` `tidy` `clean`

## 4. 硬性约束

- Go 1.26+、Flutter ^3.11.0、单文件 ≤600 行
- 注释使用中文
- **禁止修改 README.md**（仅阅读参考）
- 不录制演示视频（除非用户明确要求）

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

启动顺序和命令见 §3，Cloud 环境额外注意：

1. **Redis**：启动后执行 `redis-cli config set stop-writes-on-bgsave-error no`（Cloud VM 磁盘权限导致 RDB 快照失败）
2. **PostgreSQL 可选**：DSN 为空或连接失败时自动 fallback 到内存存储，后端可正常启动
3. **Asynq Worker**：依赖 Redis，可用时自动启动
4. **登录测试**：`POST /api/v1/auth/login`，凭证 `admin`/`admin123`

### 已知问题

- `go vet` 报告 `module/episode/data.go:48` 自赋值警告，属仓库已有问题
- `middleware.CORS()` 已定义（`pub/middleware/cors.go`）但未在 `main.go` 中注册，浏览器跨域请求（前端 :8080 → 后端 :3737）会被 CORS 策略阻止；终端 `curl` 不受影响。如需浏览器端测试，需将 `r.Use(middleware.CORS())` 添加到 `main.go` 的中间件链中
