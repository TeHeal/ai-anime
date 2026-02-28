# 迁移映射表：anime（旧版）→ ai-anime（新版）

> 阶段 0 产出：旧版 handler/service/repo 与新版 module 的对应关系，供阶段 3 迁移时参考。
>
> **旧版路径**：`anime/ai-anime-api/internal/`  
> **新版路径**：`ai-anime/anime_ai/`

---

## 一、环境检查结果

| 工具 | 状态 | 说明 |
|------|------|------|
| **psql** (PostgreSQL 客户端) | ✅ 已安装 | `psql (PostgreSQL) 16.11` |
| **sqlc** | ✅ 已安装 | sch 层 SQL 代码生成 |

### sqlc 安装命令

```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```

安装后确保 `$GOPATH/bin` 或 `$HOME/go/bin` 在 `PATH` 中。

---

## 二、Handler 文件 → 新版 Module 映射表

| 旧版 handler 文件 | 新版 module | 备注 |
|-------------------|-------------|------|
| auth.go | module/auth | 登录、JWT、用户认证 |
| project.go | module/project | 项目 CRUD、成员 |
| episode.go | module/episode | 集 CRUD |
| scene.go | module/scene | 场 CRUD |
| scene_block.go | module/scene | 块 CRUD |
| character.go | module/character | 角色 CRUD |
| routes_character.go | module/character | 角色相关路由（小传、形象、快照等） |
| character_snapshot.go | module/character | 角色快照 |
| segment.go | module/script | 脚本分段 |
| script_parse.go | module/script | 脚本解析 |
| script_ai.go | module/script | 脚本 AI 生成 |
| storyboard.go | module/storyboard | 分镜生成、列表、预览 |
| shot.go | module/shot | 镜头 CRUD |
| shot_generate.go | module/shot | 镜头生成 |
| shot_composite_handler.go | module/shot | 镜头合成 |
| shot_image_handler.go | module/shot_image | 镜图生成、审核 |
| dashboard.go | module/dashboard | 仪表盘（或 pub 编排） |
| org.go | pub 或 module/org | 组织 CRUD |
| team.go | pub 或 module/org | 团队、成员 |
| review.go | pub 或 module/review | 审核记录 |
| lock.go | pub 或 module/lock | 任务锁 |
| task.go | pub/worker | 任务查询、进度 |
| export.go | pub 或 module/export | 成片导出 |
| generate.go | pub 编排 | 统一生成入口 |
| tts.go | pub/worker | TTS 任务 |
| voice.go | pub 或 module/voice | 语音、配音 |
| video_generate.go | pub/worker | 视频生成任务 |
| timeline.go | pub 或 module/timeline | 时间线 |
| ws.go | pub/realtime | WebSocket |
| health.go | module/health | 健康检查 |
| admin.go | pub 或 module/admin | 管理后台 |
| audit.go | pub 或 module/audit | 审计日志 |
| mesh_admin.go | pub/mesh | Mesh 管理 |
| model_catalog.go | pub/controlplane | 模型目录 |
| metadata.go | pub 或 module/metadata | 元数据 |
| file.go | pub/storage | 文件上传 |
| asset.go | module/asset 或 pub | 资产 CRUD |
| asset_version.go | module/asset | 资产版本 |
| delta_asset.go | module/asset | 增量资产 |
| media_asset.go | module/asset | 媒体资产 |
| location.go | module/asset 或 pub | 场景 |
| prop.go | module/asset 或 pub | 道具 |
| resource.go | module/asset 或 pub | 资源 |
| style.go | module/asset 或 pub | 风格 |
| bio.go | pub 或 module/bio | 小传 |
| music.go | pub/worker | 音乐任务 |
| version.go | pub 或 module/version | 版本服务 |
| ai_chat.go | pub 或 module/ai | AI 对话 |
| ai_generate.go | pub 或 module/ai | AI 生成 |
| routes_ai.go | pub | AI 相关路由 |
| routes_collab.go | pub/realtime | 协作路由 |
| routes_media.go | pub/storage | 媒体路由 |
| router.go | 根目录 route.go | 路由注册，不迁移到 module |

**排除**：storyboard_test.go、mesh_admin_test.go（测试文件）

---

## 三、Service 文件 → 新版 Module 映射表

