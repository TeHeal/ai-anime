package parser

import (
	"fmt"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

var (
	reTitle        = regexp.MustCompile(`^\*{0,2}《(.+?)》\*{0,2}$`)
	reEpisode      = regexp.MustCompile(`^\*{0,2}第\s*(\d+)\s*集\*{0,2}$`)
	reSceneHeader  = regexp.MustCompile(
		`^\*{0,2}(\d+)\s*[-—]\s*(\d+)\s*` +
			`(日|夜|黄昏|凌晨|晨|傍晚|清晨|午|深夜)\s*[，,]\s*` +
			`(内|外)\s*[，,]\s*` +
			`(.+?)\s*\*{0,2}$`,
	)
	reCharacters = regexp.MustCompile(`^\*{0,2}人物[：:]\s*(.+?)\s*\*{0,2}$`)
	reAction     = regexp.MustCompile(`^△\s*(.+)`)
	reOS         = regexp.MustCompile(`^(.+?)[Oo][Ss]\s*[：:]\s*(.+)`)
	reCloseup    = regexp.MustCompile(`^●\s*特写\s*[：:]\s*(.+)`)
	reDirection  = regexp.MustCompile(`^【导演】\s*(.+)`)
	reDialogue   = regexp.MustCompile(`^([^\s△●【\*][^：:]*?)[：:]\s*(.+)`)
	reEmotion    = regexp.MustCompile(`^[（(]([^）)]+)[）)]\s*(.*)`)
	reCharSplit  = regexp.MustCompile(`[，,、]+`)
)

// RegexParse 使用正则规则解析预处理后的文本，返回 ParsedScript
func RegexParse(text string) *ParsedScript {
	lines := strings.Split(text, "\n")
	result := &ParsedScript{
		Episodes: []ParsedEpisode{},
	}

	var currentEpisode *ParsedEpisode
	var currentScene *ParsedScene
	totalContent := 0
	recognized := 0

	for lineIdx, rawLine := range lines {
		lineNum := lineIdx + 1
		line := strings.TrimSpace(rawLine)
		if line == "" {
			continue
		}
		totalContent++

		if m := reTitle.FindStringSubmatch(line); m != nil {
			result.Title = m[1]
			recognized++
			continue
		}

		if m := reEpisode.FindStringSubmatch(line); m != nil {
			epNum, _ := strconv.Atoi(m[1])
			result.Episodes = append(result.Episodes, ParsedEpisode{
				EpisodeNum: epNum,
				Scenes:     []ParsedScene{},
			})
			currentEpisode = &result.Episodes[len(result.Episodes)-1]
			currentScene = nil
			recognized++
			continue
		}

		if m := reSceneHeader.FindStringSubmatch(line); m != nil {
			if currentEpisode == nil {
				result.Episodes = append(result.Episodes, ParsedEpisode{
					EpisodeNum: 1,
					Scenes:     []ParsedScene{},
				})
				currentEpisode = &result.Episodes[len(result.Episodes)-1]
			}
			sceneNum := fmt.Sprintf("%s-%s", m[1], m[2])
			currentEpisode.Scenes = append(currentEpisode.Scenes, ParsedScene{
				SceneNum:   sceneNum,
				Time:       m[3],
				IntExt:     m[4],
				Location:   strings.TrimRight(m[5], "* "),
				Characters: []string{},
				Blocks:     []ParsedBlock{},
			})
			currentScene = &currentEpisode.Scenes[len(currentEpisode.Scenes)-1]
			recognized++
			continue
		}

		if m := reCharacters.FindStringSubmatch(line); m != nil {
			if currentScene != nil {
				currentScene.Characters = splitCharacters(m[1])
			}
			recognized++
			continue
		}

		if currentScene == nil {
			appendOrphanBlock(result, line, lineNum)
			continue
		}

		if m := reAction.FindStringSubmatch(line); m != nil {
			currentScene.Blocks = append(currentScene.Blocks, ParsedBlock{
				Type:       BlockAction,
				Content:    m[1],
				Confidence: 1.0,
				SourceLine: lineNum,
			})
			recognized++
			continue
		}

		if m := reCloseup.FindStringSubmatch(line); m != nil {
			currentScene.Blocks = append(currentScene.Blocks, ParsedBlock{
				Type:       BlockCloseup,
				Content:    m[1],
				Confidence: 1.0,
				SourceLine: lineNum,
			})
			recognized++
			continue
		}

		if m := reDirection.FindStringSubmatch(line); m != nil {
			currentScene.Blocks = append(currentScene.Blocks, ParsedBlock{
				Type:       BlockDirection,
				Content:    m[1],
				Confidence: 1.0,
				SourceLine: lineNum,
			})
			recognized++
			continue
		}

		if m := reOS.FindStringSubmatch(line); m != nil {
			char := strings.TrimSpace(m[1])
			content := strings.TrimSpace(m[2])
			emotion, content := extractEmotion(content)
			currentScene.Blocks = append(currentScene.Blocks, ParsedBlock{
				Type:       BlockOS,
				Character:  char,
				Emotion:    emotion,
				Content:    content,
				Confidence: 1.0,
				SourceLine: lineNum,
			})
			recognized++
			continue
		}

		if m := reDialogue.FindStringSubmatch(line); m != nil {
			char := strings.TrimSpace(m[1])
			content := strings.TrimSpace(m[2])
			emotion, content := extractEmotion(content)
			currentScene.Blocks = append(currentScene.Blocks, ParsedBlock{
				Type:       BlockDialogue,
				Character:  char,
				Emotion:    emotion,
				Content:    content,
				Confidence: 1.0,
				SourceLine: lineNum,
			})
			recognized++
			continue
		}

		currentScene.Blocks = append(currentScene.Blocks, ParsedBlock{
			Type:       BlockUnknown,
			Content:    line,
			Confidence: 0,
			SourceLine: lineNum,
		})
	}

	result.Metadata = buildMetadata(result, totalContent, recognized)
	return result
}

func extractEmotion(content string) (emotion, rest string) {
	if em := reEmotion.FindStringSubmatch(content); em != nil {
		return em[1], em[2]
	}
	return "", content
}

func splitCharacters(raw string) []string {
	parts := reCharSplit.Split(raw, -1)
	var chars []string
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			chars = append(chars, p)
		}
	}
	return chars
}

