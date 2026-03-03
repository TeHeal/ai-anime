# AI 网关能力：内置 NewAPI vs 在项目内实现

## 一、两种思路

| 思路 | 含义 | 适用场景 |
|------|------|----------|
| **把 NewAPI 内置到项目** | 将「即梦格式 / 统一 AI」的 HTTP 网关以子模块或独立服务形式跑在本项目内，请求先经该网关再转给各 Provider | 已有现成 NewAPI 服务、希望统一暴露即梦/多厂商 OpenAPI 且不改现有业务路由 |
| **在项目内实现 NewAPI 的能力** | 不引入独立 NewAPI 服务，在本项目现有架构上增强：多租户、统一鉴权、限流、审计、计费 | 希望能力与业务深度结合、少一层转发、运维简单 |

下文以「在项目内实现 NewAPI 能力」为主，并说明若要暴露即梦格式 HTTP 时如何与现有能力结合。

---

## 二、现有能力对照

项目里已有与 NewAPI 类似的能力，对比如下。

| 能力 | 现状 | 位置 | 缺口（若要对齐 NewAPI） |
|------|------|------|--------------------------|
| **多租户** | 项目/用户维度，请求带 project_id、user_id | `ProjectContext`、payload、`provider_usages` | 无；可补「按 org 聚合」若需要 |
| **统一鉴权** | JWT + RBAC（Action），按路由 RequireAction | `middleware.JWTAuth`、`RequireAction(auth.ActionShotVideoGen)` 等 | 无 |
| **限流** | ① 全局按 IP（middleware）② 按 Provider（mesh） | `middleware.RateLimit`、`mesh.RateLimiter` | **按项目/按组织的 AI 配额**（如每项目每月 N 次视频）目前没有 |
| **审计** | 写操作（POST/PUT/DELETE）记 path、resource、user | `middleware.Audit`、`AuditWriter` | **未记录「单次 AI 调用」**（provider、model、用量）；可增强为 AI 调用审计 |
| **计费/用量** | 按次写入 provider_usages（project_id、user_id、provider、model、token_count/image_count/video_seconds） | `provider_usage.Recorder`、Worker 内调用 | **cost_cents 未用**；可加单价配置做成本回填 |

结论：**多租户、统一鉴权已具备；限流、审计、计费可在现有基础上做小幅增强即可达到「在项目内实现 NewAPI 能力」**。

---

## 三、推荐方案：在项目内实现能力（不跑独立 NewAPI）

- **保持现有调用链**：业务 API（如 `POST /shots/:shotId/videos`）→ Handler → Service → Asynq → Worker → `VideoRouter`/Provider，不额外加一层独立 HTTP 网关服务。
- **在现有链路上补齐**：
  1. **按租户/项目的 AI 限流**（可选）：在 Worker 或 Router 提交前，按 `project_id`（或 `org_id`）查配额（如本月已用次数/额度），超限则直接返回错误；配额数据可来自 `provider_usages` 聚合或单独 `project_quotas` 表。
  2. **AI 调用审计**：在 Worker 或封装 Router 的层里，在每次真实调用 Provider 前后写一条「AI 调用」审计（project_id、user_id、provider、model、请求摘要、用量、task_id）；可复用现有 `AuditWriter` 或单独表 `ai_call_logs`。
  3. **计费回填**：在 `provider_usage.Recorder` 里根据 `provider+model` 查单价（配置或表），算出 `cost_cents` 再写入 `provider_usages.cost_cents`；或异步任务扫未计费记录补算。

这样即实现：多租户、统一鉴权、限流（含按项目配额）、审计（含 AI 调用）、计费，且全部在本项目内完成，无需内置独立 NewAPI 服务。

---

## 四、若需要「即梦格式」或统一 AI 的 HTTP 入口

如果希望对外暴露「即梦格式」（如 `POST /jimeng/?Action=CVSync2AsyncSubmitTask`）或统一 OpenAPI 的 AI 接口（供第三方/前端直调），可以二选一：

- **方案 A：在本项目内实现即梦格式 Handler**  
  - 新增路由，例如 `POST /api/v1/ai/jimeng`，查询参数 `Action=CVSync2AsyncSubmitTask` / `CVSync2AsyncGetResult`。  
  - Handler 内解析即梦格式 body，转成现有 `capability.VideoRequest`，调现有 `VideoRouter`，再把结果转成即梦格式响应。  
  - **鉴权/限流/审计/计费**：该路由同样走现有 middleware（JWT、RequireAction、RateLimit、Audit），并在 Worker 或 Router 层继续做「按项目限流 + AI 审计 + 计费」，与现有能力一致。

- **方案 B：反向代理到独立 NewAPI 服务**  
  - 若 NewAPI 是独立进程/服务，在本项目加一层反向代理（如 `GET/POST /api/v1/ai/proxy/*` → NewAPI），在代理入口挂 JWT、限流、审计（记录「调用了 AI 网关」）；用量可由 NewAPI 回传或仍由我们 Worker 记录。  
  - 缺点：多一跳、需维护 NewAPI 部署与版本。

更推荐 **方案 A**：即梦格式在本项目内实现，复用现有 Router/Provider 与全部中间件能力，无额外服务依赖。

---

## 五、小结

| 问题 | 建议 |
|------|------|
| 把 NewAPI 内置到我们项目？ | 若不强制保留独立 NewAPI 服务，**不必内置**；在本项目内实现「多租户、鉴权、限流、审计、计费」即可。 |
| 在我们项目中也实现 NewAPI 的功能？ | **推荐**。多租户与鉴权已有；补充：按项目/组织 AI 配额限流、AI 调用审计、cost_cents 计费回填。 |
| 既要能力又要即梦格式 HTTP？ | 在本项目内增加即梦格式 Handler，转发到现有 VideoRouter/Provider，并复用现有鉴权、限流、审计、计费。 |

以上增强（按项目配额、AI 审计、cost 回填、即梦 Handler）均可分步做，先做计费与审计，再做配额限流与即梦入口。