| 旧版 service 文件 | 新版 module | 备注 |
|-------------------|-------------|------|
| auth.go | module/auth | 认证逻辑 |
| project.go | module/project | 项目业务 |
| episode.go | module/episode | 集业务 |
| scene.go | module/scene | 场业务 |
| scene_block.go | module/scene | 块业务 |
| character.go | module/character | 角色业务 |
| character_variant.go | module/character | 角色变体 |
| character_analyze.go | module/character | 角色分析 |
| character_candidate.go | module/character | 角色候选 |
| segment.go | module/script | 分段业务 |
| script_parse.go | module/script | 脚本解析 |
| script_ai.go | module/script | 脚本 AI |
| script_parser/* | module/script | 解析器子包 |
| storyboard_gen.go | module/storyboard | 分镜生成 |
| storyboard_extract.go | module/storyboard | 分镜提取 |
| storyboard_extract_prompt.go | module/storyboard | 提取提示词 |
| storyboard_extract_types.go | module/storyboard | 提取类型 |
| shot.go | module/shot | 镜头业务 |
| shot_generate.go | module/shot | 镜头生成 |
| shot_composite_svc.go | module/shot | 镜头合成 |
| shot_image_svc.go | module/shot_image | 镜图业务 |
| image_qa_svc.go | module/shot_image 或 pub | 镜图 QA |
| composite_qa_svc.go | module/shot 或 pub | 镜头 QA |
| dashboard.go | module/dashboard | 仪表盘 |
| org_service.go | pub 或 module/org | 组织 |
| team_service.go | pub 或 module/org | 团队 |
| review_service.go | pub 或 module/review | 审核 |
| lock_service.go | pub 或 module/lock | 任务锁 |
| task.go | pub/worker | 任务 |
| progress.go | pub 或 module/progress | 进度 |
| export.go | pub 或 module/export | 导出 |
| generate.go | pub 编排 | 生成编排 |
| tts.go | pub/worker | TTS |
| voice.go | pub 或 module/voice | 语音 |
| video_generate.go | pub/worker | 视频生成 |
| timeline.go | pub 或 module/timeline | 时间线 |
| music.go | pub/worker | 音乐 |
| model_catalog.go | pub/controlplane | 模型目录 |
| model_router.go | pub/mesh | 模型路由 |
| admin.go | pub 或 module/admin | 管理 |
| metadata_service.go | pub 或 module/metadata | 元数据 |
| file.go | pub/storage | 文件 |
| asset.go | module/asset 或 pub | 资产 |
| delta_asset.go | module/asset | 增量资产 |
| media_asset.go | module/asset | 媒体资产 |
| version_service.go | pub 或 module/version | 版本 |
| location.go | module/asset 或 pub | 场景 |
| prop.go | module/asset 或 pub | 道具 |
| resource.go | module/asset 或 pub | 资源 |
| resource_generate.go | pub 或 module/asset | 资源生成 |
| style.go | module/asset 或 pub | 风格 |
| style_helpers.go | module/asset 或 pub | 风格辅助 |
| bio.go | pub 或 module/bio | 小传 |
| ai_chat.go | pub 或 module/ai | AI 对话 |
| ai_generate.go | pub 或 module/ai | AI 生成 |
| skeleton.go | pub 或 module | 骨架（按实际用途归属） |

---

## 四、Repo 文件 → 新版 Module Data 或 sch 映射表

| 旧版 repo 文件 | 新版归属 | 备注 |
|----------------|----------|------|
| user.go | module/auth/data.go | 用户表，sqlc 生成后封装 |
| project.go | module/project/data.go | 项目表 |
| project_member.go | module/project/data.go | 项目成员表 |
| episode.go | module/episode/data.go | 集表 |
| scene.go | module/scene/data.go | 场表 |
| scene_block.go | module/scene/data.go 或 module/script/data.go | 块表（剧本与脚本共用） |
| character.go | module/character/data.go | 角色表 |
| character_snapshot.go | module/character/data.go | 角色快照表 |
| segment.go | module/script/data.go | 分段表 |
| shot.go | module/shot/data.go | 镜头表 |
| shot_subtask.go | module/shot/data.go 或 module/shot_image/data.go | 镜头子任务 |
| organization.go | sch 或 module/org | 组织表 |
| org_member.go | sch 或 module/org | 组织成员 |
| team.go | sch 或 module/org | 团队表 |
| team_member.go | sch 或 module/org | 团队成员 |
| review.go | sch 或 module/review | 审核记录表 |
| task.go | sch 或 pub/worker | 任务表 |
| export.go | sch 或 module/export | 导出任务表 |
| timeline.go | sch 或 module/timeline | 时间线表 |
| voice.go | sch 或 module/voice | 语音表 |
| voiceover.go | sch 或 module/voice | 配音表 |
| music.go | sch 或 module/music | 音乐表 |
| prompt_record.go | sch | 提示词记录（可追溯） |
| qa_result.go | sch | QA 结果表 |
| provider_config.go | sch 或 pub | Provider 配置 |
| version.go | sch 或 module/version | 版本表 |
| asset.go | module/asset/data.go | 资产表 |
| asset_version.go | module/asset/data.go | 资产版本表 |
| delta_asset.go | module/asset/data.go | 增量资产表 |
| media_asset.go | module/asset/data.go | 媒体资产表 |
| location.go | module/asset/data.go 或 sch | 场景表 |
| prop.go | module/asset/data.go 或 sch | 道具表 |
| resource.go | module/asset/data.go 或 sch | 资源表 |
| style.go | module/asset/data.go 或 sch | 风格表 |
| model_catalog.go | sch 或 pub | 模型目录表 |
| episode_progress.go | sch 或 module/episode | 集进度表 |
| audit_log.go | sch | 审计日志表 |
| interfaces.go | 不迁移 | 旧版接口定义，新版按需在 pub 中定义 |

---

## 五、依赖顺序（迁移时参考）

按 REFACTOR_PLAN 阶段 3 建议顺序：

1. **auth** → project → episode → scene → character → script → storyboard → shot → shot_image
2. **资产类**（location、prop、style、resource、asset、asset_version、media_asset、delta_asset）可合并为 module/asset 或按需拆分
3. **组织类**（org、team、audit）→ pub 或 module/org
4. **任务类**（task、lock、review、export）→ pub/worker 或独立 module

---

## 六、说明

- **pub**：公共层，跨模块能力（worker、realtime、storage、mesh、controlplane 等）
- **sch**：sqlc schema 与 SQL 查询，供各 module data 层调用
- 部分 handler/service/repo 可能对应同一 module 的多个职责，迁移时需按业务边界拆分或合并
- 标注「或 pub」「或 module/xxx」的项，需在具体迁移时根据依赖关系确定最终归属
