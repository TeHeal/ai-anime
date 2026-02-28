package prompt

import (
	"fmt"
	"strings"
)

// ScriptParseSystem 剧本解析系统提示词（剧本文本→脚本分段）
func ScriptParseSystem() string {
	return `你是一位专业的漫剧分镜师。你的任务是将剧本文本解析为结构化的脚本分段（Segment）列表。

每个分段包含：
- 一个或多个连续镜头的描述
- 场景信息、角色动作、对白、镜头指示

输出格式为 JSON 数组：
[
  {"content": "分段1内容", "sort_index": 0},
  {"content": "分段2内容", "sort_index": 1}
]

规则：
1. 按场景自然分段，每场为一个或多个分段
2. 保留原始对白和动作描写
3. 每个分段应自包含，可独立理解
4. sort_index 从 0 开始递增`
}

// ScriptParseUser 剧本解析用户提示词
func ScriptParseUser(story string) string {
	return fmt.Sprintf("请将以下剧本文本解析为脚本分段：\n\n%s", story)
}

// StoryboardSystem 分镜生成系统提示词（脚本分段→分镜镜头指令）
func StoryboardSystem() string {
	return `你是一位专业的漫剧分镜师。你的任务是根据脚本分段生成结构化的分镜镜头指令列表。

每个镜头指令包含：
- prompt: 画面描述（英文，供文生图 AI 使用）
- style_prompt: 风格提示词（英文）
- camera_type: 镜头类型（特写/中景/远景/全景）
- camera_angle: 镜头角度（正面/侧面/俯拍/仰拍/鸟瞰）
- dialogue: 角色对白（中文）
- character_name: 主要角色名
- emotion: 角色情绪
- duration: 预计秒数（3-10）
- transition: 转场方式（切/淡入淡出/溶解）

输出格式为 JSON 数组：
[
  {
    "prompt": "A young woman standing in a neon-lit alley, looking up at the rain",
    "style_prompt": "anime style, dramatic lighting",
    "camera_type": "中景",
    "camera_angle": "仰拍",
    "dialogue": "总有一天，我会离开这里。",
    "character_name": "小雨",
    "emotion": "坚定",
    "duration": 5,
    "transition": "淡入淡出"
  }
]

规则：
1. prompt 使用英文，详细描述画面内容
2. 结合角色外貌特征和场景环境
3. 镜头切换要有节奏感
4. 每个分段通常生成 2-5 个镜头`
}

// StoryboardUser 分镜生成用户提示词
func StoryboardUser(segments []string, characters string) string {
	joined := strings.Join(segments, "\n---\n")
	return fmt.Sprintf("角色信息：\n%s\n\n脚本分段：\n%s\n\n请生成分镜镜头指令。", characters, joined)
}

// ShotImagePrompt 构建镜图生成的完整 prompt
func ShotImagePrompt(basePrompt, stylePrompt, characterAppearance string) string {
	parts := []string{}
	if basePrompt != "" {
		parts = append(parts, basePrompt)
	}
	if characterAppearance != "" {
		parts = append(parts, characterAppearance)
	}
	if stylePrompt != "" {
		parts = append(parts, stylePrompt)
	}
	parts = append(parts, "masterpiece, best quality, highly detailed")
	return strings.Join(parts, ", ")
}

// ShotImageNegative 镜图生成的默认负面提示词
func ShotImageNegative(custom string) string {
	base := "low quality, blurry, distorted, deformed, ugly, bad anatomy, watermark, text"
	if custom != "" {
		return custom + ", " + base
	}
	return base
}

// ReviewSystem AI 审核系统提示词
func ReviewSystem(phase string) string {
	phaseDesc := map[string]string{
		"script":     "脚本分段",
		"shot_image": "镜图（关键帧图像）",
		"shot_video": "镜头视频",
	}
	desc := phaseDesc[phase]
	if desc == "" {
		desc = phase
	}

	return fmt.Sprintf(`你是一位专业的漫剧 QA 审核员。你的任务是审核%s的质量。

评分标准（0-100 分）：
- 90-100：优秀，可直接通过
- 70-89：良好，小问题可接受
- 50-69：一般，需要修改
- 0-49：不合格，需要重新生成

审核维度：
1. 内容完整性：是否包含必要信息
2. 一致性：与剧本/资产描述是否一致
3. 质量：表达/画面/视频质量是否达标
4. 连贯性：与上下文是否衔接流畅

输出格式为 JSON：
{
  "score": 85,
  "approved": true,
  "reason": "画面质量良好，角色形象与设定一致，镜头构图合理。"
}`, desc)
}

// ReviewUser AI 审核用户提示词
func ReviewUser(phase, content, context string) string {
	return fmt.Sprintf("阶段：%s\n\n待审核内容：\n%s\n\n上下文信息：\n%s\n\n请审核并给出评分和意见。", phase, content, context)
}

// ScriptAssistSystem AI 辅助编剧系统提示词
func ScriptAssistSystem() string {
	return `你是一位资深的漫剧编剧助手。你的任务是根据用户的指令辅助创作剧本内容。

你可以：
1. 扩写：将简要描述扩展为详细的场景描写
2. 细化：为已有场景添加动作描写、对白、情绪
3. 补全：为缺失的部分补充合理内容
4. 润色：优化表达方式和叙事节奏

输出直接为剧本文本，保持集-场-块的结构。`
}

// ScriptAssistUser AI 辅助编剧用户提示词
func ScriptAssistUser(instruction, currentContent string) string {
	return fmt.Sprintf("指令：%s\n\n当前内容：\n%s", instruction, currentContent)
}
