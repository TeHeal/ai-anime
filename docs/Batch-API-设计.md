# Batch API 支持方案设计

> 以「时间」换「金钱」：非实时 LLM 调用可享受约 50% 价格折扣、更高限流额度。本文档描述系统如何支持 Batch API 模式。

## 一、Batch API 核心机制回顾

| 特性 | 说明 |
|------|------|
| **流程** | 上传 jsonl 文件 → 创建 Batch → 厂商在空闲时段处理（通常 1–24h）→ 下载结果文件 |
| **价格** | 约 50% 折扣（以 OpenAI 为例） |
| **限流** | 独立额度池，不占用实时 API 配额 |
| **限制** | 不支持流式；单 Batch 最多约 5 万条；单文件最大约 200MB |

**适用场景**：内容审核、数据提取、离线翻译、分类/打标签等「可等几小时」的任务。  
**不适用**：聊天机器人、实时翻译、即时搜索建议、强依赖步骤的自动化工作流。

---

## 二、本系统适用 Batch 的业务场景

| 场景 | 当前实现 | 是否适合 Batch | 说明 |
|------|----------|----------------|------|
| **脚本辅助**（扩写/润色/续写） | `StreamAssist` 流式 | ❌ 不适合 | 用户等待即时反馈 |
| **分镜生成**（整集拆镜） | `GenerateSync` 同步 | ⚠️ 可选 | 若用户接受「稍后完成」，可走 Batch |
| **镜图 AI 审核** | `AIReviewer.ReviewImage` 单张 | ✅ 非常适合 | 批量选中镜图 → 批量 AI 审核 |
| **脚本 QA**（审核 AI 线） | 待接入 | ✅ 适合 | 批量审核脚本质量 |
| **角色/资产批量分析** | 占位 | ✅ 适合 | 批量分析角色描述、小传等 |

**优先落地**：镜图批量 AI 审核（已有 `AIReviewer` 接口与审核流程，扩展为「批量模式」收益最大）。

---

## 三、架构设计

### 3.1 分层与职责

```
┌─────────────────────────────────────────────────────────────────┐
│  Handler / 业务 Service（如 shot_image）                          │
│  - 收集待处理项（如 shot_ids）                                     │
│  - 决定走「实时」还是「Batch」（根据数量、配置）                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│  LLMBatchService（pub/provider/llm/batch.go）                     │
│  - SubmitBatch(requests []BatchRequest) → batchID                │
│  - GetBatchStatus(batchID) → status, outputFileID                │
│  - PollAndApply(batchID, callback) → 轮询完成后回调                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│  LLMBatchProvider 接口（仅支持 Batch 的 Provider 实现）            │
│  - UploadInputFile(jsonl) → fileID                               │
│  - CreateBatch(fileID, endpoint) → batchID                       │
│  - GetBatch(batchID) → status, outputFileID                      │
│  - DownloadOutput(fileID) → jsonl 内容                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│  OpenAI 兼容 Batch API（OpenAI、DeepSeek、Kimi 等）                │
│  - POST /v1/files (purpose=batch)                                │
│  - POST /v1/batches                                              │
│  - GET /v1/batches/:id                                           │
│  - GET /v1/files/:id/content                                     │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 与现有组件的关系

| 组件 | 关系 |
|------|------|
| **LLMService** | 保持现有 `Chat`/`ChatStream`/`ChatWithJSON`，Batch 作为**并行能力**，不替换实时接口 |
| **LLMProvider** | 现有接口不变；Batch 由 `LLMBatchProvider` 扩展，仅部分 Provider 实现 |
| **Asynq** | Batch 的「提交 + 轮询 + 结果回写」可作为 Asynq 任务执行，避免阻塞 HTTP |
| **AIReviewer** | 单张审核仍走实时；新增 `BatchAIReview(shotIDs)` 走 Batch 路径 |

### 3.3 数据模型

新增表 `llm_batch_tasks`（或 `llm_batches`）：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | uuid | 主键 |
| batch_id | text | 厂商返回的 batch_id（如 batch_abc123） |
| provider | text | deepseek / openai / kimi |
| batch_type | text | shot_image_review / storyboard / script_qa 等 |
| status | text | validating / in_progress / finalizing / completed / failed / expired |
| input_file_id | text | 厂商文件 ID |
| output_file_id | text | 完成后的结果文件 ID（可空） |
| request_count | int | 请求条数 |
| metadata_json | jsonb | 业务元数据（如 project_id, user_id） |
| created_at | timestamptz | 创建时间 |
| completed_at | timestamptz | 完成时间（可空） |

`custom_id` 约定：每条请求的 `custom_id` 与业务 ID 对应（如 `shot_id`），便于结果回写。

---

## 四、流程设计

### 4.1 镜图批量 AI 审核流程

```
用户选中 N 张镜图 → 点击「批量 AI 审核」
    │
    ▼
