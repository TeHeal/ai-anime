package parser

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"sync"
	"time"
)

const llmBatchTimeout = 60 * time.Second
const llmConcurrency = 5

// LLMParser 通过 LLM 解析 unknown 块
type LLMParser struct {
	client LLMClient
}

// NewLLMParser 创建 LLMParser
func NewLLMParser(client LLMClient) *LLMParser {
	return &LLMParser{client: client}
}

// ResolvedBlock LLM 解析后的块结果
type ResolvedBlock struct {
	EpisodeIdx int
	SceneIdx   int
	BlockIdx   int
	Type       BlockType
	Character  string
	Emotion    string
	Content    string
	Confidence float64
}

// ResolveUnknownBlocks 按场分批调用 LLM，返回解析结果
func (p *LLMParser) ResolveUnknownBlocks(ctx context.Context, refs []UnknownBlockRef) ([]ResolvedBlock, error) {
	if len(refs) == 0 {
		return nil, nil
	}
	batches := groupByScene(refs)

	var (
		mu       sync.Mutex
		results  []ResolvedBlock
		errOnce  sync.Once
		firstErr error
		wg       sync.WaitGroup
		sem      = make(chan struct{}, llmConcurrency)
	)

	for _, batch := range batches {
		wg.Add(1)
		sem <- struct{}{}
		go func(b sceneBatch) {
			defer wg.Done()
			defer func() { <-sem }()

			batchCtx, cancel := context.WithTimeout(ctx, llmBatchTimeout)
			defer cancel()

			resolved, err := p.processBatch(batchCtx, b)
			if err != nil {
				errOnce.Do(func() { firstErr = err })
				return
			}

			mu.Lock()
			results = append(results, resolved...)
			mu.Unlock()
		}(batch)
	}

	wg.Wait()

	if firstErr != nil {
		return results, firstErr
	}
	return results, nil
}

type sceneBatch struct {
	episodeIdx int
	sceneIdx   int
	refs       []UnknownBlockRef
}

func groupByScene(refs []UnknownBlockRef) []sceneBatch {
	key := func(r UnknownBlockRef) [2]int { return [2]int{r.EpisodeIdx, r.SceneIdx} }
	orderMap := make(map[[2]int]int)
	var batches []sceneBatch
	for _, r := range refs {
		k := key(r)
		if idx, ok := orderMap[k]; ok {
			batches[idx].refs = append(batches[idx].refs, r)
		} else {
			orderMap[k] = len(batches)
			batches = append(batches, sceneBatch{
				episodeIdx: r.EpisodeIdx,
				sceneIdx:   r.SceneIdx,
				refs:       []UnknownBlockRef{r},
			})
		}
	}
	return batches
}

func (p *LLMParser) processBatch(ctx context.Context, batch sceneBatch) ([]ResolvedBlock, error) {
	var sb strings.Builder
	for i, ref := range batch.refs {
		fmt.Fprintf(&sb, "[%d] %s\n", i, ref.Content)
	}

	resp, err := p.client.ChatSync(ctx, scriptAnalysisPrompt, sb.String())
	if err != nil {
		return nil, fmt.Errorf("LLM call failed for scene %d-%d: %w",
			batch.episodeIdx, batch.sceneIdx, err)
	}

	parsed, err := parseLLMResponse(resp)
	if err != nil {
		var fallback []ResolvedBlock
		for _, ref := range batch.refs {
			fallback = append(fallback, ResolvedBlock{
				EpisodeIdx: ref.EpisodeIdx,
				SceneIdx:   ref.SceneIdx,
				BlockIdx:   ref.BlockIdx,
				Type:       BlockAction,
				Content:    ref.Content,
				Confidence: 0.3,
			})
		}
		return fallback, nil
	}

	var results []ResolvedBlock
	for _, item := range parsed {
		if item.Index < 0 || item.Index >= len(batch.refs) {
			continue
		}
		ref := batch.refs[item.Index]
		results = append(results, ResolvedBlock{
			EpisodeIdx: ref.EpisodeIdx,
			SceneIdx:   ref.SceneIdx,
			BlockIdx:   ref.BlockIdx,
			Type:       toBlockType(item.Type),
			Character:  item.Character,
			Emotion:    item.Emotion,
			Content:    ref.Content,
			Confidence: 0.8,
		})
	}

	covered := make(map[int]bool, len(results))
	for _, r := range results {
		covered[r.BlockIdx] = true
	}
	for _, ref := range batch.refs {
		if !covered[ref.BlockIdx] {
			results = append(results, ResolvedBlock{
				EpisodeIdx: ref.EpisodeIdx,
				SceneIdx:   ref.SceneIdx,
				BlockIdx:   ref.BlockIdx,
				Type:       BlockAction,
				Content:    ref.Content,
				Confidence: 0.3,
			})
		}
	}
	return results, nil
}

type llmBlockItem struct {
	Index     int    `json:"index"`
	Type      string `json:"type"`
	Character string `json:"character"`
	Emotion   string `json:"emotion"`
	Content   string `json:"content"`
}

func parseLLMResponse(resp string) ([]llmBlockItem, error) {
	resp = strings.TrimSpace(resp)
	if idx := strings.Index(resp, "```json"); idx >= 0 {
		resp = resp[idx+7:]
		if end := strings.Index(resp, "```"); end >= 0 {
			resp = resp[:end]
		}
	} else if idx := strings.Index(resp, "```"); idx >= 0 {
		resp = resp[idx+3:]
		if end := strings.Index(resp, "```"); end >= 0 {
			resp = resp[:end]
		}
	}
	resp = strings.TrimSpace(resp)

	var items []llmBlockItem
	if err := json.Unmarshal([]byte(resp), &items); err != nil {
		return nil, fmt.Errorf("failed to parse LLM JSON: %w", err)
	}
	return items, nil
}

func toBlockType(s string) BlockType {
	switch BlockType(s) {
	case BlockAction, BlockDialogue, BlockOS, BlockCloseup, BlockDirection:
		return BlockType(s)
	default:
		return BlockAction
	}
}
