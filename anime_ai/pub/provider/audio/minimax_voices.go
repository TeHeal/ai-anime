// Package audio 音色设计、TTS、克隆等音频 Provider 实现
package audio

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"anime_ai/pub/capability"
)

// SystemVoiceInfo 系统音色信息（与 MiniMax get_voice 响应对齐）
type SystemVoiceInfo struct {
	VoiceID     string   `json:"voice_id"`
	VoiceName   string   `json:"voice_name"`
	Description []string `json:"description"`
}

// GetMiniMaxSystemVoices 调用 MiniMax POST /v1/get_voice 获取系统音色列表
// 文档：https://platform.minimaxi.com/docs/api-reference/voice-management-get
func GetMiniMaxSystemVoices(ctx context.Context, apiKey string) ([]SystemVoiceInfo, error) {
	if apiKey == "" {
		return nil, fmt.Errorf("MiniMax API Key 未配置")
	}
	body := []byte(`{"voice_type":"system"}`)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, minimaxAPIBase+"/v1/get_voice", bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+apiKey)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("请求 get_voice 失败: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("MiniMax 返回 %d: %s", resp.StatusCode, string(respBody))
	}

	var result struct {
		SystemVoice []SystemVoiceInfo `json:"system_voice"`
		BaseResp    *struct {
			StatusCode int    `json:"status_code"`
			StatusMsg  string `json:"status_msg"`
		} `json:"base_resp"`
	}
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}
	if result.BaseResp != nil && result.BaseResp.StatusCode != 0 {
		return nil, fmt.Errorf("MiniMax 错误: %s (code=%d)", result.BaseResp.StatusMsg, result.BaseResp.StatusCode)
	}
	if result.SystemVoice == nil {
		return []SystemVoiceInfo{}, nil
	}
	return result.SystemVoice, nil
}

// MiniMaxSystemVoiceLister 实现 SystemVoiceLister，用于资源服务合并系统音色
type MiniMaxSystemVoiceLister struct {
	apiKey string
}

// NewMiniMaxSystemVoiceLister 创建 MiniMax 系统音色列表器
func NewMiniMaxSystemVoiceLister(apiKey string) *MiniMaxSystemVoiceLister {
	return &MiniMaxSystemVoiceLister{apiKey: apiKey}
}

// ListSystemVoices 返回 MiniMax 系统音色；provider 非 minimax 时返回空
func (m *MiniMaxSystemVoiceLister) ListSystemVoices(ctx context.Context, provider string) ([]capability.SystemVoiceItem, error) {
	if provider != "minimax" && !strings.Contains(strings.ToLower(provider), "minimax") {
		return nil, nil
	}
	list, err := GetMiniMaxSystemVoices(ctx, m.apiKey)
	if err != nil {
		return nil, err
	}
	out := make([]capability.SystemVoiceItem, 0, len(list))
	for _, v := range list {
		desc := ""
		if len(v.Description) > 0 {
			desc = v.Description[0]
		}
		out = append(out, capability.SystemVoiceItem{
			VoiceID:     v.VoiceID,
			VoiceName:   v.VoiceName,
			Description: desc,
			Provider:    "minimax",
		})
	}
	return out, nil
}
