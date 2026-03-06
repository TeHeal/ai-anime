// Package audio TTS、克隆等音频 Provider 实现
package audio

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"anime_ai/pub/capability"
)

// MiniMaxTTSProvider MiniMax 异步语音合成 (t2a_async_v2)
// 文档：https://platform.minimaxi.com/docs/guides/speech-t2a-async
type MiniMaxTTSProvider struct {
	apiKey string
	client *http.Client
}

// NewMiniMaxTTSProvider 创建 MiniMax TTS Provider
func NewMiniMaxTTSProvider(apiKey string) *MiniMaxTTSProvider {
	return &MiniMaxTTSProvider{
		apiKey: apiKey,
		client: &http.Client{Timeout: 60 * time.Second},
	}
}

func (p *MiniMaxTTSProvider) Name() string { return "minimax_tts" }

// t2aCreateReq 创建任务请求
type t2aCreateReq struct {
	Model         string                 `json:"model"`
	Text          string                 `json:"text"`
	VoiceSetting  map[string]any          `json:"voice_setting"`
	AudioSetting  map[string]any          `json:"audio_setting,omitempty"`
	LanguageBoost string                 `json:"language_boost,omitempty"`
}

// t2aCreateResp 创建任务响应
// MiniMax API 的 task_id 实际为 number，用 json.Number 兼容
type t2aCreateResp struct {
	TaskID   json.Number `json:"task_id"`
	FileID   int64       `json:"file_id"`
	BaseResp *struct {
		StatusCode int    `json:"status_code"`
		StatusMsg  string `json:"status_msg"`
	} `json:"base_resp"`
}

// t2aQueryResp 查询任务响应
type t2aQueryResp struct {
	TaskStatus string `json:"task_status"` // Pending, Running, Success, Failed
	FileID     int64  `json:"file_id"`
	BaseResp   *struct {
		StatusCode int    `json:"status_code"`
		StatusMsg  string `json:"status_msg"`
	} `json:"base_resp"`
}

// fileRetrieveResp 文件检索响应（含下载 URL）
type fileRetrieveResp struct {
	DownloadURL string `json:"download_url"`
	BaseResp   *struct {
		StatusCode int    `json:"status_code"`
		StatusMsg  string `json:"status_msg"`
	} `json:"base_resp"`
}

