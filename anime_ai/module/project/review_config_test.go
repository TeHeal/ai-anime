package project

import (
	"testing"
)

func TestReviewConfig_Default(t *testing.T) {
	p := &Project{}
	cfg := p.GetReviewConfig()
	if cfg.Script.Mode != ReviewModeHumanOnly {
		t.Errorf("默认 Script 审核模式应为 human_only, 得 %s", cfg.Script.Mode)
	}
	if cfg.ShotImage.Mode != ReviewModeHumanOnly {
		t.Errorf("默认 ShotImage 审核模式应为 human_only, 得 %s", cfg.ShotImage.Mode)
	}
	if cfg.ShotVideo.Mode != ReviewModeHumanOnly {
		t.Errorf("默认 ShotVideo 审核模式应为 human_only, 得 %s", cfg.ShotVideo.Mode)
	}
}

func TestReviewConfig_SetAndGet(t *testing.T) {
	p := &Project{}
	cfg := ReviewConfig{
		Script:    StageReviewConfig{Mode: ReviewModeAIOnly, AIModel: "deepseek"},
		ShotImage: StageReviewConfig{Mode: ReviewModeHumanAI},
		ShotVideo: StageReviewConfig{Mode: ReviewModeHumanOnly},
	}
	p.SetReviewConfig(cfg)

	got := p.GetReviewConfig()
	if got.Script.Mode != ReviewModeAIOnly {
		t.Errorf("Script 审核模式应为 ai_only, 得 %s", got.Script.Mode)
	}
	if got.Script.AIModel != "deepseek" {
		t.Errorf("Script AI 模型应为 deepseek, 得 %s", got.Script.AIModel)
	}
	if got.ShotImage.Mode != ReviewModeHumanAI {
		t.Errorf("ShotImage 审核模式应为 human_and_ai, 得 %s", got.ShotImage.Mode)
	}
}

func TestReviewConfig_PreservesOtherProps(t *testing.T) {
	p := &Project{PropsJSON: `{"someOther": "value"}`}
	cfg := ReviewConfig{
		Script:    StageReviewConfig{Mode: ReviewModeAIOnly},
		ShotImage: StageReviewConfig{Mode: ReviewModeHumanOnly},
		ShotVideo: StageReviewConfig{Mode: ReviewModeHumanOnly},
	}
	p.SetReviewConfig(cfg)

	got := p.GetReviewConfig()
	if got.Script.Mode != ReviewModeAIOnly {
		t.Errorf("Script 审核模式应为 ai_only, 得 %s", got.Script.Mode)
	}
}

func TestValidReviewMode(t *testing.T) {
	tests := []struct {
		mode  string
		valid bool
	}{
		{ReviewModeHumanOnly, true},
		{ReviewModeAIOnly, true},
		{ReviewModeHumanAI, true},
		{"invalid", false},
		{"", false},
	}
	for _, tt := range tests {
		if got := ValidReviewMode(tt.mode); got != tt.valid {
			t.Errorf("ValidReviewMode(%q) = %v, want %v", tt.mode, got, tt.valid)
		}
	}
}

func TestService_GetReviewConfig(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, err := svc.Create("user1", CreateProjectRequest{Name: "测试项目"})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}

	cfg, err := svc.GetReviewConfig(p.IDStr, "user1")
	if err != nil {
		t.Fatalf("GetReviewConfig 失败: %v", err)
	}
	if cfg.Script.Mode != ReviewModeHumanOnly {
		t.Errorf("默认 Script 审核模式应为 human_only, 得 %s", cfg.Script.Mode)
	}
}

func TestService_UpdateReviewConfig(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, err := svc.Create("user1", CreateProjectRequest{Name: "测试项目"})
	if err != nil {
		t.Fatalf("Create 失败: %v", err)
	}

	aiScript := &StageReviewConfig{Mode: ReviewModeAIOnly, AIModel: "deepseek"}
	cfg, err := svc.UpdateReviewConfig(p.IDStr, "user1", UpdateReviewConfigRequest{
		Script: aiScript,
	})
	if err != nil {
		t.Fatalf("UpdateReviewConfig 失败: %v", err)
	}
	if cfg.Script.Mode != ReviewModeAIOnly {
		t.Errorf("Script 审核模式应为 ai_only, 得 %s", cfg.Script.Mode)
	}
	if cfg.ShotImage.Mode != ReviewModeHumanOnly {
		t.Errorf("ShotImage 审核模式应保持 human_only, 得 %s", cfg.ShotImage.Mode)
	}

	retrieved, err := svc.GetReviewConfig(p.IDStr, "user1")
	if err != nil {
		t.Fatalf("GetReviewConfig 失败: %v", err)
	}
	if retrieved.Script.Mode != ReviewModeAIOnly {
		t.Errorf("持久化后 Script 审核模式应为 ai_only, 得 %s", retrieved.Script.Mode)
	}
}

func TestService_UpdateReviewConfig_InvalidMode(t *testing.T) {
	data := NewMemData()
	svc := NewService(data)

	p, _ := svc.Create("user1", CreateProjectRequest{Name: "测试项目"})
	invalid := &StageReviewConfig{Mode: "invalid_mode"}
	_, err := svc.UpdateReviewConfig(p.IDStr, "user1", UpdateReviewConfigRequest{
		Script: invalid,
	})
	if err == nil {
		t.Fatal("无效模式应返回错误")
	}
}
