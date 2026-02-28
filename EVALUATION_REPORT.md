# AI-Anime 代码库评估报告

> 严格按照 README.md 各章节规范进行全面评估

---

## 一、目录设计与命名规范

| 检查项 | 状态 | 说明 |
|--------|------|------|
| 根目录结构 | ⚠️ | 缺少 `deploy_packages/` 目录和 `build_deploy.sh` 脚本 |
| 后端 `module/` + `pub/` 布局 | ✅ | 完全符合规范 |
| 后端模块内用层名文件 | ✅ | 统一使用 `handler.go`、`service.go`、`data.go` |
| 后端 pub 跨模块文件命名 | ✅ | 遵循 `资源_层` 模式 |
| 前端 `module/` + `pub/` 布局 | ✅ | 结构清晰 |
| 前端模块内层名子目录 | ⚠️ | 约半数模块未使用 `providers/`、`widgets/`、`view/` 子目录结构，如 `login/`、`story/`、`draft/`、`episode/` 等直接将文件放在模块根目录 |
| 语义化命名 | ✅ | 未发现 `s1.go`、`util2.dart` 等反模式 |
| 单文件 ≤600 行（后端） | ✅ | 所有手写 .go 文件均在 600 行内（最大 488 行），仅 sqlc 自动生成文件 `shots.sql.go`（767 行）超标 |
| 单文件 ≤600 行（前端） | ❌ | **8 个手写 Dart 文件超标**，详见下表 |

**前端超 600 行文件：**

| 文件 | 行数 |
|------|------|
| `draft/preview_page.dart` | 1400 |
| `script/view/widgets/review_editor.dart` | 1329 |
| `pub/widgets/prompt_field_with_assistant.dart` | 862 |
| `pub/models/storyboard_script.dart` | 803 |
| `script/scene_editor.dart` | 787 |
| `script/block_item.dart` | 779 |
| `assets/versions_page.dart` | 763 |
| `script/view/widgets/center_task_section.dart` | 679 |

---

## 二、跨模块调用规则

| 检查项 | 状态 | 说明 |
|--------|------|------|
| 模块间禁止直接引用 Data | ✅ | 未发现违规 |
| 通过接口解耦 | ✅ | `pub/crossmodule/` 定义接口（`EpisodeReader`、`ProjectVerifier`、`ShotReader`、`ProjectStoryboardAccess`），模块通过依赖注入使用 |
| pub 提供跨模块编排 | ✅ | `pub/crossmodule/` 实现编排 |
| sch 提供共享数据模型 | ✅ | `sch/db/` 存放 sqlc 生成的共享模型 |
| 依赖方向正确 | ⚠️ | `pub/worker/image_handler.go` 直接 import 了 `module/shot_image`，建议将 `ShotImageStore` 接口移至 `pub/crossmodule/` |

---

## 三、后端分层（Handler → Service → Data）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| 分层结构 | ✅ | 所有模块均严格遵循 Handler → Service → Data 三层 |
| Handler 职责 | ✅ | HTTP 请求解析、参数校验、调用 Service、统一响应 |
| Service 职责 | ✅ | 业务逻辑、状态转换、跨层协调 |
| Data 职责 | ✅ | 数据访问，支持 DB 和内存双实现（`data_db.go`、`data_mem.go`） |

---

## 四、领域模型与状态机

### 4.1 核心实体实现情况

| 实体 | 后端 | 前端 | 说明 |
|------|------|------|------|
| Project | ✅ | ✅ | |
| Episode | ✅ | ✅ | |
| Scene / SceneBlock | ✅ | ✅ | Block 类型完整：action/dialogue/os/direction/closeup |
| Character | ✅ | ✅ | |
| **Asset** | ❌ | ✅ | 后端无独立 Asset 实体，仅有 AssetVersion |
| AssetVersion | ✅ | ✅ | |
| Storyboard | ⚠️ | ✅ | 后端存储为 Project 的 JSON 字段，非独立表 |
| Shot | ✅ | ✅ | |
| ShotImage | ✅ | ❌ | 前端无独立 ShotImage 模型 |
| **ShotVideo** | ⚠️ | ❌ | DB Schema 存在但无模块实现（无 handler/service/data） |
| CompositeTask | ✅ | ❌ | 前端缺失模型 |
| User | ✅ | ✅ | |
| Organization / Team | ✅ | ✅ | |
| ReviewRecord | ✅ | ❌ | 前端缺失模型 |
| Notification | ✅ | ❌ | 前端缺失模型 |
| Schedule | ✅ | ❌ | 前端缺失模型 |
| **Cron** | ❌ | ❌ | 无独立实体，cron_expr 内嵌于 Schedule |