// SubmitTTSTask 提交 TTS 任务
func (p *MiniMaxTTSProvider) SubmitTTSTask(ctx context.Context, req capability.TTSRequest) (string, error) {
	model := req.Model
	if model == "" {
		model = "speech-2.8-hd"
	}
	voiceID := req.VoiceID
	if voiceID == "" {
		voiceID = "audiobook_male_1"
	}

	body := t2aCreateReq{
		Model:         model,
		Text:          req.Text,
		LanguageBoost: "auto",
		VoiceSetting: map[string]any{
			"voice_id": voiceID,
			"speed":    1,
			"vol":      10,
			"pitch":    1,
		},
		AudioSetting: map[string]any{
			"audio_sample_rate": 32000,
			"bitrate":           128000,
			"format":            "mp3",
			"channel":           2,
		},
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return "", fmt.Errorf("序列化请求失败: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, minimaxAPIBase+"/v1/t2a_async_v2", bytes.NewReader(bodyBytes))
	if err != nil {
		return "", fmt.Errorf("创建请求失败: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("请求 t2a_async_v2 失败: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("MiniMax 返回 %d: %s", resp.StatusCode, string(respBody))
	}

	var result t2aCreateResp
	if err := json.Unmarshal(respBody, &result); err != nil {
		return "", fmt.Errorf("解析响应失败: %w", err)
	}
	if result.BaseResp != nil && result.BaseResp.StatusCode != 0 {
		return "", fmt.Errorf("MiniMax 错误: %s (code=%d)", result.BaseResp.StatusMsg, result.BaseResp.StatusCode)
	}
	taskID := result.TaskID.String()
	if taskID == "" || taskID == "0" {
		return "", fmt.Errorf("MiniMax 未返回 task_id")
	}
	return taskID, nil
}

// QueryTTSTask 查询 TTS 任务状态
func (p *MiniMaxTTSProvider) QueryTTSTask(ctx context.Context, taskID string) (*capability.TTSResult, error) {
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet,
		minimaxAPIBase+"/v1/query/t2a_async_query_v2?task_id="+taskID, nil)
	if err != nil {
		return nil, fmt.Errorf("创建查询请求失败: %w", err)
	}
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("查询任务失败: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var result t2aQueryResp
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("解析查询响应失败: %w", err)
	}
	if result.BaseResp != nil && result.BaseResp.StatusCode != 0 {
		return nil, fmt.Errorf("MiniMax 查询错误: %s (code=%d)", result.BaseResp.StatusMsg, result.BaseResp.StatusCode)
	}

	ttsResult := &capability.TTSResult{}
	switch result.TaskStatus {
	case "Success":
		ttsResult.Status = "completed"
		if result.FileID != 0 {
			url, err := p.getFileDownloadURL(ctx, result.FileID)
			if err != nil {
				return nil, fmt.Errorf("获取下载 URL 失败: %w", err)
			}
			ttsResult.AudioURL = url
		}
	case "Failed":
		ttsResult.Status = "failed"
		ttsResult.Error = result.BaseResp.StatusMsg
	default:
		ttsResult.Status = "pending"
	}
	return ttsResult, nil
}

// SynthesizeSync 同步语音合成（t2a_v2），直接返回 mp3 音频字节
// 适用于短文本试听，2~5 秒内返回结果
func (p *MiniMaxTTSProvider) SynthesizeSync(ctx context.Context, req capability.TTSRequest) ([]byte, error) {
	model := req.Model
	if model == "" {
		model = "speech-2.8-hd"
	}
	voiceID := req.VoiceID
	if voiceID == "" {
		voiceID = "audiobook_male_1"
	}

	body := map[string]any{
		"model":  model,
		"text":   req.Text,
		"stream": false,
		"voice_setting": map[string]any{
			"voice_id": voiceID,
			"speed":    1,
			"vol":      1,
			"pitch":    0,
		},
		"audio_setting": map[string]any{
			"sample_rate": 32000,
			"bitrate":     128000,
			"format":      "mp3",
			"channel":     1,
		},
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("序列化请求失败: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, minimaxAPIBase+"/v1/t2a_v2", bytes.NewReader(bodyBytes))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("请求 t2a_v2 失败: %w", err)
	}
	defer resp.Body.Close()
	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("MiniMax t2a_v2 返回 %d: %s", resp.StatusCode, string(respBody))
	}

	var result struct {
		Data struct {
			Audio  string `json:"audio"`
			Status int    `json:"status"`
		} `json:"data"`
		BaseResp *struct {
			StatusCode int    `json:"status_code"`
			StatusMsg  string `json:"status_msg"`
		} `json:"base_resp"`
	}
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("解析 t2a_v2 响应失败: %w", err)
	}
	if result.BaseResp != nil && result.BaseResp.StatusCode != 0 {
		return nil, fmt.Errorf("MiniMax t2a_v2 错误: %s (code=%d)", result.BaseResp.StatusMsg, result.BaseResp.StatusCode)
	}
	if result.Data.Audio == "" {
		return nil, fmt.Errorf("MiniMax t2a_v2 未返回音频数据")
	}

	audioBytes, err := hexDecode(result.Data.Audio)
	if err != nil {
		return nil, fmt.Errorf("解码 hex 音频失败: %w", err)
	}
	return audioBytes, nil
}

// hexDecode 解码 hex 编码的字符串
func hexDecode(s string) ([]byte, error) {
	if len(s)%2 != 0 {
		return nil, fmt.Errorf("hex 字符串长度为奇数")
	}
	b := make([]byte, len(s)/2)
	for i := 0; i < len(s); i += 2 {
		hi := unhex(s[i])
		lo := unhex(s[i+1])
		if hi == 0xFF || lo == 0xFF {
			return nil, fmt.Errorf("无效 hex 字符在位置 %d", i)
		}
		b[i/2] = hi<<4 | lo
	}
	return b, nil
}

func unhex(c byte) byte {
	switch {
	case '0' <= c && c <= '9':
		return c - '0'
	case 'a' <= c && c <= 'f':
		return c - 'a' + 10
	case 'A' <= c && c <= 'F':
		return c - 'A' + 10
	default:
		return 0xFF
	}
}

// getFileDownloadURL 通过 file_id 获取下载 URL
// 使用 retrieve 接口返回 download_url（有效期约 9 小时）
func (p *MiniMaxTTSProvider) getFileDownloadURL(ctx context.Context, fileID int64) (string, error) {
	url := fmt.Sprintf("%s/v1/files/retrieve?file_id=%d", minimaxAPIBase, fileID)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	var fileResp fileRetrieveResp
	if err := json.Unmarshal(body, &fileResp); err == nil && fileResp.DownloadURL != "" {
		return fileResp.DownloadURL, nil
	}
	var m map[string]any
	if json.Unmarshal(body, &m) == nil {
		if u, ok := m["download_url"].(string); ok && u != "" {
			return u, nil
		}
	}
	return "", fmt.Errorf("无法获取音频下载 URL，file_id=%d", fileID)
}
