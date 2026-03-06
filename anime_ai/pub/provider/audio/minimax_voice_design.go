// Package audio 音色设计、TTS、克隆等音频 Provider 实现
package audio

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"anime_ai/pub/capability"
)

// MiniMaxVoiceDesignProvider MiniMax 音色设计（文生音色）
// 文档：docs/模型/MiniMax.md，API POST /v1/voice_design
// 输入文本描述，同步返回新生成的 voice_id + 试听音频（hex 编码）
type MiniMaxVoiceDesignProvider struct {
	apiKey string
	client *http.Client
}

// NewMiniMaxVoiceDesignProvider 创建 MiniMax 音色设计 Provider
func NewMiniMaxVoiceDesignProvider(apiKey string) *MiniMaxVoiceDesignProvider {
	return &MiniMaxVoiceDesignProvider{
		apiKey: apiKey,
		client: &http.Client{Timeout: 60 * time.Second},
	}
}

func (p *MiniMaxVoiceDesignProvider) Name() string { return "minimax_voice_design" }

// voiceDesignReq 音色设计请求体
type voiceDesignReq struct {
	Prompt      string `json:"prompt"`
	PreviewText string `json:"preview_text"`
	VoiceID     string `json:"voice_id,omitempty"`
	AigcMark    bool   `json:"aigc_watermark,omitempty"`
}

// voiceDesignResp 音色设计响应体
type voiceDesignResp struct {
	VoiceID   string `json:"voice_id"`
	TrialAudio string `json:"trial_audio"` // hex 编码的 mp3
	BaseResp  *struct {
		StatusCode int    `json:"status_code"`
		StatusMsg  string `json:"status_msg"`
	} `json:"base_resp"`
}

// Design 调用 MiniMax /v1/voice_design，同步返回新音色 + 试听音频
func (p *MiniMaxVoiceDesignProvider) Design(ctx context.Context, req capability.VoiceDesignRequest) (*capability.VoiceDesignResult, error) {
	previewText := strings.TrimSpace(req.PreviewText)
	if previewText == "" {
		previewText = "你好，这是一段试听音频。"
	}
	if len(previewText) > 500 {
		previewText = previewText[:500]
	}

	body := voiceDesignReq{
		Prompt:      strings.TrimSpace(req.Prompt),
		PreviewText: previewText,
		AigcMark:    false,
	}
	if req.VoiceID != "" {
		body.VoiceID = req.VoiceID
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("序列化请求失败: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, minimaxAPIBase+"/v1/voice_design", bytes.NewReader(bodyBytes))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("请求 voice_design 失败: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("MiniMax 返回 %d: %s", resp.StatusCode, string(respBody))
	}

	var result voiceDesignResp
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}
	if result.BaseResp != nil && result.BaseResp.StatusCode != 0 {
		return nil, fmt.Errorf("MiniMax 错误: %s (code=%d)", result.BaseResp.StatusMsg, result.BaseResp.StatusCode)
	}
	if result.VoiceID == "" {
		return nil, fmt.Errorf("MiniMax 未返回 voice_id")
	}

	// trial_audio 为 hex 编码，解码为 mp3 字节
	var audioData []byte
	if result.TrialAudio != "" {
		audioData, err = hex.DecodeString(result.TrialAudio)
		if err != nil {
			return nil, fmt.Errorf("解码 trial_audio 失败: %w", err)
		}
	}

	return &capability.VoiceDesignResult{
		VoiceID:   result.VoiceID,
		AudioData: audioData,
		Provider:  p.Name(),
	}, nil
}