### 4.2 状态机实现

| 状态机 | 状态 | 说明 |
|--------|------|------|
| 剧本 `draft→editing→locked` | ❌ | 无显式状态机，仅有 lock 标志位 |
| 脚本 `generated→editing→frozen` | ❌ | 无状态机实现 |
| 镜图/镜头 `pending→generating→review→approved/rejected` | ⚠️ | 基本流程有，但缺少 `regenerating`（不通过闭环）和 `locked`（锁定后不可修改）状态 |
| 成片 `editing→exporting→done` | ✅ | 完整实现 |
| 审核细化状态机 | ✅ | `review→ai_reviewing→ai_approved/ai_rejected→human_review→approved/rejected` 完整实现 |
| 任务锁 `待执行/执行中/已完成/已取消` | ✅ | 完整实现，含执行人、时间、超时释放 |

---

## 五、错误处理规范（§8.4）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| 统一错误码 ERR_XXX | ✅ | `pub/pkg/errs.go` 定义 `ErrNotFound`、`ErrUnauthorized` 等 |
| 错误透传 {code, message} | ✅ | Handler 统一使用 `pkg.BadRequest`、`pkg.InternalError` 等 |
| **zap 日志记录错误** | ❌ | **所有 18 个 Handler 文件均未注入 logger，错误未记录 zap 日志** |
| **日志含 request_id** | ❌ | Handler 不读取 request_id，错误日志缺失上下文 |
| 防御性编程 | ✅ | 未发现空 catch/recover，`errors.Is`/`errors.As` 使用正确 |
| **错误信息泄露** | ⚠️ | 部分 Handler 直接返回 `err.Error()` 给前端，可能暴露内部信息 |

---

## 六、安全

| 检查项 | 状态 | 说明 |
|--------|------|------|
| JWT 认证 | ✅ | `middleware.JWTAuth` 保护所有接口，secret 从配置加载 |
| 接口鉴权 | ✅ | 路由分组保护、`AdminOnly()` 中间件、`ProjectContext()` 项目级鉴权 |
| SQL 防注入 | ✅ | 全部使用 sqlc 参数化查询，无字符串拼接 |
| 敏感信息走配置/环境变量 | ⚠️ | `config.yaml` 含硬编码 API Key/密码且已提交到仓库（注释说明为测试用），`config.yaml.example` 存在但 `config.yaml` 未在 `.gitignore` 中排除 |

---

## 七、验收标准检查清单（§七）

| 验收项 | 状态 | 说明 |
|--------|------|------|
| 目标达成（效率、资产复用） | ✅ | 资产按 ID 引用，不复制 |
| AI 驱动 | ✅ | LLM、文生图、文生视频、TTS 多 Provider 支持 |
| 任务编排 | ⚠️ | Asynq 异步任务有，但无端到端流水线编排（一键出片）和断点续跑 |
| 定时任务 | ⚠️ | Schedule 模块有 cron_expr，但 main.go 未启动定时轮询 |
| 双线 AI | ⚠️ | 审核 AI 用同一 Mesh，无独立"审核 AI 线"配置 |
| 核心环节审核 | ✅ | 脚本、镜图、镜头均有审核流程 |
| 审核可人工/AI | ✅ | 支持 `ModeHuman`/`ModeAI`/`ModeHumanAI` 三种模式 |
| 团队防冲突 | ✅ | TaskLock 完整实现 |
| **完整流程** | ⚠️ | 各阶段 API 存在，但缺少 ShotVideo 模块实现和自动化流水线编排 |
| 任务锁 | ✅ | 完整 |
| 任务通知 | ✅ | WebSocket + 站内通知 + 前端红点角标均已实现 |
| **生成物下载** | ❌ | 工具函数（`DownloadFile`、`ZipFiles`）存在但**无 API 端点**，无按集打包下载 |
| 布局自动适配 | ✅ | `LayoutBuilder`、`MediaQuery` 响应式布局 |
| **测试** | ❌ | 仅 4 个 Service 单测 + 1 个 RBAC 测试 + 1 个 Widget 烟雾测试，无集成测试、无 E2E 测试、无覆盖率追踪 |
| **可观测性** | ⚠️ | Prometheus `/metrics` 有，但无 OpenTelemetry、无 Grafana、无 Alertmanager |
| **AI 成本** | ❌ | Schema 存在但未集成：Provider 调用后未记录用量、无预算控制、无告警 |

