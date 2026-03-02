package ffmpeg

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestFormatSRTTime(t *testing.T) {
	tests := []struct {
		ms   int64
		want string
	}{
		{0, "00:00:00,000"},
		{1500, "00:00:01,500"},
		{61000, "00:01:01,000"},
		{3661500, "01:01:01,500"},
		{-100, "00:00:00,000"},
	}
	for _, tt := range tests {
		got := formatSRTTime(tt.ms)
		if got != tt.want {
			t.Errorf("formatSRTTime(%d) = %q, want %q", tt.ms, got, tt.want)
		}
	}
}

func TestFormatASSTime(t *testing.T) {
	tests := []struct {
		ms   int64
		want string
	}{
		{0, "0:00:00.00"},
		{1500, "0:00:01.50"},
		{61000, "0:01:01.00"},
		{3661500, "1:01:01.50"},
	}
	for _, tt := range tests {
		got := formatASSTime(tt.ms)
		if got != tt.want {
			t.Errorf("formatASSTime(%d) = %q, want %q", tt.ms, got, tt.want)
		}
	}
}

func TestGenerateSRT(t *testing.T) {
	tmpDir := t.TempDir()
	outPath := filepath.Join(tmpDir, "test.srt")

	items := []SubtitleItem{
		{Index: 1, StartMs: 0, EndMs: 3000, Character: "小明", Text: "你好世界"},
		{Index: 2, StartMs: 3000, EndMs: 6000, Text: "旁白文字"},
	}

	if err := GenerateSRT(items, outPath); err != nil {
		t.Fatalf("GenerateSRT failed: %v", err)
	}

	data, err := os.ReadFile(outPath)
	if err != nil {
		t.Fatalf("read file: %v", err)
	}
	content := string(data)

	if !strings.Contains(content, "小明: 你好世界") {
		t.Error("SRT 应包含角色名前缀")
	}
	if !strings.Contains(content, "00:00:00,000 --> 00:00:03,000") {
		t.Error("SRT 应包含正确的时间戳")
	}
	if !strings.Contains(content, "旁白文字") {
		t.Error("SRT 应包含无角色名的文字")
	}
}

func TestGenerateSRT_Empty(t *testing.T) {
	if err := GenerateSRT(nil, "/dev/null"); err == nil {
		t.Error("空条目应返回错误")
	}
}

func TestGenerateASS(t *testing.T) {
	tmpDir := t.TempDir()
	outPath := filepath.Join(tmpDir, "test.ass")

	items := []SubtitleItem{
		{Index: 1, StartMs: 0, EndMs: 3000, Character: "小明", Text: "你好世界"},
		{Index: 2, StartMs: 3000, EndMs: 6000, Text: "旁白"},
	}

	if err := GenerateASS(items, outPath); err != nil {
		t.Fatalf("GenerateASS failed: %v", err)
	}

	data, err := os.ReadFile(outPath)
	if err != nil {
		t.Fatalf("read file: %v", err)
	}
	content := string(data)

	if !strings.Contains(content, "[Script Info]") {
		t.Error("ASS 应包含 Script Info 段")
	}
	if !strings.Contains(content, "[V4+ Styles]") {
		t.Error("ASS 应包含样式定义")
	}
	if !strings.Contains(content, "[Events]") {
		t.Error("ASS 应包含事件段")
	}
	if !strings.Contains(content, "Dialogue:") {
		t.Error("ASS 应包含对话行")
	}
	if !strings.Contains(content, "小明") {
		t.Error("ASS 应包含角色名")
	}
}

func TestEscapeASSText(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{"hello", "hello"},
		{"line1\nline2", "line1\\Nline2"},
		{"back\\slash", "back\\\\slash"},
	}
	for _, tt := range tests {
		got := escapeASSText(tt.input)
		if got != tt.want {
			t.Errorf("escapeASSText(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}
