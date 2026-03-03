// Package parser 剧本解析器：借鉴 anime-bak 实现，将原始文本解析为集-场-块结构。
// 流程：预处理 → 正则解析 → 校验；暂不接入 LLM。
package parser

// ParseResult 解析结果，与 Flutter ScriptParseResult 契约一致
type ParseResult struct {
	Script *ParsedScript     `json:"script"`
	Issues []ValidationIssue `json:"issues"`
}

// ParsedScript 解析后的剧本顶层结构
type ParsedScript struct {
	Title    string          `json:"title"`
	Episodes []ParsedEpisode `json:"episodes"`
	Metadata ParsedMetadata  `json:"metadata"`
}

// ParsedEpisode 集
type ParsedEpisode struct {
	EpisodeNum int          `json:"episode_num"`
	Scenes     []ParsedScene `json:"scenes"`
}

// ParsedScene 场
type ParsedScene struct {
	SceneNum   string        `json:"scene_num"`
	Time       string        `json:"time"`
	IntExt     string        `json:"int_ext"`
	Location   string        `json:"location"`
	Characters []string       `json:"characters"`
	Blocks     []ParsedBlock `json:"blocks"`
}

// ParsedBlock 内容块（动作/对白/OS/特写/导演/未知）
type ParsedBlock struct {
	Type       BlockType `json:"type"`
	Character  string    `json:"character,omitempty"`
	Emotion    string    `json:"emotion,omitempty"`
	Content    string    `json:"content"`
	Confidence float64   `json:"confidence"`
	SourceLine int       `json:"source_line"`
}

// BlockType 内容块类型
type BlockType string

const (
	BlockAction    BlockType = "action"
	BlockDialogue  BlockType = "dialogue"
	BlockOS        BlockType = "os"
	BlockCloseup   BlockType = "closeup"
	BlockDirection BlockType = "direction"
	BlockUnknown   BlockType = "unknown"
)

// ParsedMetadata 解析元信息
type ParsedMetadata struct {
	TotalLines      int      `json:"total_lines"`
	RecognizedLines int      `json:"recognized_lines"`
	RecognizeRate   float64  `json:"recognize_rate"`
	EpisodeCount   int      `json:"episode_count"`
	SceneCount      int      `json:"scene_count"`
	CharacterNames  []string `json:"character_names"`
	UnknownBlocks   int      `json:"unknown_blocks"`
}

// IssueLevel 校验问题级别
type IssueLevel string

const (
	IssueInfo    IssueLevel = "info"
	IssueWarning IssueLevel = "warning"
)

// ValidationIssue 校验问题，与 Flutter ValidationIssue 契约一致
type ValidationIssue struct {
	Level   IssueLevel `json:"level"`
	Message string     `json:"message"`
	Detail  string     `json:"detail"`
}

// FormatHint 格式提示
type FormatHint string

const (
	FormatStandard FormatHint = "standard"
	FormatUnknown  FormatHint = "unknown"
)

// ParseOptions 解析选项
type ParseOptions struct {
	FormatHint FormatHint
}
