package resource

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"anime_ai/pub/capability"
	"anime_ai/pub/pkg"
	"anime_ai/pub/storage"
)

// ImageGen 图生能力接口（用于 generate-image）
type ImageGen interface {
	Submit(ctx context.Context, req capability.ImageRequest, preferred string) (providerName, taskID string, err error)
	Query(ctx context.Context, taskID string) (*capability.ImageResult, error)
}

// PromptGen LLM 提示词生成接口
type PromptGen interface {
	Chat(ctx context.Context, systemPrompt, userPrompt string) (string, error)
}

// TTSCapability TTS 能力接口（用于音色设计）
type TTSCapability interface {
	Submit(ctx context.Context, req capability.TTSRequest, preferred string) (providerName, taskID string, err error)
	Query(ctx context.Context, taskID string) (*capability.TTSResult, error)
}

// VoiceCloneProvider 音色克隆能力接口
type VoiceCloneProvider interface {
	Name() string
	Clone(ctx context.Context, req capability.VoiceCloneRequest) (*capability.VoiceCloneResult, error)
}

// Service 素材库业务逻辑层
type Service struct {
	data             Data
	imageGen         ImageGen
	promptGen        PromptGen
	ttsCap           TTSCapability
	voiceClone       VoiceCloneProvider
	store            storage.Storage
	voiceCloneHTTP   *http.Client
}

// NewService 创建 Service
func NewService(data Data) *Service {
	return &Service{data: data}
}

// SetImageGen 注入图生能力
func (s *Service) SetImageGen(g ImageGen) {
	s.imageGen = g
}

// SetPromptGen 注入 LLM 提示词生成能力
func (s *Service) SetPromptGen(g PromptGen) {
	s.promptGen = g
}

// SetTTSCapability 注入 TTS 能力（音色设计、预览文本）
func (s *Service) SetTTSCapability(c TTSCapability) {
	s.ttsCap = c
}

// SetVoiceCloneProvider 注入音色克隆能力
func (s *Service) SetVoiceCloneProvider(p VoiceCloneProvider) {
	s.voiceClone = p
}

// SetStorage 注入存储（用于从 sample_url 读取本地上传的音频）
func (s *Service) SetStorage(store storage.Storage) {
	s.store = store
	if s.voiceCloneHTTP == nil {
		s.voiceCloneHTTP = &http.Client{Timeout: 60 * time.Second}
	}
}

var validModalities = map[string]bool{"visual": true, "audio": true, "text": true}
var validSortBy = map[string]bool{"newest": true, "oldest": true, "name_asc": true, "name_desc": true}
var validLibraryTypes = map[string]bool{
	"style": true, "character": true, "scene": true, "prop": true,
	"expression": true, "pose": true, "effect": true, "voice": true, "prompt": true,
	"voiceover": true, "sfx": true, "music": true,
	"styleGuide": true, "dialogueTemplate": true, "scriptSnippet": true,
}

func validateModality(m string) error {
	if m != "" && !validModalities[m] {
		return fmt.Errorf("%w: 无效的素材模态 %s", pkg.ErrBadRequest, m)
	}
	return nil
}

func validateLibraryType(t string) error {
	if t != "" && !validLibraryTypes[t] {
		return fmt.Errorf("%w: 无效的子库类型 %s", pkg.ErrBadRequest, t)
	}
	return nil
}

func validateJSON(s string, name string) error {
	if s == "" {
		return nil
	}
	if !json.Valid([]byte(s)) {
		return fmt.Errorf("%w: %s 不是有效 JSON", pkg.ErrBadRequest, name)
	}
	return nil
}

