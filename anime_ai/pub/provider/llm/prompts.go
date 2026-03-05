package llm

import (
	"fmt"
	"strings"
)

// ── 脚本 AI 辅助 Prompt ──

const scriptAssistSystemPrompt = `你是一位专业的漫剧编剧 AI 助手，擅长创作引人入胜的动漫/漫画剧本。

你的职责：
- 根据用户的请求扩写、润色或续写剧本内容
- 保持与已有剧本风格和语境的一致性
- 输出格式需与用户提供的块类型保持一致
- 使用中文输出

内容块类型说明：
- action（动作描写）：描述角色的动作、表情和肢体语言
- dialogue（台词）：角色说的话，需自然生动
- os（OS 旁白）：画外音或旁白解说
- direction（场景指示）：场景转换、镜头指示等
- closeup（特写）：特写镜头描述

输出规则：
- 直接输出内容，不要加引号、标签或额外格式
- 不要重复输入内容
- 续写时要与前文自然衔接
- 保持内容精炼有力`

// BuildScriptAssistUserPrompt 构建脚本 AI 辅助的用户 Prompt
func BuildScriptAssistUserPrompt(action, blockType, blockContent, sceneMeta string, contextBlocks []string) string {
	var sb strings.Builder

	if sceneMeta != "" {
		sb.WriteString(fmt.Sprintf("【场景信息】\n%s\n\n", sceneMeta))
	}

	if len(contextBlocks) > 0 {
		sb.WriteString("【上下文内容】\n")
		for _, block := range contextBlocks {
			sb.WriteString(block)
			sb.WriteString("\n")
		}
		sb.WriteString("\n")
	}

	sb.WriteString(fmt.Sprintf("【内容块类型】%s\n", blockType))

	switch action {
	case "expand":
		sb.WriteString(fmt.Sprintf("【任务】请将以下内容扩写得更加详细生动：\n%s", blockContent))
	case "refine":
		sb.WriteString(fmt.Sprintf("【任务】请对以下内容进行润色优化，提升文学表现力：\n%s", blockContent))
	case "continueWrite":
		if blockContent != "" {
			sb.WriteString(fmt.Sprintf("【任务】请续写以下内容，保持风格一致并推进剧情：\n%s", blockContent))
		} else {
			sb.WriteString("【任务】请根据上下文续写新的内容，保持风格一致并推进剧情。")
		}
	case "randomPrompt":
		hint := blockType
		if hint == "" || hint == "prompt" {
			hint = "通用画面描述"
		}
		if blockContent != "" {
			sb.WriteString(fmt.Sprintf("【任务】请基于以下内容，随机生成一段富有创意的提示词关键词（用于 %s 场景），风格多样、细节丰富，直接输出关键词用逗号分隔：\n%s", hint, blockContent))
		} else {
			sb.WriteString(fmt.Sprintf("【任务】请随机生成一段富有创意的提示词关键词（用于 %s 场景），风格多样、细节丰富，直接输出关键词用逗号分隔。", hint))
		}
	default:
		sb.WriteString(fmt.Sprintf("【任务】%s\n%s", action, blockContent))
	}

	return sb.String()
}

// GetScriptAssistSystemPrompt 返回脚本辅助系统 Prompt
func GetScriptAssistSystemPrompt() string {
	return scriptAssistSystemPrompt
}

// ── 分镜（Storyboard）生成 Prompt ──

const storyboardSystemPrompt = `你是一位专业的动漫分镜师 AI，擅长将剧本文本转化为结构化的分镜列表。

你的职责：
- 分析剧本的场景和内容块
- 将每个场景拆分为多个镜头（Shot）
- 为每个镜头指定合理的镜头语言

输出要求：
- 输出 JSON 数组，每个元素为一个镜头对象
- 镜头对象字段：
  - scene_id: 场景 ID（数字）
  - prompt: 画面描述（详细描述画面内容，供 AI 绘图用）
  - style_prompt: 风格提示词（如"日系动漫风格"）
  - camera_type: 镜头类型（close-up/medium/wide/extreme-wide/over-shoulder/pov/aerial）
  - camera_angle: 镜头角度（eye-level/low-angle/high-angle/dutch-angle/bird-eye）
  - dialogue: 该镜头中的台词（如无则为空字符串）
  - voice: 说话角色名（如无则为空字符串）
  - duration: 建议时长（秒，整数，2-8之间）
  - sort_index: 排序索引（从 0 开始递增）
  - character_name: 主要角色名（如无则为空字符串）
  - emotion: 情感基调（happy/sad/angry/fearful/neutral/excited/melancholy）
  - transition: 转场效果（cut/fade/dissolve/wipe，默认 cut）
  - negative_prompt: 负面提示词（要避免的元素）

规则：
- 每个场景至少生成 2 个镜头
- 动作描写适合用 medium 或 wide 镜头
- 台词场景适合用 close-up 或 medium 镜头
- 特写块用 close-up 镜头
- prompt 要详细具体，包含角色外貌、动作、场景背景等
- 只输出 JSON 数组，不要包含任何其他文本、markdown 代码块标记`

// BuildStoryboardUserPrompt 构建分镜生成的用户 Prompt
func BuildStoryboardUserPrompt(episodeTitle string, scenes []SceneForPrompt) string {
	var sb strings.Builder
	sb.WriteString(fmt.Sprintf("请为以下剧本内容生成分镜列表。\n\n集标题：%s\n\n", episodeTitle))

	for i, scene := range scenes {
		sb.WriteString(fmt.Sprintf("=== 场景 %d (ID: %d) ===\n", i+1, scene.ID))
		if scene.Location != "" {
			sb.WriteString(fmt.Sprintf("地点：%s\n", scene.Location))
		}
		if scene.Time != "" {
			sb.WriteString(fmt.Sprintf("时间：%s\n", scene.Time))
		}
		if scene.InteriorExterior != "" {
			sb.WriteString(fmt.Sprintf("内外景：%s\n", scene.InteriorExterior))
		}
		if len(scene.Characters) > 0 {
			sb.WriteString(fmt.Sprintf("角色：%s\n", strings.Join(scene.Characters, "、")))
		}
		sb.WriteString("\n内容块：\n")
		for _, block := range scene.Blocks {
			sb.WriteString(fmt.Sprintf("  [%s]", block.Type))
			if block.Character != "" {
				sb.WriteString(fmt.Sprintf(" (%s)", block.Character))
			}
			sb.WriteString(fmt.Sprintf(": %s\n", block.Content))
		}
		sb.WriteString("\n")
	}

	return sb.String()
}

// GetStoryboardSystemPrompt 返回分镜生成系统 Prompt
func GetStoryboardSystemPrompt() string {
	return storyboardSystemPrompt
}

// SceneForPrompt 用于构建分镜 Prompt 的场景数据
type SceneForPrompt struct {
	ID               uint
	Location         string
	Time             string
	InteriorExterior string
	Characters       []string
	Blocks           []BlockForPrompt
}

// BlockForPrompt 用于构建分镜 Prompt 的内容块数据
type BlockForPrompt struct {
	Type      string
	Character string
	Content   string
}