Handler: POST /shot-images/batch-ai-review { shot_ids: [...] }
    │
    ▼
Service 判断：
  - 若 N < batch_min_requests（如 10）→ 逐张走实时 AIReviewer（现有逻辑）
  - 若 N >= batch_min_requests 且 batch_enabled → 走 Batch 路径
    │
    ▼
1. 构建 jsonl：每行 { custom_id: shot_id, method: POST, url: /v1/chat/completions, body: {...} }
   - body 含 system prompt（审核规则）+ user prompt（镜图 URL + 镜头描述）
    │
    ▼
2. 调用 LLMBatchService.SubmitBatch(requests)
   - 上传 jsonl → CreateBatch → 写入 llm_batch_tasks
   - 入队 Asynq 任务：BatchPollTask(batch_id)
    │
    ▼
3. 返回 batch_id 给前端，前端轮询 GET /llm-batches/:id 或 WebSocket 推送
    │
    ▼
4. Asynq Worker 轮询 Batch 状态（如每 5 分钟）
   - status=completed → 下载 output_file
   - 解析 jsonl，按 custom_id 映射到 shot_id
   - 调用 shotReader.BatchUpdateShotReview(shotIDs, status, comment)
   - 写入 ReviewRecord，发送站内通知
```

### 4.2 配置项

```yaml
# config.yaml
llm:
  # 现有配置
  deepseek_key: "..."
  kimi_key: "..."

  # Batch 相关（新增）
  batch_enabled: true                    # 是否启用 Batch 模式
  batch_provider: "deepseek"             # 用于 Batch 的 Provider（需支持 Batch API）
  batch_min_requests: 10                 # 少于 N 条时仍用实时 API
  batch_poll_interval_minutes: 5         # 轮询间隔（分钟）
