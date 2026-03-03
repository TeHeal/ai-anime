package parser

import (
	"regexp"
	"strings"
)

// Preprocess 预处理原始剧本文本：去除 BOM/零宽字符、规范化标点、合并粗体碎片、压缩空行等
func Preprocess(raw string) string {
	text := raw

	// 1. 去除 UTF-8 BOM 与零宽字符
	text = strings.TrimPrefix(text, "\xef\xbb\xbf")
	text = strings.NewReplacer(
		"\u200b", "",
		"\u200c", "",
		"\u200d", "",
		"\ufeff", "",
	).Replace(text)

	// 2. 合并粗体碎片：**第****71****集** → **第71集**
	text = mergeBoldFragments(text)

	// 3. 标点规范化为全角中文
	text = strings.NewReplacer(
		":", "：",
		",", "，",
		";", "；",
		"(", "（",
		")", "）",
	).Replace(text)

	// 4. 对白行常见笔误：分号当冒号
	text = fixSemicolonInDialogue(text)

	// 5. 合并连续空行
	text = collapseBlankLines(text)

	// 6. 每行去除尾部空白
	text = trimTrailingSpaces(text)

	return text
}

func mergeBoldFragments(text string) string {
	lines := strings.Split(text, "\n")
	for i, line := range lines {
		if !strings.Contains(line, "**") {
			continue
		}
		count := strings.Count(line, "**")
		if count <= 2 {
			continue
		}
		stripped := strings.ReplaceAll(line, "**", "")
		trimmed := strings.TrimSpace(stripped)
		if trimmed == "" {
			lines[i] = ""
			continue
		}
		lt := strings.TrimSpace(line)
		if strings.HasPrefix(lt, "**") && strings.HasSuffix(lt, "**") {
			lines[i] = "**" + trimmed + "**"
		} else if strings.HasPrefix(lt, "**") {
			lines[i] = "**" + trimmed
		} else {
			lines[i] = trimmed
		}
	}
	return strings.Join(lines, "\n")
}

var reDialogueSemicolon = regexp.MustCompile(`^([^\s△●【\*].+?)；\s*`)

func fixSemicolonInDialogue(text string) string {
	lines := strings.Split(text, "\n")
	for i, line := range lines {
		if reDialogueSemicolon.MatchString(line) {
			lines[i] = strings.Replace(line, "；", "：", 1)
		}
	}
	return strings.Join(lines, "\n")
}

func collapseBlankLines(text string) string {
	var b strings.Builder
	lines := strings.Split(text, "\n")
	prevBlank := false
	for _, line := range lines {
		isBlank := strings.TrimSpace(line) == ""
		if isBlank {
			if !prevBlank {
				b.WriteString("\n")
			}
			prevBlank = true
			continue
		}
		prevBlank = false
		b.WriteString(line)
		b.WriteString("\n")
	}
	return strings.TrimRight(b.String(), "\n")
}

func trimTrailingSpaces(text string) string {
	lines := strings.Split(text, "\n")
	for i, line := range lines {
		lines[i] = strings.TrimRight(line, " \t\r")
	}
	return strings.Join(lines, "\n")
}
