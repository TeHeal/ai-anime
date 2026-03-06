package resource

import (
	"context"
	"encoding/json"

	"anime_ai/module/task"
)

// TaskSvcAdapter 将 task.Service 适配为 ResourceTaskCreator
type TaskSvcAdapter struct {
	svc *task.Service
}

// NewTaskSvcAdapter 创建适配器
func NewTaskSvcAdapter(svc *task.Service) *TaskSvcAdapter {
	return &TaskSvcAdapter{svc: svc}
}

// CreateTaskForUser 创建无 project 归属的 Task，返回 taskID
func (a *TaskSvcAdapter) CreateTaskForUser(ctx context.Context, userID, typ, title string, config json.RawMessage) (string, error) {
	dto, err := a.svc.CreateForUser(ctx, userID, typ, title, "", config)
	if err != nil {
		return "", err
	}
	return dto.ID, nil
}
