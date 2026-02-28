# 重构步骤：anime（旧版）→ ai-anime（新版）

> 目标：将 anime 的业务逻辑迁移到 ai-anime，遵循新架构（module + pub + sch）。
>
> **进度**：阶段 0 ✅ 阶段 1 ✅ 阶段 2 ✅ 阶段 3 ✅ 阶段 4 ✅ 阶段 5 ✅ 阶段 6 ✅（story、draft、script、assets、shots、shot_images、dashboard）

---

## 一、总体顺序

```
阶段 0：准备与基础设施
    ↓
阶段 1：后端 pub 层（配置、中间件、存储、AI 能力）
    ↓
阶段 2：sch 层（PostgreSQL schema + sqlc）
    ↓
阶段 3：后端 module 层（按依赖顺序迁移）
    ↓
阶段 4：后端 pub 跨模块编排
    ↓
阶段 5：前端 pub 层（models、services、providers、widgets）
    ↓
阶段 6：前端 module 层
    ↓
阶段 7：联调与验收
```

---

## 二、阶段 0：准备与基础设施

| 步骤 | 内容 | 产出 |
|------|------|------|
| 0.1 | 确认 PostgreSQL 可用，创建数据库 | 可连接的 DB |
| 0.2 | 安装 sqlc、Atlas（若未安装） | 工具就绪 |
| 0.3 | 梳理旧版 handler→service→repo 映射表 | 迁移对照表 |
| 0.4 | 梳理旧版 API 路由与前端调用对应关系 | API 映射表 |

---

## 三、阶段 1：后端 pub 层

**来源**：anime `internal/config`、`internal/middleware`、`internal/auth`、`internal/storage`、`internal/provider`、`internal/mesh`、`internal/capability`、`internal/adapters`、`internal/controlplane`、`internal/realtime`、`internal/worker`、`internal/tasktypes`、`internal/pkg`

| 步骤 | pub 子目录 | 迁移内容 | 备注 |
|------|------------|----------|------|
| 1.1 | pub/config | config.go、Viper 加载、环境变量 | 对齐 config.yaml.example |
| 1.2 | pub/middleware | request_id、cors、logger、auth、authz、ratelimit、project_ctx、lock_guard、audit | 保持行为一致 |
| 1.3 | pub/auth | JWT、RBAC、上下文 UserID/ProjectID | 与 middleware 配合 |
| 1.4 | pub/pkg | errs、resp、hash、jwt、ffmpeg 等工具 | 抽取通用逻辑 |
| 1.5 | pub/storage | 文件存储抽象（本地/S3） | 接口 + 实现 |
| 1.6 | pub/realtime | WebSocket Hub、房间管理 | 从 internal/realtime 迁移 |
| 1.7 | pub/worker | Asynq 初始化、Server | 任务类型先占位 |
| 1.8 | pub/tasktypes | 任务类型常量 | 从 internal/tasktypes 迁移 |
| 1.9 | pub/capability | LLM、Image、Video、TTS、Music、KIE 接口定义 | 抽象层 |
| 1.10 | pub/adapters | OpenAI 兼容、火山等第三方适配 | 从 internal/adapters 迁移 |
| 1.11 | pub/provider | llm、image、video、audio、music、kie 实现 | 从 internal/provider 迁移 |
| 1.12 | pub/mesh | 路由、熔断、重试、限流 | 从 internal/mesh 迁移 |
| 1.13 | pub/controlplane | 特性开关、模型目录、路由策略 | 从 internal/controlplane 迁移 |

**验收**：`main.go` 能启动，健康检查、CORS、日志、JWT 中间件生效。

---

## 四、阶段 2：sch 层（PostgreSQL + sqlc）

**来源**：anime `internal/repo`、`internal/model`、`migration/`

