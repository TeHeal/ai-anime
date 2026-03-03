package parser

import "fmt"

// LLMStrategy 描述需要多少 LLM 辅助
type LLMStrategy int

const (
	StrategyNone    LLMStrategy = iota // 正则已处理大部分（rate >= 0.8）
	StrategyPartial                     // 仅 unknown 块需 LLM（0.3 <= rate < 0.8）
	StrategyFull                        // 大部分未识别（rate < 0.3）
)

const (
	thresholdHigh = 0.80
	thresholdLow  = 0.30

	// MaxUnknownBlocksForLLMAssist 超过此数量禁止导入，提示用户优化格式
	MaxUnknownBlocksForLLMAssist = 30
)

// Evaluate 根据正则解析结果决定 LLM 策略
func Evaluate(result *ParsedScript) LLMStrategy {
	rate := result.Metadata.RecognizeRate
	switch {
	case rate >= thresholdHigh:
		return StrategyNone
	case rate >= thresholdLow:
		return StrategyPartial
	default:
		return StrategyFull
	}
}

// UnknownBlockRef 指向待 LLM 解析的 unknown 块
type UnknownBlockRef struct {
	EpisodeIdx int
	SceneIdx   int
	BlockIdx   int
	Content    string
	SourceLine int
}

// CollectUnknownBlocks 收集所有 type=unknown 的块，供 LLM 处理
func CollectUnknownBlocks(result *ParsedScript) []UnknownBlockRef {
	var refs []UnknownBlockRef
	for ei, ep := range result.Episodes {
		for si, sc := range ep.Scenes {
			for bi, b := range sc.Blocks {
				if b.Type == BlockUnknown {
					refs = append(refs, UnknownBlockRef{
						EpisodeIdx: ei,
						SceneIdx:   si,
						BlockIdx:   bi,
						Content:    b.Content,
						SourceLine: b.SourceLine,
					})
				}
			}
		}
	}
	return refs
}

// ShouldBlockImport 当未识别块过多时禁止导入，返回 (true, 提示文案)
func ShouldBlockImport(result *ParsedScript) (bool, string) {
	n := result.Metadata.UnknownBlocks
	if n > MaxUnknownBlocksForLLMAssist {
		return true, fmt.Sprintf("剧本格式不规范，未识别内容块过多（共 %d 个），请先按推荐格式整理后再导入", n)
	}
	return false, ""
}
