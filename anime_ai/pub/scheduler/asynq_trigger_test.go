package scheduler

import (
	"encoding/json"
	"testing"

	"anime_ai/pub/crossmodule"
	"anime_ai/pub/tasktypes"
)

func TestBuildPayload(t *testing.T) {
	sch := &crossmodule.ScheduleInfo{
		ID:        "sch-001",
		ProjectID: "proj-001",
		UserID:    "user-001",
		Action:    "batch_image",
		Config:    []byte(`{"prompt":"test prompt","width":1024}`),
	}

	data, err := buildPayload(sch)
	if err != nil {
		t.Fatalf("buildPayload 失败: %v", err)
	}

	var m map[string]interface{}
	if err := json.Unmarshal(data, &m); err != nil {
		t.Fatalf("反序列化 payload 失败: %v", err)
	}

	if m["schedule_id"] != "sch-001" {
		t.Errorf("schedule_id = %v, want sch-001", m["schedule_id"])
	}
	if m["project_id"] != "proj-001" {
		t.Errorf("project_id = %v, want proj-001", m["project_id"])
	}
	if m["user_id"] != "user-001" {
		t.Errorf("user_id = %v, want user-001", m["user_id"])
	}
	if m["prompt"] != "test prompt" {
		t.Errorf("prompt = %v, want 'test prompt'", m["prompt"])
	}
	if m["width"] != float64(1024) {
		t.Errorf("width = %v, want 1024", m["width"])
	}
}

func TestBuildPayloadBaseFieldsOverrideConfig(t *testing.T) {
	sch := &crossmodule.ScheduleInfo{
		ID:        "sch-002",
		ProjectID: "proj-real",
		UserID:    "user-real",
		Action:    "export",
		Config:    []byte(`{"project_id":"proj-fake","extra":"val"}`),
	}

	data, err := buildPayload(sch)
	if err != nil {
		t.Fatalf("buildPayload 失败: %v", err)
	}

	var m map[string]interface{}
	_ = json.Unmarshal(data, &m)

	if m["project_id"] != "proj-real" {
		t.Errorf("基础字段应优先: project_id = %v, want proj-real", m["project_id"])
	}
	if m["extra"] != "val" {
		t.Errorf("config 额外字段应保留: extra = %v, want val", m["extra"])
	}
}

func TestBuildPayloadEmptyConfig(t *testing.T) {
	sch := &crossmodule.ScheduleInfo{
		ID:        "sch-003",
		ProjectID: "proj-003",
		UserID:    "user-003",
		Action:    "pipeline",
	}

	data, err := buildPayload(sch)
	if err != nil {
		t.Fatalf("buildPayload 失败: %v", err)
	}

	var m map[string]interface{}
	_ = json.Unmarshal(data, &m)

	if len(m) != 3 {
		t.Errorf("空 config 时 payload 应只有 3 个字段, got %d: %v", len(m), m)
	}
}

func TestActionTaskTypeMapping(t *testing.T) {
	tests := []struct {
		action   string
		wantType string
		wantOK   bool
	}{
		{"pipeline", tasktypes.TypeStoryboardGenerate, true},
		{"batch_image", tasktypes.TypeImageGeneration, true},
		{"batch_video", tasktypes.TypeVideoGeneration, true},
		{"export", tasktypes.TypeExport, true},
		{"unknown", "", false},
	}

	for _, tt := range tests {
		got, ok := actionTaskType[tt.action]
		if ok != tt.wantOK {
			t.Errorf("actionTaskType[%q] ok = %v, want %v", tt.action, ok, tt.wantOK)
		}
		if got != tt.wantType {
			t.Errorf("actionTaskType[%q] = %q, want %q", tt.action, got, tt.wantType)
		}
	}
}