```

**注意**：需确认 DeepSeek、Kimi 等是否提供 Batch API。OpenAI 官方支持；国产厂商可能需查阅各自文档（如阿里百炼 Batch 接口）。

---

## 五、实现步骤（建议分阶段）

### 阶段 1：基础设施（不依赖具体业务）

1. 定义 `LLMBatchProvider` 接口与 `BatchRequest`/`BatchResult` 结构体
2. 实现 OpenAI 兼容的 Batch Provider（`OpenAIBatchProvider`，可复用 `openai_compat.go` 的 baseURL/apiKey）
3. 实现 `LLMBatchService`：SubmitBatch、GetStatus、DownloadAndParse
4. 新增 `llm_batch_tasks` 表及 Data 层
5. 配置项：`batch_enabled`、`batch_provider`、`batch_min_requests`

### 阶段 2：镜图批量 AI 审核

1. 扩展 `shot_image` 模块：新增 `BatchAIReview(shotIDs)` 接口
2. 构建镜图审核的 prompt 模板（与现有 `AIReviewer` 逻辑一致）
3. Handler：`POST /shot-images/batch-ai-review`
4. Asynq Worker：`BatchPollTask` 轮询 + 结果回写
5. 前端：批量选择 + 「批量 AI 审核」按钮 + 任务状态展示

### 阶段 3：扩展（可选）

- 分镜生成 Batch 模式：用户选择「稍后完成」时走 Batch
- 脚本 QA 批量审核
- 用量统计：Batch 与实时分开统计，便于成本分析

---

## 六、与实时 API 的切换策略

| 条件 | 使用方式 |
|------|----------|
| `batch_enabled=false` | 始终实时 |
| 请求数 < `batch_min_requests` | 实时（避免小批量也走 Batch 的额外延迟） |
| 请求数 >= `batch_min_requests` 且 `batch_enabled=true` | Batch |
| 用户显式选择「立即完成」 | 实时（如分镜生成可提供两种选项） |

---

## 七、风险与注意事项

1. **Provider 兼容性**：并非所有 LLM 厂商都支持 Batch API，需逐家确认；不支持的 Provider 不实现 `LLMBatchProvider`
2. **24h 超时**：Batch 未在 24h 内完成会 `expired`，需在结果回写时处理 `error_file` 中的失败项，并标记为「AI 审核超时，请人工审核」
3. **custom_id 唯一性**：同一 Batch 内不可重复，否则厂商可能拒绝
4. **文件大小**：镜图审核若使用 base64 会迅速超限，应使用 `image_url` 引用可公网访问的 URL

---

## 八、主流平台 Batch API 支持情况

> 截至 2025 年初调研结果，供选型参考。具体以各平台最新文档为准。

### 8.1 大语言模型（LLM）

| 平台 | 国家/地区 | 是否支持 Batch | 说明 |
|------|-----------|----------------|------|
| **OpenAI** | 美国 | ✅ 支持 | 官方 Batch API，支持 chat/completions、embeddings、moderations、images 等 |
| **Anthropic Claude** | 美国 | ✅ 支持 | Message Batches API，50% 折扣，单批最多 10 万条或 256MB |
| **Google Gemini** | 美国 | ✅ 支持 | Vertex AI Batch Inference，支持 Gemini 2.0/2.5/3 系列 |
| **Azure OpenAI** | 美国 | ✅ 支持 | 与 OpenAI 兼容，支持 Blob Storage 输入 |
| **DeepSeek** | 中国 | ✅ 支持 | OpenAI 兼容格式，可用 OpenAI SDK 调用 Batch |
| **阿里云百炼（通义千问）** | 中国 | ✅ 支持 | Batch Chat（同步等待）+ 文件输入模式，50% 折扣 |
| **智谱 GLM** | 中国 | ✅ 支持 | 官方 Batch API，支持文本/图像/向量化，50% 折扣 |
| **Kimi（月之暗面）** | 中国 | ❓ 未明确 | 官方文档未提及 Batch，仅支持流式/同步 |
| **豆包（字节跳动）** | 中国 | ❓ 未明确 | 官方文档未提及 Batch API |
| **百度千帆（文心）** | 中国 | ❓ 待确认 | 千帆 4.0 有批量能力，需查官方文档 |

### 8.2 文生图（Image Generation）

| 平台 | 是否支持 Batch | 说明 |
|------|----------------|------|
| **OpenAI DALL·E** | ✅ 支持 | Batch API 支持 `/v1/images/generations`、`/v1/images/edits` |
| **阿里云百炼（万相/FLUX）** | ⚠️ 异步任务 | 文生图为「创建任务→轮询」模式，非标准 Batch 文件输入 |
| **智谱 CogView** | ✅ 支持 | 智谱 Batch API 支持图像生成 |
| **Stability AI** | ❓ 未明确 | 有 Batch 工具，但非标准 API 形式 |
| **Midjourney** | ❌ 不支持 | 无公开 Batch API |

### 8.3 文生视频（Video Generation）

| 平台 | 是否支持 Batch | 说明 |
|------|----------------|------|
| **Runway** | ❌ 未明确 | 主要为单任务异步，无标准 Batch 文档 |
| **Kling（可灵）** | ⚠️ 异步任务 | 支持批量提交，但为「多任务并行」非厂商 Batch 队列 |
| **阿里云万相** | ⚠️ 异步任务 | 创建任务→轮询，非 Batch 文件模式 |
| **天幕（万兴）** | ⚠️ 有 Batch 端点 | `/v3/pic/t2v/batch` 支持批量 |

### 8.4 小结

- **LLM**：OpenAI、Anthropic、Google、Azure、DeepSeek、阿里百炼、智谱 明确支持 Batch；Kimi、豆包 需进一步确认。
- **文生图**：OpenAI、智谱 支持；其余多为异步任务模式。
- **文生视频**：主流平台多为单任务异步，Batch 能力有限。

---

## 九、参考

- [OpenAI Batch API 官方文档](https://platform.openai.com/docs/guides/batch)
- [Anthropic Message Batches](https://docs.anthropic.com/zh-CN/docs/build-with-claude/batch-processing)
- [阿里云百炼 Batch 接口](https://help.aliyun.com/zh/model-studio/batch-interfaces-compatible-with-openai)
- [智谱 Batch 批量处理](https://docs.bigmodel.cn/cn/guide/tools/batch)
- 本系统 `pub/provider/llm/`、`module/shot_image/review_flow.go`、`pub/worker/`
