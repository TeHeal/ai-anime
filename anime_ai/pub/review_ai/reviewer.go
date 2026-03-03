// Package review_ai 实现基于 LLM 的 AI 审核（README 2.2 双线 AI 审核）
package review_ai

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"anime_ai/pub/provider/llm"
)

const reviewSystemPrompt = `你是一位专业的动漫分镜镜图质量审核员。
你需要根据以下标准审核镜图（AI 生成的动漫风格分镜图片）：

审核标准：
1. 画面完整性：人物是否完整呈现，没有明显截断或缺失
2. 构图合理性：画面构图是否合理，主体是否突出
3. 风格一致性：是否符合动漫/漫画分镜的艺术风格
4. 内容相关性：画面是否与提供的描述 prompt 相符
5. 技术质量：是否存在明显的 AI 生成瑕疵（如多余手指、面部畸变等）

请以 JSON 格式输出审核结果，字段如下：
{
  "approved": true/false,
  "score": 1-10,
  "feedback": "具体反馈意见",
  "issues": ["问题1", "问题2"]
}

只输出 JSON，不要包含其他文本或 markdown 代码块标记。`

// reviewResult AI 审核 JSON 响应
type reviewResult struct {
	Approved bool     `json:"approved"`
	Score    int      `json:"score"`
	Feedback string   `json:"feedback"`
	Issues   []string `json:"issues"`
}

// LLMReviewer 基于 LLM 的 AI 审核实现
type LLMReviewer struct {
	llmSvc *llm.LLMService
}

// NewLLMReviewer 创建 LLM 审核器
func NewLLMReviewer(llmSvc *llm.LLMService) *LLMReviewer {
	return &LLMReviewer{llmSvc: llmSvc}
}

// ReviewImage 审核镜图质量（实现 shot_image.AIReviewer 接口）
func (r *LLMReviewer) ReviewImage(ctx context.Context, imageURL, projectID, prompt string) (approved bool, comment string, err error) {
	if r.llmSvc == nil || !r.llmSvc.Available() {
		return false, "", fmt.Errorf("LLM 服务不可用")
	}

	userPrompt := buildReviewUserPrompt(imageURL, prompt)
	result, err := r.llmSvc.ChatWithJSON(ctx, reviewSystemPrompt, userPrompt)
	if err != nil {
		return false, "", fmt.Errorf("LLM 审核调用失败: %w", err)
	}

	var res reviewResult
	cleaned := cleanJSONResponse(result)
	if err := json.Unmarshal([]byte(cleaned), &res); err != nil {
		return false, result, fmt.Errorf("解析审核结果失败: %w", err)
	}

	comment = res.Feedback
	if len(res.Issues) > 0 {
		comment += " | 问题: " + strings.Join(res.Issues, "; ")
	}
	comment += fmt.Sprintf(" (评分: %d/10)", res.Score)

	return res.Approved, comment, nil
}

func buildReviewUserPrompt(imageURL, prompt string) string {
	var sb strings.Builder
	sb.WriteString("请审核以下镜图：\n\n")
	if imageURL != "" {
		sb.WriteString(fmt.Sprintf("图片地址：%s\n", imageURL))
	}
	if prompt != "" {
		sb.WriteString(fmt.Sprintf("生成提示词：%s\n", prompt))
	}
	if imageURL == "" && prompt == "" {
		sb.WriteString("（无额外信息，请基于通用动漫分镜标准给出评估）\n")
	}
	sb.WriteString("\n请按审核标准评估并给出 JSON 格式的结果。")
	return sb.String()
}

// cleanJSONResponse 清理 LLM 返回中可能包含的 markdown 代码块标记
func cleanJSONResponse(raw string) string {
	s := strings.TrimSpace(raw)
	s = strings.TrimPrefix(s, "```json")
	s = strings.TrimPrefix(s, "```")
	s = strings.TrimSuffix(s, "```")
	return strings.TrimSpace(s)
}