func appendOrphanBlock(result *ParsedScript, line string, lineNum int) {
	if len(result.Episodes) > 0 {
		ep := &result.Episodes[len(result.Episodes)-1]
		if len(ep.Scenes) > 0 {
			sc := &ep.Scenes[len(ep.Scenes)-1]
			sc.Blocks = append(sc.Blocks, ParsedBlock{
				Type:       BlockUnknown,
				Content:    line,
				Confidence: 0,
				SourceLine: lineNum,
			})
		}
	}
}

func buildMetadata(result *ParsedScript, total, recognized int) ParsedMetadata {
	meta := ParsedMetadata{
		TotalLines:      total,
		RecognizedLines: recognized,
		EpisodeCount:    len(result.Episodes),
		CharacterNames:  []string{},
	}
	if total > 0 {
		meta.RecognizeRate = float64(recognized) / float64(total)
	}
	charSet := make(map[string]struct{})
	for _, ep := range result.Episodes {
		meta.SceneCount += len(ep.Scenes)
		for _, sc := range ep.Scenes {
			for _, c := range sc.Characters {
				charSet[c] = struct{}{}
			}
			for _, b := range sc.Blocks {
				if b.Type == BlockUnknown {
					meta.UnknownBlocks++
				}
				if b.Character != "" {
					charSet[b.Character] = struct{}{}
				}
			}
		}
	}
	for name := range charSet {
		meta.CharacterNames = append(meta.CharacterNames, name)
	}
	sort.Strings(meta.CharacterNames)
	return meta
}
