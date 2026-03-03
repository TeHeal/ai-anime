package parser

import "fmt"

// Validate 对解析结果做基础校验，返回问题列表（保证非 nil，便于 JSON 序列化为 []）
func Validate(result *ParsedScript) []ValidationIssue {
	issues := []ValidationIssue{}

	for i, ep := range result.Episodes {
		if i > 0 && ep.EpisodeNum != result.Episodes[i-1].EpisodeNum+1 {
			issues = append(issues, ValidationIssue{
				Level:   IssueWarning,
				Message: "集号不连续",
				Detail:  fmt.Sprintf("第%d集 之后是 第%d集", result.Episodes[i-1].EpisodeNum, ep.EpisodeNum),
			})
		}
		if len(ep.Scenes) == 0 {
			issues = append(issues, ValidationIssue{
				Level:   IssueWarning,
				Message: "空集",
				Detail:  fmt.Sprintf("第%d集 没有场景", ep.EpisodeNum),
			})
		}
	}

	if result.Metadata.UnknownBlocks > 0 {
		issues = append(issues, ValidationIssue{
			Level:   IssueInfo,
			Message: "存在未识别内容块",
			Detail:  fmt.Sprintf("共 %d 个内容块未能自动识别类型，需人工确认", result.Metadata.UnknownBlocks),
		})
	}

	return issues
}
