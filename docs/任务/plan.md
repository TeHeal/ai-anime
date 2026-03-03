# 剧本解析实施计划（已完成）

## 目标

借鉴 anime-bak 的 script_parser 实现，在当前 anime_ai 中实现剧本同步解析，解决「解析失败: TypeError: null」问题。

## 实施原则

- **借鉴而非直接迁移**：参考原版算法与正则规则，按当前项目架构重写
- **遵循 README 规范**：Handler→Service→Data 分层、单文件 ≤600 行、错误处理规范
- **跨端契约**：ParseResult 与 Flutter ScriptParseResult 契约一致

## 已完成内容

1. **parser 包**（`anime_ai/module/script/parser/`）
   - `types.go`：ParseResult、ParsedScript、ParsedEpisode、ParsedScene、ParsedBlock、ValidationIssue 等
   - `preprocessor.go`：预处理（BOM、零宽字符、标点、粗体碎片、空行）
   - `regex.go`：正则解析（集/场/对白/动作/OS/特写/导演）
   - `validator.go`：基础校验（集号连续性、空集、未识别块）
   - `parser.go`：主流程 预处理 → 正则解析 → 校验

2. **script service 集成**
   - `ParseSync` 调用 `parser.Parse()`，返回真实解析结果
   - 移除占位 ParseResult，使用 `parser.ParseResult`

3. **前端防御**
   - `ScriptParseResult.fromJson` 对 `script == null` 抛出明确 FormatException
   - `ParsedScript.fromJson` 对 `metadata == null` 使用默认空元数据

4. **API 测试**
   - 更新 `TestAPI_Script_ParseSync` 以适配新响应结构
   - 确保 `issues` 非 nil（空 slice 序列化为 `[]`）

## 暂未实现

- LLM 辅助解析（unknown 块）：可后续接入 `pub/provider/llm`
- 异步解析任务（parse + preview）：当前仅支持同步 parse-sync
