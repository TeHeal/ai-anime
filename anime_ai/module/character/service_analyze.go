package character

import "context"

// AnalyzeRequest 角色分析请求
type AnalyzeRequest struct {
	SceneIDs []string `json:"scene_ids"`
}

// AnalyzePreview 分析预览（占位）
func (s *Service) AnalyzePreview(ctx context.Context, projectID, userID uint, req AnalyzeRequest) (interface{}, error) {
	_ = ctx
	_ = projectID
	_ = userID
	_ = req
	return map[string]interface{}{
		"preview": true,
		"message": "角色分析预览占位，待接入 LLM",
	}, nil
}

// AnalyzeConfirm 分析确认（占位）
func (s *Service) AnalyzeConfirm(ctx context.Context, projectID, userID uint, req AnalyzeRequest) (interface{}, error) {
	_ = ctx
	_ = projectID
	_ = userID
	_ = req
	return map[string]interface{}{
		"confirmed": true,
		"message":   "角色分析确认占位，待接入 LLM",
	}, nil
}
