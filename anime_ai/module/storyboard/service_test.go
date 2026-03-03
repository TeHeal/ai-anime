package storyboard

import (
	"testing"

	"github.com/TeHeal/ai-anime/anime_ai/module/project"
)

// noopVerifier 占位实现，始终通过验证
type noopVerifier struct{}

func (noopVerifier) Verify(projectID, userID string) error { return nil }

func TestStoryboardService_List(t *testing.T) {
	projectData := project.NewMemData()
	p := &project.Project{UserIDStr: "user1", Name: "测试"}
	_ = projectData.CreateProject(p)
	projectID := p.IDStr

	access := project.NewStoryboardAccess(projectData)
	data := NewMemData(access)
	svc := NewService(data, noopVerifier{})

	list, err := svc.List(projectID, "user1")
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if list == nil {
		t.Error("List 应返回非 nil 切片")
	}
	if len(list) != 0 {
		t.Errorf("空项目分镜列表应为 0, 得 %d", len(list))
	}
}

func TestStoryboardService_SaveAndList(t *testing.T) {
	projectData := project.NewMemData()
	// 需先有项目，StoryboardAccess 才能读写
	p := &project.Project{UserIDStr: "user1", Name: "测试"}
	_ = projectData.CreateProject(p)
	projectID := p.IDStr

	access := project.NewStoryboardAccess(projectData)
	data := NewMemData(access)
	svc := NewService(data, noopVerifier{})

	shots := []ShotItem{
		{SceneID: 1, Prompt: "镜头1", SortIndex: 0},
		{SceneID: 1, Prompt: "镜头2", SortIndex: 1},
	}
	_, err := svc.Confirm(projectID, "user1", ConfirmRequest{Shots: shots})
	if err != nil {
		t.Fatalf("Confirm 失败: %v", err)
	}

	list, err := svc.List(projectID, "user1")
	if err != nil {
		t.Fatalf("List 失败: %v", err)
	}
	if len(list) != 2 {
		t.Errorf("应有 2 个分镜, 得 %d", len(list))
	}
}
