package shot_image

import (
	"encoding/json"
	"fmt"

	"github.com/TeHeal/ai-anime/anime_ai/pub/tasktypes"
	"github.com/google/uuid"
	"github.com/hibiken/asynq"
)

// triggerRegeneration 审核拒绝后自动发起重新生成任务（README 2.2 审核闭环）
// 将拒绝原因追加到原始提示词中，引导 AI 改进生成结果
func (s *Service) triggerRegeneration(shotID, projectID, userID, feedback string) error {
	if s.asynqClient == nil {
		return fmt.Errorf("Asynq 客户端未配置，无法入队重生成任务")
	}
	if s.shotReader == nil {
		return fmt.Errorf("shot reader 未配置")
	}

	// 读取原始镜头提示词
	prompt, negPrompt, err := s.shotReader.GetShotPrompt(shotID)
	if err != nil {
		return fmt.Errorf("获取镜头提示词失败: %w", err)
	}

	// 将拒绝反馈融入提示词
	if feedback != "" {
		prompt = prompt + "\n修改要求: " + feedback
	}

	if prompt == "" {
		prompt = "anime style illustration, high quality"
	}

	taskID := uuid.New().String()
	payload := map[string]interface{}{
		"task_id":         taskID,
		"shot_image_id":   "",
		"provider":        "",
		"model":           "",
		"prompt":          prompt,
		"negative_prompt": negPrompt,
		"project_id":      projectID,
		"user_id":         userID,
		"shot_id":         shotID,
	}
	payloadBytes, _ := json.Marshal(payload)
	task := asynq.NewTask(tasktypes.TypeImageGeneration, payloadBytes)
	if _, err := s.asynqClient.Enqueue(task); err != nil {
		return fmt.Errorf("入队重生成任务失败: %w", err)
	}

	return nil
}

// shouldAutoRetry 判断是否应该自动重试（根据审核模式）
func (s *Service) shouldAutoRetry(projectID string) bool {
	mode := s.getReviewMode(projectID)
	return mode == "ai_only" || mode == "human_and_ai"
}
