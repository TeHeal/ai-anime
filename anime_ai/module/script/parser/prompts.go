package parser

const scriptAnalysisPrompt = `你是一个专业的剧本结构分析器。请将以下剧本片段解析为结构化 JSON。

## 识别规则

- **action**（动作描写）：描述场景环境、角色动作的段落，通常以△开头
- **dialogue**（对白）：角色名+冒号+台词内容
- **os**（内心独白/旁白）：角色名+os+冒号+内容
- **closeup**（特写）：以●特写开头，描述特写镜头
- **direction**（导演指示）：以【导演】开头，导演对拍摄的指示

## 输出格式

请严格按以下 JSON 数组格式输出，每个元素对应输入中的一行/一段：

` + "```json" + `
[
  {
    "index": 0,
    "type": "action|dialogue|os|closeup|direction",
    "character": "角色名（仅dialogue和os时填写）",
    "emotion": "情绪（如有括号标注的情绪）",
    "content": "内容文本"
  }
]
` + "```" + `

## 注意

- index 从 0 开始，对应输入片段的顺序
- 如果无法确定类型，使用 "action" 作为默认值
- character 字段仅在 type 为 dialogue 或 os 时填写
- 只输出 JSON，不要输出其他内容

## 输入片段

`
