package parser

import (
	"context"

	"anime_ai/pub/pkg"
)

// Parse 执行完整解析流程：预处理 → 正则解析 →（可选）LLM 辅助 → 校验
// llmClient 为 nil 时不调用 LLM；format_hint=unknown 且 unknown 块过多时返回 BizError 禁止导入
func Parse(ctx context.Context, rawText string, opts ParseOptions, llmClient LLMClient) (*ParseResult, error) {
	cleaned := Preprocess(rawText)
	script := RegexParse(cleaned)

	if opts.FormatHint == FormatUnknown {
		if block, msg := ShouldBlockImport(script); block {
			return nil, pkg.NewBizError(msg)
		}
		if llmClient != nil {
			refs := CollectUnknownBlocks(script)
			if len(refs) > 0 {
				lp := NewLLMParser(llmClient)
				resolved, err := lp.ResolveUnknownBlocks(ctx, refs)
				if err != nil {
					return nil, err
				}
				ApplyLLMResults(script, resolved)
			}
		}
	}

	issues := Validate(script)
	return &ParseResult{
		Script: script,
		Issues: issues,
	}, nil
}
