package ffmpeg

import (
	"fmt"
	"os"
	"strings"
)

// SubtitleItem 字幕条目
type SubtitleItem struct {
	Index     int    // 序号
	StartMs   int64  // 开始时间（毫秒）
	EndMs     int64  // 结束时间（毫秒）
	Character string // 角色名（可选）
	Text      string // 字幕文本
}

// GenerateSRT 生成 SRT 格式字幕文件
func GenerateSRT(items []SubtitleItem, outputPath string) error {
	if len(items) == 0 {
		return fmt.Errorf("字幕条目为空")
	}

	var sb strings.Builder
	for i, item := range items {
		idx := item.Index
		if idx <= 0 {
			idx = i + 1
		}

		text := item.Text
		if item.Character != "" {
			text = item.Character + ": " + text
		}

		sb.WriteString(fmt.Sprintf("%d\n", idx))
		sb.WriteString(fmt.Sprintf("%s --> %s\n", formatSRTTime(item.StartMs), formatSRTTime(item.EndMs)))
		sb.WriteString(text + "\n\n")
	}

	return os.WriteFile(outputPath, []byte(sb.String()), 0o644)
}

// GenerateASS 生成 ASS 格式字幕文件（动漫风格）
func GenerateASS(items []SubtitleItem, outputPath string) error {
	if len(items) == 0 {
		return fmt.Errorf("字幕条目为空")
	}

	var sb strings.Builder

	// ASS 文件头
	sb.WriteString("[Script Info]\n")
	sb.WriteString("Title: AI-Anime Composite Subtitles\n")
	sb.WriteString("ScriptType: v4.00+\n")
	sb.WriteString("PlayResX: 1920\n")
	sb.WriteString("PlayResY: 1080\n")
	sb.WriteString("WrapStyle: 0\n")
	sb.WriteString("\n")

	// 样式定义（动漫风格：白字黑边、半透明深色底栏）
	sb.WriteString("[V4+ Styles]\n")
	sb.WriteString("Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n")
	// 默认样式：白字、黑色描边、半透明暗背景
	sb.WriteString("Style: Default,Arial,48,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,3,2,0,2,20,20,40,1\n")
	// 角色名样式：稍小、黄色
	sb.WriteString("Style: CharName,Arial,40,&H0000FFFF,&H000000FF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,3,2,0,2,20,20,40,1\n")
	sb.WriteString("\n")

	// 事件（对话行）
	sb.WriteString("[Events]\n")
	sb.WriteString("Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n")

	for _, item := range items {
		startTime := formatASSTime(item.StartMs)
		endTime := formatASSTime(item.EndMs)

		text := escapeASSText(item.Text)
		if item.Character != "" {
			// 角色名使用特殊样式前缀
			charTag := fmt.Sprintf("{\\rCharName}%s: {\\rDefault}", escapeASSText(item.Character))
			text = charTag + text
		}

		sb.WriteString(fmt.Sprintf("Dialogue: 0,%s,%s,Default,,0,0,0,,%s\n",
			startTime, endTime, text))
	}

	return os.WriteFile(outputPath, []byte(sb.String()), 0o644)
}

// formatSRTTime 将毫秒转为 SRT 时间格式 HH:MM:SS,mmm
func formatSRTTime(ms int64) string {
	if ms < 0 {
		ms = 0
	}
	h := ms / 3600000
	ms %= 3600000
	m := ms / 60000
	ms %= 60000
	s := ms / 1000
	ms %= 1000
	return fmt.Sprintf("%02d:%02d:%02d,%03d", h, m, s, ms)
}

// formatASSTime 将毫秒转为 ASS 时间格式 H:MM:SS.cc（百分秒）
func formatASSTime(ms int64) string {
	if ms < 0 {
		ms = 0
	}
	h := ms / 3600000
	ms %= 3600000
	m := ms / 60000
	ms %= 60000
	s := ms / 1000
	cs := (ms % 1000) / 10
	return fmt.Sprintf("%d:%02d:%02d.%02d", h, m, s, cs)
}

// escapeASSText 转义 ASS 文本中的特殊字符
func escapeASSText(text string) string {
	text = strings.ReplaceAll(text, "\\", "\\\\")
	text = strings.ReplaceAll(text, "\n", "\\N")
	return text
}