// Create 创建素材
func (s *Service) Create(ctx context.Context, userID string, req CreateRequest) (*Resource, error) {
	if err := validateModality(req.Modality); err != nil {
		return nil, err
	}
	if err := validateLibraryType(req.LibraryType); err != nil {
		return nil, err
	}
	if err := validateJSON(req.TagsJSON, "tagsJson"); err != nil {
		return nil, err
	}
	if err := validateJSON(req.MetadataJSON, "metadataJson"); err != nil {
		return nil, err
	}
	if err := validateJSON(req.BindingIdsJSON, "bindingIdsJson"); err != nil {
		return nil, err
	}
	r := &Resource{
		UserID:         userID,
		Name:           req.Name,
		LibraryType:   req.LibraryType,
		Modality:      req.Modality,
		ThumbnailURL:  req.ThumbnailURL,
		TagsJSON:      orEmpty(req.TagsJSON, "[]"),
		Version:       req.Version,
		MetadataJSON:  orEmpty(req.MetadataJSON, "{}"),
		BindingIdsJSON: orEmpty(req.BindingIdsJSON, "[]"),
		Description:   req.Description,
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// GeneratePrompt 调用 LLM 生成提示词，写入 resources 表（libraryType=prompt）
func (s *Service) GeneratePrompt(ctx context.Context, userID string, req GeneratePromptRequest) (*Resource, error) {
	if s.promptGen == nil {
		return nil, fmt.Errorf("%w: LLM 未配置", pkg.ErrBadRequest)
	}
	libraryType := req.LibraryType
	if libraryType == "" {
		libraryType = "prompt"
	}
	if err := validateLibraryType(libraryType); err != nil {
		return nil, err
	}
	systemPrompt := `你是一位专业的 AI 提示词生成助手。根据用户的指令生成高质量、可直接用于 AI 图像/视频生成的提示词。
输出规则：直接输出生成的提示词内容，不要加引号、标签或额外格式。使用中文输出，除非用户明确要求其他语言。`
	if req.Language != "" {
		systemPrompt += "\n请使用" + req.Language + "输出。"
	}
	result, err := s.promptGen.Chat(ctx, systemPrompt, req.Instruction)
	if err != nil {
		return nil, fmt.Errorf("LLM 生成失败: %w", err)
	}
	name := req.Name
	if name == "" {
		name = "生成提示词"
	}
	r := &Resource{
		UserID:         userID,
		Name:           name,
		LibraryType:    libraryType,
		Modality:       "text",
		ThumbnailURL:   "",
		TagsJSON:       orEmpty(req.TagsJSON, "[]"),
		MetadataJSON:   fmt.Sprintf(`{"category":"%s","targetModel":"%s"}`, req.Category, req.TargetModel),
		BindingIdsJSON: "[]",
		Description:    result,
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

func orEmpty(s, def string) string {
	if s == "" {
		return def
	}
	return s
}

// Get 获取素材详情
func (s *Service) Get(ctx context.Context, id, userID string) (*Resource, error) {
	return s.data.GetByIDAndUser(ctx, id, userID)
}

// List 分页列表
func (s *Service) List(ctx context.Context, userID string, req ListRequest) (*ListResponse, error) {
	if err := validateModality(req.Modality); err != nil {
		return nil, err
	}
	if err := validateLibraryType(req.LibraryType); err != nil {
		return nil, err
	}
	sortBy := req.SortBy
	if sortBy == "" {
		sortBy = "newest"
	}
	if !validSortBy[sortBy] {
		return nil, fmt.Errorf("%w: 无效的排序方式 %s", pkg.ErrBadRequest, sortBy)
	}
	page := req.Page
	if page < 1 {
		page = 1
	}
	pageSize := req.PageSize
	if pageSize < 1 || pageSize > 100 {
		pageSize = 50
	}
	opts := ListDataOpts{
		Modality:    req.Modality,
		LibraryType: req.LibraryType,
		TagsOverlap: TagsToOverlapJSON(req.Tags),
		Search:      strings.TrimSpace(req.Search),
		SortBy:      sortBy,
		Offset:      int32((page - 1) * pageSize),
		Limit:       int32(pageSize),
	}
	items, total, err := s.data.List(ctx, userID, opts)
	if err != nil {
		return nil, err
	}
	return &ListResponse{Items: items, Total: total, Page: page, Size: pageSize}, nil
}

// Update 更新素材
func (s *Service) Update(ctx context.Context, id, userID string, req UpdateRequest) (*Resource, error) {
	r, err := s.data.GetByIDAndUser(ctx, id, userID)
	if err != nil {
		return nil, err
	}
	if req.Name != nil {
		r.Name = *req.Name
	}
	if req.LibraryType != nil {
		if err := validateLibraryType(*req.LibraryType); err != nil {
			return nil, err
		}
		r.LibraryType = *req.LibraryType
	}
	if req.Modality != nil {
		if err := validateModality(*req.Modality); err != nil {
			return nil, err
		}
		r.Modality = *req.Modality
	}
	if req.ThumbnailURL != nil {
		r.ThumbnailURL = *req.ThumbnailURL
	}
	if req.TagsJSON != nil {
		if err := validateJSON(*req.TagsJSON, "tagsJson"); err != nil {
			return nil, err
		}
		r.TagsJSON = *req.TagsJSON
	}
	if req.Version != nil {
		r.Version = *req.Version
	}
	if req.MetadataJSON != nil {
		if err := validateJSON(*req.MetadataJSON, "metadataJson"); err != nil {
			return nil, err
		}
		r.MetadataJSON = *req.MetadataJSON
	}
	if req.BindingIdsJSON != nil {
		if err := validateJSON(*req.BindingIdsJSON, "bindingIdsJson"); err != nil {
			return nil, err
		}
		r.BindingIdsJSON = *req.BindingIdsJSON
	}
	if req.Description != nil {
		r.Description = *req.Description
	}
	if err := s.data.Update(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// Delete 软删除素材
func (s *Service) Delete(ctx context.Context, id, userID string) error {
	_, err := s.data.GetByIDAndUser(ctx, id, userID)
	if err != nil {
		return err
	}
	return s.data.SoftDelete(ctx, id, userID)
}

// Counts 各子库数量统计
func (s *Service) Counts(ctx context.Context, userID, modality string) (*CountsResponse, error) {
	if err := validateModality(modality); err != nil {
		return nil, err
	}
	counts, err := s.data.CountByLibraryType(ctx, userID, modality)
	if err != nil {
		return nil, err
	}
	return &CountsResponse{Counts: counts}, nil
}

// promptToCosyVoiceID 将音色描述映射到 CosyVoice 预设音色 ID（cosyvoice-v1 兼容）
func promptToCosyVoiceID(prompt string) string {
	p := strings.ToLower(strings.TrimSpace(prompt))
	m := map[string]string{
		"少女": "longxiaochun", "甜美": "longxiaochun", "娇气": "longxiaochun", "萝莉": "longxiaochun", "可爱": "longxiaochun",
		"少年": "longanyang", "阳光": "longanyang", "男孩": "longanyang", "男声": "longanyang",
		"元气": "longanhuan", "欢脱": "longanhuan", "活泼": "longanhuan", "女声": "longanhuan",
	}
	for k, v := range m {
		if strings.Contains(p, k) {
			return v
		}
	}
	return "longxiaochun"
}

// GeneratePreviewText 根据音色描述生成适合试听的示例文本
func (s *Service) GeneratePreviewText(ctx context.Context, req GeneratePreviewTextRequest) (string, error) {
	if s.promptGen == nil {
		return "", fmt.Errorf("%w: LLM 未配置", pkg.ErrBadRequest)
	}
	systemPrompt := `你是一位配音试听文本生成助手。根据用户描述的音色特征，生成 1-2 句适合该音色试听的示例文本。
要求：自然口语化、能体现音色特点；直接输出文本，不要加引号或说明。`
	result, err := s.promptGen.Chat(ctx, systemPrompt, req.VoicePrompt)
	if err != nil {
		return "", fmt.Errorf("LLM 生成失败: %w", err)
	}
	return strings.TrimSpace(result), nil
}

// GenerateVoice 音色克隆：根据音频样本克隆音色并写入素材库
func (s *Service) GenerateVoice(ctx context.Context, userID string, req GenerateVoiceRequest) (*Resource, error) {
	if s.voiceClone == nil {
		return nil, fmt.Errorf("%w: 音色克隆服务未配置", pkg.ErrBadRequest)
	}
	if err := validateJSON(req.TagsJSON, "tags_json"); err != nil {
		return nil, err
	}

	// 获取待克隆音频
	audio, filename, err := s.fetchSampleAudio(ctx, req.SampleURL)
	if err != nil {
		return nil, fmt.Errorf("获取音频样本失败: %w", err)
	}

	previewText := req.PreviewText
	if previewText == "" {
		previewText = "你好，这是一段试听音频。"
	}
	model := req.Model
	if model == "" {
		model = "speech-2.8-hd"
	}

	result, err := s.voiceClone.Clone(ctx, capability.VoiceCloneRequest{
		SampleAudio:   audio,
		SampleFilename: filename,
		PreviewText:   previewText,
		Model:         model,
	})
	if err != nil {
		return nil, fmt.Errorf("音色克隆失败: %w", err)
	}

	metadata := fmt.Sprintf(`{"provider":"%s","voiceId":"%s","audioUrl":"%s"}`,
		result.Provider, result.VoiceID, result.DemoURL)
	r := &Resource{
		UserID:         userID,
		Name:           req.Name,
		LibraryType:    "voice",
		Modality:       "audio",
		ThumbnailURL:   result.DemoURL,
		TagsJSON:       orEmpty(req.TagsJSON, "[]"),
		MetadataJSON:   metadata,
		BindingIdsJSON: "[]",
		Description:    req.Description,
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// fetchSampleAudio 从 URL 获取音频：支持 HTTP(S) 或存储路径（/files/xxx）
func (s *Service) fetchSampleAudio(ctx context.Context, url string) ([]byte, string, error) {
	// 存储路径：/files/voice/xxx 或 base/voice/xxx
	if s.store != nil {
		var path string
		if strings.HasPrefix(url, "/files/") {
			path = strings.TrimPrefix(url, "/files/")
		} else if base := s.store.BaseURL(); base != "" && strings.HasPrefix(url, base) {
			path = strings.TrimPrefix(strings.TrimPrefix(url, base), "/")
		} else {
			path = ""
		}
		if path != "" {
			rc, err := s.store.Get(ctx, path)
			if err == nil {
				defer rc.Close()
				data, err := io.ReadAll(rc)
				if err != nil {
					return nil, "", err
				}
				parts := strings.Split(path, "/")
				fn := "audio.mp3"
				if len(parts) > 0 {
					fn = parts[len(parts)-1]
				}
				return data, fn, nil
			}
		}
	}
	if strings.HasPrefix(url, "http://") || strings.HasPrefix(url, "https://") {
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
		if err != nil {
			return nil, "", err
		}
		if s.voiceCloneHTTP == nil {
			s.voiceCloneHTTP = &http.Client{Timeout: 60 * time.Second}
		}
		resp, err := s.voiceCloneHTTP.Do(req)
		if err != nil {
			return nil, "", err
		}
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusOK {
			return nil, "", fmt.Errorf("HTTP %d", resp.StatusCode)
		}
		data, err := io.ReadAll(resp.Body)
		if err != nil {
			return nil, "", err
		}
		filename := "audio.mp3"
		if ct := resp.Header.Get("Content-Disposition"); strings.Contains(ct, "filename=") {
			if idx := strings.Index(ct, "filename="); idx >= 0 {
				filename = strings.Trim(strings.TrimPrefix(ct[idx:], "filename="), "\"")
			}
		}
		return data, filename, nil
	}
	return nil, "", fmt.Errorf("%w: sample_url 须为 http(s) URL 或存储路径（如 /files/voice/xxx）", pkg.ErrBadRequest)
}

// GenerateVoiceDesign 音色设计：根据文本描述选择 TTS 预设音色，生成预览音频并写入素材库
func (s *Service) GenerateVoiceDesign(ctx context.Context, userID string, req GenerateVoiceDesignRequest) (*Resource, error) {
	if s.ttsCap == nil {
		return nil, fmt.Errorf("%w: TTS 服务未配置", pkg.ErrBadRequest)
	}
	voiceID := req.VoiceID
	if voiceID == "" {
		voiceID = promptToCosyVoiceID(req.Prompt)
	}
	previewText := req.PreviewText
	if previewText == "" {
		previewText = "你好，这是一段试听音频。"
	}
	ttsReq := capability.TTSRequest{
		Text:    previewText,
		VoiceID: voiceID,
		Model:   req.Model,
	}
	providerName, taskID, err := s.ttsCap.Submit(ctx, ttsReq, req.Provider)
	if err != nil {
		return nil, fmt.Errorf("TTS 提交失败: %w", err)
	}
	// 轮询等待完成（最多 60 秒）
	var audioURL string
	for i := 0; i < 30; i++ {
		time.Sleep(2 * time.Second)
		res, err := s.ttsCap.Query(ctx, taskID)
		if err != nil {
			return nil, fmt.Errorf("TTS 查询失败: %w", err)
		}
		if res.Status == "completed" && res.AudioURL != "" {
			audioURL = res.AudioURL
			break
		}
		if res.Status == "failed" {
			return nil, fmt.Errorf("%w: TTS 生成失败: %s", pkg.ErrBadRequest, res.Error)
		}
	}
	if audioURL == "" {
		return nil, fmt.Errorf("%w: TTS 生成超时", pkg.ErrBadRequest)
	}
	metadata := fmt.Sprintf(`{"provider":"%s","voiceId":"%s","audioUrl":"%s"}`, providerName, voiceID, audioURL)
	r := &Resource{
		UserID:         userID,
		Name:           req.Name,
		LibraryType:    "voice",
		Modality:       "audio",
		ThumbnailURL:   "",
		TagsJSON:       orEmpty(req.TagsJSON, "[]"),
		MetadataJSON:   metadata,
		BindingIdsJSON: "[]",
		Description:    req.Description,
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// GenerateImage 调用图生能力，写入 resources 表并返回
func (s *Service) GenerateImage(ctx context.Context, userID string, req GenerateImageRequest) (*Resource, error) {
	if s.imageGen == nil {
		return nil, fmt.Errorf("%w: 图生服务未配置", pkg.ErrBadRequest)
	}
	libraryType := req.LibraryType
	if libraryType == "" {
		libraryType = "style"
	}
	modality := req.Modality
	if modality == "" {
		modality = "visual"
	}
	if err := validateLibraryType(libraryType); err != nil {
		return nil, err
	}
	if err := validateModality(modality); err != nil {
		return nil, err
	}
	imgReq := capability.ImageRequest{
		Prompt:         req.Prompt,
		NegativePrompt: req.NegativePrompt,
		Model:          req.Model,
		Width:          req.Width,
		Height:         req.Height,
		AspectRatio:    req.AspectRatio,
	}
	if req.ReferenceImageURL != "" {
		imgReq.ReferenceImageURLs = []string{req.ReferenceImageURL}
	}
	providerName, taskID, err := s.imageGen.Submit(ctx, imgReq, req.Provider)
	if err != nil {
		return nil, fmt.Errorf("图生提交失败: %w", err)
	}
	// 轮询等待完成（最多 60 秒）
	var thumbnailURL string
	for i := 0; i < 30; i++ {
		time.Sleep(2 * time.Second)
		result, err = s.imageGen.Query(ctx, taskID)
		if err != nil {
			return nil, fmt.Errorf("图生查询失败: %w", err)
		}
		if result.Status == "completed" && len(result.URLs) > 0 {
			thumbnailURL = result.URLs[0]
			break
		}
		if result.Status == "failed" {
			return nil, fmt.Errorf("%w: 图生失败: %s", pkg.ErrBadRequest, result.Error)
		}
	}
	if thumbnailURL == "" {
		return nil, fmt.Errorf("%w: 图生超时", pkg.ErrBadRequest)
	}
	name := req.Name
	if name == "" {
		name = "生成图片"
	}
	r := &Resource{
		UserID:        userID,
		Name:          name,
		LibraryType:   libraryType,
		Modality:      modality,
		ThumbnailURL:  thumbnailURL,
		TagsJSON:      "[]",
		MetadataJSON:  fmt.Sprintf(`{"provider":"%s","model":"%s"}`, providerName, req.Model),
		BindingIdsJSON: "[]",
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}
