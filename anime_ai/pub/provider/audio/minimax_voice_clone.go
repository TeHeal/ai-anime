package audio

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"regexp"
	"strings"
	"time"

	"anime_ai/pub/capability"
)

const minimaxAPIBase = "https://api.minimaxi.com"

// voiceID 格式：8~256 字符，首字符须为字母，允许数字、字母、-、_，末位不可为 -、_
var voiceIDRe = regexp.MustCompile(`^[a-zA-Z][a-zA-Z0-9\-_]{7,255}$`)

// MiniMaxVoiceCloneProvider MiniMax 音色快速复刻
// 文档：https://platform.minimaxi.com/docs/guides/speech-voice-clone
type MiniMaxVoiceCloneProvider struct {
	apiKey string
	client *http.Client
}

// NewMiniMaxVoiceCloneProvider 创建 MiniMax 音色克隆 Provider
func NewMiniMaxVoiceCloneProvider(apiKey string) *MiniMaxVoiceCloneProvider {
	return &MiniMaxVoiceCloneProvider{
		apiKey: apiKey,
		client: &http.Client{Timeout: 120 * time.Second},
	}
}

func (p *MiniMaxVoiceCloneProvider) Name() string { return "minimax_voice_clone" }

// fileUploadResp 文件上传响应
type fileUploadResp struct {
	File struct {
		FileID int64 `json:"file_id"`
	} `json:"file"`
	BaseResp *baseResp `json:"base_resp"`
}

type baseResp struct {
	StatusCode int    `json:"status_code"`
	StatusMsg  string `json:"status_msg"`
}


// voiceCloneResp 音色克隆响应
type voiceCloneResp struct {
	DemoAudio  string    `json:"demo_audio"`
	BaseResp   *baseResp `json:"base_resp"`
}

// Clone 执行音色克隆
func (p *MiniMaxVoiceCloneProvider) Clone(ctx context.Context, req capability.VoiceCloneRequest) (*capability.VoiceCloneResult, error) {
	if len(req.SampleAudio) == 0 {
		return nil, fmt.Errorf("待克隆音频为空")
	}
	voiceID := strings.TrimSpace(req.VoiceID)
	if voiceID == "" {
		voiceID = genVoiceID()
	}
	if !voiceIDRe.MatchString(voiceID) {
		return nil, fmt.Errorf("voice_id 格式无效：须 8~256 字符，首字符为字母，允许字母数字-_")
	}

	// 1. 上传待克隆音频
	fileID, err := p.uploadFile(ctx, req.SampleAudio, req.SampleFilename, "voice_clone")
	if err != nil {
		return nil, fmt.Errorf("上传复刻音频失败: %w", err)
	}

	// 2. 调用克隆接口
	previewText := req.PreviewText
	if previewText == "" {
		previewText = "你好，这是一段试听音频。"
	}
	model := req.Model
	if model == "" {
		model = "speech-2.8-hd"
	}

	cloneBody := map[string]any{
		"file_id":  fileID,
		"voice_id": voiceID,
		"text":     previewText,
		"model":    model,
	}
	bodyBytes, _ := json.Marshal(cloneBody)

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, minimaxAPIBase+"/v1/voice_clone", bytes.NewReader(bodyBytes))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("请求 voice_clone 失败: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var cloneResp voiceCloneResp
	if err := json.Unmarshal(respBody, &cloneResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}
	if cloneResp.BaseResp != nil && cloneResp.BaseResp.StatusCode != 0 {
		return nil, fmt.Errorf("voice_clone 失败: %s (code=%d)", cloneResp.BaseResp.StatusMsg, cloneResp.BaseResp.StatusCode)
	}

	return &capability.VoiceCloneResult{
		VoiceID:  voiceID,
		DemoURL:  cloneResp.DemoAudio,
		Provider: p.Name(),
	}, nil
}

// uploadFile 上传文件到 MiniMax，返回 file_id
func (p *MiniMaxVoiceCloneProvider) uploadFile(ctx context.Context, data []byte, filename, purpose string) (int64, error) {
	if filename == "" {
		filename = "audio.mp3"
	}
	var buf bytes.Buffer
	w := multipart.NewWriter(&buf)

	_ = w.WriteField("purpose", purpose)
	part, err := w.CreateFormFile("file", filename)
	if err != nil {
		return 0, err
	}
	if _, err := part.Write(data); err != nil {
		return 0, err
	}
	if err := w.Close(); err != nil {
		return 0, err
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, minimaxAPIBase+"/v1/files/upload", &buf)
	if err != nil {
		return 0, err
	}
	httpReq.Header.Set("Content-Type", w.FormDataContentType())
	httpReq.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(httpReq)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var uploadResp fileUploadResp
	if err := json.Unmarshal(respBody, &uploadResp); err != nil {
		return 0, fmt.Errorf("解析上传响应失败: %w", err)
	}
	if uploadResp.BaseResp != nil && uploadResp.BaseResp.StatusCode != 0 {
		return 0, fmt.Errorf("上传失败: %s (code=%d)", uploadResp.BaseResp.StatusMsg, uploadResp.BaseResp.StatusCode)
	}
	if uploadResp.File.FileID == 0 {
		return 0, fmt.Errorf("上传未返回 file_id")
	}
	return uploadResp.File.FileID, nil
}

// genVoiceID 生成符合规范的 voice_id
func genVoiceID() string {
	return fmt.Sprintf("MiniMax%x", time.Now().UnixNano()&0xFFFFFF)
}
