package parser

import "sort"

// ApplyLLMResults 将 LLM 解析结果写回 script，更新 metadata
func ApplyLLMResults(result *ParsedScript, resolved []ResolvedBlock) {
	lookup := make(map[[3]int]ResolvedBlock, len(resolved))
	for _, r := range resolved {
		key := [3]int{r.EpisodeIdx, r.SceneIdx, r.BlockIdx}
		lookup[key] = r
	}

	unknownRemaining := 0
	recognizedDelta := 0

	for ei := range result.Episodes {
		for si := range result.Episodes[ei].Scenes {
			for bi := range result.Episodes[ei].Scenes[si].Blocks {
				b := &result.Episodes[ei].Scenes[si].Blocks[bi]
				if b.Type != BlockUnknown {
					continue
				}
				key := [3]int{ei, si, bi}
				if r, ok := lookup[key]; ok {
					b.Type = r.Type
					b.Character = r.Character
					b.Emotion = r.Emotion
					if r.Content != "" {
						b.Content = r.Content
					}
					b.Confidence = r.Confidence
					recognizedDelta++
				} else {
					unknownRemaining++
				}
			}
		}
	}

	result.Metadata.RecognizedLines += recognizedDelta
	result.Metadata.UnknownBlocks = unknownRemaining
	if result.Metadata.TotalLines > 0 {
		result.Metadata.RecognizeRate = float64(result.Metadata.RecognizedLines) / float64(result.Metadata.TotalLines)
	}
	result.Metadata.CharacterNames = collectAllCharacters(result)
}

func collectAllCharacters(result *ParsedScript) []string {
	charSet := make(map[string]struct{})
	for _, ep := range result.Episodes {
		for _, sc := range ep.Scenes {
			for _, c := range sc.Characters {
				charSet[c] = struct{}{}
			}
			for _, b := range sc.Blocks {
				if b.Character != "" {
					charSet[b.Character] = struct{}{}
				}
			}
		}
	}
	names := make([]string, 0, len(charSet))
	for n := range charSet {
		names = append(names, n)
	}
	sort.Strings(names)
	return names
}
