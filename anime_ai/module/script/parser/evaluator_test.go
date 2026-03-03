package parser

import (
	"testing"
)

func TestEvaluate(t *testing.T) {
	tests := []struct {
		rate   float64
		expect LLMStrategy
	}{
		{0.9, StrategyNone},
		{0.8, StrategyNone},
		{0.79, StrategyPartial},
		{0.5, StrategyPartial},
		{0.3, StrategyPartial},
		{0.29, StrategyFull},
		{0, StrategyFull},
	}
	for _, tt := range tests {
		s := &ParsedScript{Metadata: ParsedMetadata{RecognizeRate: tt.rate}}
		got := Evaluate(s)
		if got != tt.expect {
			t.Errorf("Evaluate(rate=%.2f) = %v, want %v", tt.rate, got, tt.expect)
		}
	}
}

func TestShouldBlockImport(t *testing.T) {
	tests := []struct {
		unknownBlocks int
		wantBlock     bool
	}{
		{29, false},
		{30, false},
		{31, true},
		{50, true},
	}
	for _, tt := range tests {
		s := &ParsedScript{Metadata: ParsedMetadata{UnknownBlocks: tt.unknownBlocks}}
		block, msg := ShouldBlockImport(s)
		if block != tt.wantBlock {
			t.Errorf("ShouldBlockImport(unknown=%d) block=%v, want %v", tt.unknownBlocks, block, tt.wantBlock)
		}
		if block && msg == "" {
			t.Errorf("ShouldBlockImport(unknown=%d) should return non-empty msg when blocking", tt.unknownBlocks)
		}
	}
}

func TestCollectUnknownBlocks(t *testing.T) {
	s := &ParsedScript{
		Episodes: []ParsedEpisode{
			{
				EpisodeNum: 1,
				Scenes: []ParsedScene{
					{
						SceneNum: "1-1",
						Blocks: []ParsedBlock{
							{Type: BlockUnknown, Content: "a"},
							{Type: BlockDialogue, Content: "b"},
							{Type: BlockUnknown, Content: "c"},
						},
					},
				},
			},
		},
	}
	refs := CollectUnknownBlocks(s)
	if len(refs) != 2 {
		t.Errorf("CollectUnknownBlocks: got %d refs, want 2", len(refs))
	}
	if refs[0].Content != "a" || refs[1].Content != "c" {
		t.Errorf("CollectUnknownBlocks: wrong content order")
	}
}