| 步骤 | 内容 | 备注 |
|------|------|------|
| 2.1 | 设计 PostgreSQL schema | 对齐 README 领域模型：Project、Episode、Scene、SceneBlock、Character、Asset、Storyboard、Shot、ShotImage、ShotVideo、CompositeTask、User、Organization、Team、ReviewRecord、Notification 等 |
| 2.2 | 编写 sqlc schema 文件 | sch/*.sql |
| 2.3 | 编写 sqlc 查询 | sch/queries/*.sql |
| 2.4 | 运行 sqlc generate | 生成 Go 代码 |
| 2.5 | 编写 Atlas 迁移脚本 | migration/*.sql |
| 2.6 | 执行迁移 | 创建表结构 |

**注意**：旧版用 SQLite，需做类型与约束适配（如 JSONB、全文检索等）。

---

## 五、阶段 3：后端 module 层

**依赖顺序**：auth → project → 其他（episode、scene、character、script、storyboard、shot、shot_image 等）

| 步骤 | module | 旧版对应 | 迁移内容 |
|------|--------|----------|----------|
| 3.1 | auth | handler/auth、service/auth、repo/user | 登录、JWT、用户 CRUD |
| 3.2 | project | handler/project、service/*、repo/project、project_member | 项目 CRUD、成员 |
| 3.3 | episode | handler/episode、repo/episode | 集 CRUD |
| 3.4 | scene | handler/scene、scene_block、repo/scene、scene_block | 场、块 CRUD |
| 3.5 | character | handler/character、routes_character、service/character*、repo/character* | 角色、小传、形象、快照 |
| 3.6 | script | handler/script_*、scene_block、segment、repo/segment、scene_block | 脚本、分段、解析 |
| 3.7 | storyboard | handler/storyboard、service、repo、internal/storyboard | 分镜生成 |
| 3.8 | shot | handler/shot、shot_generate、shot_composite、repo/shot、shot_subtask | 镜头、生成、合成 |
| 3.9 | shot_image | handler/shot_image、repo | 镜图生成 |

**每个 module 内部**：
- `handler.go`：HTTP 接口，调用 Service
- `service.go`：业务逻辑，调用 Data（本模块）
- `data.go`：封装 sqlc Queries，仅访问本模块表

**额外 module**（按需拆分或并入 pub）：
- 资产：location、prop、style、resource、asset、asset_version、media_asset、delta_asset
- 组织：org、team、audit
- 任务：task、lock、review、export
- 其他：dashboard、tts、voice、music、video_generate、timeline、admin、model_catalog、metadata、bio

**验收**：各 module 独立可测，route 注册后 API 可调。

---

## 六、阶段 4：后端 pub 跨模块编排

| 步骤 | 内容 | 示例 |
|------|------|------|
| 4.1 | 定义跨模块接口 | CharacterReader、ProjectReader 等 |
| 4.2 | 在 pub 中实现编排服务 | 镜图生成需 character + shot_image，由 pub 编排 |
| 4.3 | Worker 任务实现 | image_task、video_task、tts_task、storyboard_task、export_task 等 |
| 4.4 | route 组装依赖注入 | 将接口实现注入各 module |

---

## 七、阶段 5：前端 pub 层

**来源**：anime `lib/core`、`lib/shared`

| 步骤 | pub 子目录 | 迁移内容 |
|------|------------|----------|
| 5.1 | pub/const | API 地址、常量（已有 api.dart，补充） |
| 5.2 | pub/theme | 主题、颜色（已有 app_theme.dart，对齐旧版） |
| 5.3 | pub/router | go_router 配置（从 core/router 迁移） |
| 5.4 | pub/utils | 工具函数（从 core/utils 迁移） |
| 5.5 | pub/models | freezed 模型（从 shared/models 迁移） |
| 5.6 | pub/data | API 客户端、dio 封装（从 shared/data 迁移） |
| 5.7 | pub/services | API 调用封装（从 shared/services 迁移） |
| 5.8 | pub/providers | 全局 Riverpod Provider（从 shared/providers 迁移） |
| 5.9 | pub/widgets | 通用组件（从 core/widgets、shared/widgets 迁移） |
| 5.10 | pub/ai | AI 相关（从 shared/ai 迁移） |

**验收**：前端能启动，路由、主题、API 基础能力可用。

---

## 八、阶段 6：前端 module 层

**来源**：anime `lib/features`

| 步骤 | module | 旧版对应 | 迁移内容 |
|------|--------|----------|----------|
| 6.1 | login | 登录页 | 登录表单、Token 存储 |
| 6.2 | layout | features/layout | 布局、导航、侧边栏 |
| 6.3 | project | 项目相关 | 项目列表、创建、选择 |
| 6.4 | dashboard | handler/dashboard | 仪表盘 |
| 6.5 | story | features/story | 故事、导入、编辑、确认 |
| 6.6 | script | features/script | 脚本、树形导航、分段、生成、审核 |
| 6.7 | storyboard | features/storyboard | 分镜板 |
| 6.8 | shot_images | 镜图相关 | 镜图列表、生成、审核 |
| 6.9 | shots | features/shots | 镜头、生成、审核、合成 |
| 6.10 | assets | features/assets | 角色、场景、道具、资源、风格、版本 |
| 6.11 | config | features/config | 配置页 |
| 6.12 | task_center | 任务中心 | 任务列表、进度、WebSocket |
| 6.13 | generate | 生成入口 | 统一生成入口 |
| 6.14 | board | 画板 | 若存在 |

**每个 module 内部**：`providers/`、`widgets/`、`view/`（或 `page/`）

**验收**：主流程可走通（登录 → 项目 → 剧本 → 脚本 → 镜图 → 镜头 → 成片）。

---

## 九、阶段 7：联调与验收

| 步骤 | 内容 |
|------|------|
| 7.1 | 前后端联调 | 确保 API 路径、请求/响应格式一致 |
| 7.2 | WebSocket 联调 | 任务进度、实时通知 |
| 7.3 | 数据迁移（可选） | 若需从旧版 SQLite 迁移数据到 PostgreSQL |
| 7.4 | 验收清单 | 对照 README §七、验收标准 |
| 7.5 | 文档更新 | AGENTS.md、README 补充迁移说明 |

---

## 十、风险与注意事项

| 风险 | 应对 |
|------|------|
| 旧版 API 与新版设计不一致 | 建立 API 映射表，必要时做兼容层 |
| SQLite → PostgreSQL 差异 | 类型、函数、约束逐一适配 |
| 模块拆分过细或过粗 | 参考 README 领域模型，按业务边界拆分 |
| 跨模块循环依赖 | 严格遵循「module 间禁止直接引用」，通过 pub 编排 |
| 单文件超 600 行 | 及时拆分子文件或子模块 |

---

## 十一、建议执行节奏

1. **先完成后端可运行**：阶段 0～4，确保后端 API 可用
2. **再完成前端可运行**：阶段 5～6，确保前端可访问各页面
3. **最后联调与优化**：阶段 7

每完成一个阶段可提交一次，便于回滚与 Code Review。