---

## 八、非功能需求（§五）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| 剧本渐进加载 | ⚠️ | 场景/块按需加载，但核心列表（projects、episodes）无分页 |
| 任务进度 WebSocket <2s | ✅ | `realtime/hub.go` 实现实时推送 |
| 列表分页 ≤50 | ⚠️ | review、notification、task_lock 有分页（默认 limit=50），但 projects、characters、episodes 等核心列表无分页 |
| JWT 鉴权 | ✅ | |
| 项目级鉴权 | ✅ | `ProjectContext` 中间件 |
| 模块独立 | ✅ | |
| 单文件 ≤600 行 | ❌ | 后端合规，前端 8 个文件超标 |
| 异常必记日志 | ❌ | Handler 层缺失日志 |
| 多 AI Provider | ✅ | LLM/Image/Video/Audio/Music 多 Provider |
| Asynq + 状态机编排 | ⚠️ | Asynq 有，但无复杂流水线状态机编排 |

---

## 九、运维与质量保障（§八）

| 检查项 | 实现度 | 说明 |
|--------|--------|------|
| **§8.1 测试** | ~30% | 5 个单测文件，无集成/E2E 测试，无覆盖率 |
| **§8.2 可观测性** | ~25% | Prometheus 指标有，无 OpenTelemetry/Grafana/Alertmanager |
| **§8.3 AI 成本控制** | ~20% | Schema 有，但未集成录入/预算/告警 |
| §8.4 错误处理 | ~70% | 错误码有，但 Handler 层缺失日志 |
| **§8.5 缓存策略** | ~40% | `RedisCache` 工具有 Get/Set/Delete，但未在 main.go 初始化，模块未使用缓存 |
| **§8.6 文件清理** | ~30% | `FileCleanupWorker` 已实现但未在 main.go 启动，无失败清理/孤立文件检测 |

---

## 十、总体评分

| 维度 | 评分 | 等级 |
|------|------|------|
| 目录设计与命名 | 80/100 | B+ |
| 跨模块解耦 | 95/100 | A |
| 后端分层 | 95/100 | A |
| 领域模型 | 65/100 | C+ |
| 状态机 | 55/100 | C |
| 错误处理 | 60/100 | C |
| 安全 | 80/100 | B+ |
| 验收标准 | 55/100 | C |
| 非功能需求 | 60/100 | C |
| 运维质量保障 | 35/100 | D |
| **综合** | **63/100** | **C+** |

---

## 十一、优先级建议（按紧急程度排序）

### P0 — 阻塞验收

1. Handler 层注入 zap logger，所有错误记录日志含 request_id
2. 实现 ShotVideo 模块（handler/service/data）
3. 实现生成物下载 API 端点（单文件 + 按集打包 ZIP）
4. 补充剧本状态机 `draft→editing→locked` 和脚本状态机 `generated→editing→frozen`
5. 镜图/镜头补充 `regenerating`（不通过闭环）和 `locked` 状态

### P1 — 核心功能完善

6. AI Provider 调用后集成用量记录（调用 `CreateProviderUsage`）
7. 在 main.go 初始化 `RedisCache` 并在 project/character 等模块集成缓存
8. 启动 `FileCleanupWorker`
9. 启动定时任务轮询（Schedule 模块的 `ListDueSchedules`）
10. 核心列表（projects、episodes、characters）添加分页

### P2 — 质量提升

11. 拆分前端 8 个超 600 行文件
12. 前端模块统一使用 `providers/`、`widgets/`、`view/` 子目录
13. 补充集成测试和 E2E 测试
14. 集成 OpenTelemetry 分布式追踪
15. 创建 Grafana 仪表盘配置
16. 补充前端缺失的领域模型（ShotImage、CompositeTask、ReviewRecord、Notification、Schedule）
