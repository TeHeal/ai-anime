package review

import (
	"testing"

	"go.uber.org/zap"
)

// newTestService 创建测试用的 Review Service（使用 MemReviewStore + nop logger）
func newTestService(t *testing.T) (*Service, *MemReviewStore) {
	t.Helper()
	store := NewMemReviewStore()
	logger := zap.NewNop()
	svc := NewService(store, logger)
	return svc, store
}

// setConfig 设置审核配置的辅助方法
func setConfig(t *testing.T, store *MemReviewStore, projectID, phase, mode string) {
	t.Helper()
	_, err := store.UpsertConfig(&ReviewConfig{
		ProjectID: projectID,
		Phase:     phase,
		Mode:      mode,
	})
	if err != nil {
		t.Fatalf("设置审核配置失败: %v", err)
	}
}

// TestSubmitForReview_AIMode 测试 AI 模式提交审核后状态为 ai_reviewing
func TestSubmitForReview_AIMode(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeAI)

	record, err := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script",
		TargetID:   "s1",
		Phase:      PhaseScript,
	})
	if err != nil {
		t.Fatalf("提交审核应成功: %v", err)
	}
	if record.Status != StatusAIReviewing {
		t.Errorf("AI 模式状态应为 %s，实际: %s", StatusAIReviewing, record.Status)
	}
	if record.ReviewerType != ReviewerAI {
		t.Errorf("审核者类型应为 %s，实际: %s", ReviewerAI, record.ReviewerType)
	}
}

// TestSubmitForReview_HumanMode 测试人工模式提交审核后状态为 human_review
func TestSubmitForReview_HumanMode(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeHuman)

	record, err := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script",
		TargetID:   "s1",
		Phase:      PhaseScript,
	})
	if err != nil {
		t.Fatalf("提交审核应成功: %v", err)
	}
	if record.Status != StatusHumanReview {
		t.Errorf("人工模式状态应为 %s，实际: %s", StatusHumanReview, record.Status)
	}
	if record.ReviewerType != ReviewerHuman {
		t.Errorf("审核者类型应为 %s，实际: %s", ReviewerHuman, record.ReviewerType)
	}
}

// TestSubmitForReview_RoundIncrement 测试多次提交审核轮次递增
func TestSubmitForReview_RoundIncrement(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeAI)

	r1, _ := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script", TargetID: "s1", Phase: PhaseScript,
	})
	if r1.Round != 1 {
		t.Errorf("第一轮应为 1，实际: %d", r1.Round)
	}

	r2, _ := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script", TargetID: "s1", Phase: PhaseScript,
	})
	if r2.Round != 2 {
		t.Errorf("第二轮应为 2，实际: %d", r2.Round)
	}
}

// TestAIDecide_Approved 测试 AI 审核通过后状态变为 approved
func TestAIDecide_Approved(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeAI)

	record, _ := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script", TargetID: "s1", Phase: PhaseScript,
	})

	err := svc.AIDecide(record.ID, 90, "质量优秀", true)
	if err != nil {
		t.Fatalf("AI 审核通过应成功: %v", err)
	}

	updated, _ := svc.GetRecord(record.ID)
	if updated.Status != StatusApproved {
		t.Errorf("AI 通过后状态应为 %s，实际: %s", StatusApproved, updated.Status)
	}
}

// TestAIDecide_RejectedInHumanAI 测试人工+AI模式下AI拒绝后转人工审核
func TestAIDecide_RejectedInHumanAI(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeHumanAI)

	record, _ := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script", TargetID: "s1", Phase: PhaseScript,
	})

	err := svc.AIDecide(record.ID, 30, "质量不达标", false)
	if err != nil {
		t.Fatalf("AI 拒绝应成功: %v", err)
	}

	updated, _ := svc.GetRecord(record.ID)
	if updated.Status != StatusHumanReview {
		t.Errorf("人工+AI 模式下 AI 拒绝后应转 %s，实际: %s", StatusHumanReview, updated.Status)
	}
}

// TestAIDecide_RejectedInAIOnly 测试纯AI模式下AI拒绝后状态为rejected
func TestAIDecide_RejectedInAIOnly(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeAI)

	record, _ := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script", TargetID: "s1", Phase: PhaseScript,
	})

	err := svc.AIDecide(record.ID, 20, "不合格", false)
	if err != nil {
		t.Fatalf("AI 拒绝应成功: %v", err)
	}

	updated, _ := svc.GetRecord(record.ID)
	if updated.Status != StatusRejected {
		t.Errorf("纯AI模式下拒绝后应为 %s，实际: %s", StatusRejected, updated.Status)
	}
}

// TestHumanDecide_Approved 测试人工审核通过
func TestHumanDecide_Approved(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeHuman)

	record, _ := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script", TargetID: "s1", Phase: PhaseScript,
	})

	err := svc.HumanDecide(record.ID, "reviewer1", DecideReviewRequest{
		Status:  StatusApproved,
		Comment: "审核通过",
	})
	if err != nil {
		t.Fatalf("人工审核通过应成功: %v", err)
	}

	updated, _ := svc.GetRecord(record.ID)
	if updated.Status != StatusApproved {
		t.Errorf("人工审核通过后应为 %s，实际: %s", StatusApproved, updated.Status)
	}
}

// TestHumanDecide_WrongStatus 测试在非人工审核状态下执行人工审核应失败
func TestHumanDecide_WrongStatus(t *testing.T) {
	svc, store := newTestService(t)
	setConfig(t, store, "proj1", PhaseScript, ModeAI)

	// AI 模式提交后状态为 ai_reviewing，不允许人工审核
	record, _ := svc.SubmitForReview("proj1", SubmitReviewRequest{
		TargetType: "script", TargetID: "s1", Phase: PhaseScript,
	})

	err := svc.HumanDecide(record.ID, "reviewer1", DecideReviewRequest{
		Status:  StatusApproved,
		Comment: "尝试越权审核",
	})
	if err == nil {
		t.Fatal("非人工审核状态下执行人工审核应返回错误")
	}
}

// TestUpdateConfig_InvalidMode 测试更新配置时传入无效模式应失败
func TestUpdateConfig_InvalidMode(t *testing.T) {
	svc, _ := newTestService(t)

	_, err := svc.UpdateConfig("proj1", UpdateConfigRequest{
		Phase: PhaseScript,
		Mode:  "invalid_mode",
	})
	if err == nil {
		t.Fatal("无效审核模式应返回错误")
	}
}

// TestUpdateConfig_ValidModes 测试合法模式更新配置成功
func TestUpdateConfig_ValidModes(t *testing.T) {
	cases := []struct {
		name string
		mode string
	}{
		{"AI模式", ModeAI},
		{"人工模式", ModeHuman},
		{"人工+AI模式", ModeHumanAI},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			svc, _ := newTestService(t)
			cfg, err := svc.UpdateConfig("proj1", UpdateConfigRequest{
				Phase: PhaseScript,
				Mode:  tc.mode,
			})
			if err != nil {
				t.Fatalf("合法模式 %s 更新应成功: %v", tc.mode, err)
			}
			if cfg.Mode != tc.mode {
				t.Errorf("配置模式应为 %s，实际: %s", tc.mode, cfg.Mode)
			}
		})
	}
}
