package resource

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

// VoiceDesignProvider 音色设计能力接口（文生音色，如 MiniMax /v1/voice_design）
// 与 TTS（预设音色+合成）不同，此为「根据文本描述生成新音色」的官方 API
type VoiceDesignProvider interface {
	Name() string
	Design(ctx context.Context, req capability.VoiceDesignRequest) (*capability.VoiceDesignResult, error)
}

// SystemVoiceLister 系统音色列表能力（如 MiniMax get_voice）
type SystemVoiceLister interface {
	ListSystemVoices(ctx context.Context, provider string) ([]capability.SystemVoiceItem, error)
}

// TTSSyncProvider 同步 TTS 合成（短文本试听用）
type TTSSyncProvider interface {
	SynthesizeSync(ctx context.Context, req capability.TTSRequest) (audioBytes []byte, err error)
}

// Service 素材库业务逻辑层
type Service struct {
	data              Data
	imageGen          ImageGen
	promptGen         PromptGen
	ttsCap            TTSCapability
	ttsSyncProvider   TTSSyncProvider    // 同步 TTS（系统音色试听）
	voiceClone        VoiceCloneProvider
	voiceDesign       VoiceDesignProvider
	systemVoiceLister SystemVoiceLister
	store             storage.Storage
	voiceCloneHTTP    *http.Client
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

// SetVoiceDesignProvider 注入音色设计能力（文生音色，如 MiniMax /v1/voice_design）
func (s *Service) SetVoiceDesignProvider(p VoiceDesignProvider) {
	s.voiceDesign = p
}

// SetSystemVoiceLister 注入系统音色列表能力（如 MiniMax get_voice）
func (s *Service) SetSystemVoiceLister(l SystemVoiceLister) {
	s.systemVoiceLister = l
}

// SetTTSSyncProvider 注入同步 TTS 能力（系统音色试听）
func (s *Service) SetTTSSyncProvider(p TTSSyncProvider) {
	s.ttsSyncProvider = p
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

// CreatePromptPlaceholder 创建提示词占位 Resource
func (s *Service) CreatePromptPlaceholder(ctx context.Context, userID string, req GeneratePromptRequest) (*Resource, error) {
	libraryType := req.LibraryType
	if libraryType == "" {
		libraryType = "prompt"
	}
	if err := validateLibraryType(libraryType); err != nil {
		return nil, err
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
		TagsJSON:       orEmpty(req.TagsJSON, "[]"),
		MetadataJSON:   fmt.Sprintf(`{"_genStatus":"generating","category":"%s","targetModel":"%s"}`, req.Category, req.TargetModel),
		BindingIdsJSON: "[]",
		Description:    req.Description,
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// CompletePrompt 后台完成 LLM 提示词生成，更新占位 Resource
func (s *Service) CompletePrompt(ctx context.Context, userID, resourceID string, req GeneratePromptRequest) (*Resource, error) {
	if s.promptGen == nil {
		return nil, fmt.Errorf("%w: LLM 未配置", pkg.ErrBadRequest)
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

	r, err := s.data.GetByIDAndUser(ctx, resourceID, userID)
	if err != nil {
		return nil, fmt.Errorf("查询占位资源失败: %w", err)
	}
	r.MetadataJSON = fmt.Sprintf(`{"category":"%s","targetModel":"%s"}`, req.Category, req.TargetModel)
	r.Description = result
	if err := s.data.Update(ctx, r); err != nil {
		return nil, fmt.Errorf("更新资源失败: %w", err)
	}
	return r, nil
}

// GeneratePrompt 调用 LLM 生成提示词（保留同步接口，兼容其他模块）
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
	resp := &ListResponse{Items: items, Total: total, Page: page, Size: pageSize}

	// 音色库且请求包含系统音色时，合并 MiniMax 等系统音色
	if req.IncludeSystemVoices && req.LibraryType == "voice" && req.Modality == "audio" && s.systemVoiceLister != nil {
		svList, err := s.systemVoiceLister.ListSystemVoices(ctx, "minimax")
		if err == nil && len(svList) > 0 {
			resp.SystemVoices = make([]Resource, 0, len(svList))
			for _, sv := range svList {
				meta := map[string]string{
					"provider": sv.Provider,
					"voiceId":  sv.VoiceID,
					"source":   "system",
				}
				metaJSON, _ := json.Marshal(meta)
				resp.SystemVoices = append(resp.SystemVoices, Resource{
					ID:           "system_" + sv.Provider + "_" + sv.VoiceID,
					Name:         sv.VoiceName,
					LibraryType:  "voice",
					Modality:     "audio",
					MetadataJSON: string(metaJSON),
					Description:  sv.Description,
				})
			}
		}
	}
	return resp, nil
}

// GetSystemVoicePreview 获取系统音色试听 URL
// 优先走同步 TTS（t2a_v2，2~5s），缓存到存储后返回 URL
func (s *Service) GetSystemVoicePreview(ctx context.Context, provider, voiceID string) (string, error) {
	if s.store == nil {
		return "", fmt.Errorf("%w: 存储未配置", pkg.ErrBadRequest)
	}
	if voiceID == "" {
		return "", fmt.Errorf("%w: voiceId 不能为空", pkg.ErrBadRequest)
	}
	if provider != "minimax" && !strings.Contains(strings.ToLower(provider), "minimax") {
		return "", fmt.Errorf("%w: 暂仅支持 MiniMax 系统音色试听", pkg.ErrBadRequest)
	}

	// 缓存命中直接返回
	storagePath := fmt.Sprintf("voice/preview/minimax/%s.mp3", voiceID)
	if s.store.Exists(ctx, storagePath) {
		base := s.store.BaseURL()
		if base != "" {
			return strings.TrimSuffix(base, "/") + "/" + storagePath, nil
		}
		return "/files/" + storagePath, nil
	}

	// 同步 TTS 合成试听（t2a_v2，直接返回音频字节）
	if s.ttsSyncProvider == nil {
		return "", fmt.Errorf("%w: 同步 TTS 未配置", pkg.ErrBadRequest)
	}
	previewText := "你好，这是一段试听音频，用于展示当前音色的效果。"
	ttsReq := capability.TTSRequest{Text: previewText, VoiceID: voiceID, Model: "speech-2.8-hd"}
	audioBytes, err := s.ttsSyncProvider.SynthesizeSync(ctx, ttsReq)
	if err != nil {
		return "", fmt.Errorf("同步 TTS 合成失败: %w", err)
	}

	url, err := s.store.Put(ctx, storagePath, bytes.NewReader(audioBytes), "audio/mpeg")
	if err != nil {
		return "", fmt.Errorf("保存试听音频失败: %w", err)
	}
	return url, nil
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

// promptToMiniMaxVoiceID 将音色描述映射到 MiniMax 预设音色 ID（speech-2.8 系列）
// 参考：https://platform.minimaxi.com/docs/faq/system-voice-id
func promptToMiniMaxVoiceID(prompt string) string {
	p := strings.ToLower(strings.TrimSpace(prompt))
	m := map[string]string{
		"少女": "female-shaonv", "甜美": "female-tianmei", "温柔": "female-shaonv", "娇气": "female-tianmei",
		"萝莉": "lovely_girl", "可爱": "lovely_girl",
		"少年": "male-qn-qingse", "阳光": "male-qn-daxuesheng", "男孩": "male-qn-qingse", "男声": "male-qn-jingying",
		"元气": "qiaopi_mengmei", "欢脱": "qiaopi_mengmei", "活泼": "qiaopi_mengmei", "女声": "female-shaonv",
		"御姐": "female-yujie", "成熟": "female-chengshu", "精英": "male-qn-jingying", "霸道": "male-qn-badao",
	}
	for k, v := range m {
		if strings.Contains(p, k) {
			return v
		}
	}
	return "female-shaonv"
}

// promptToVoiceIDForProvider 根据 TTS Provider 将音色描述映射到对应预设音色 ID
func promptToVoiceIDForProvider(prompt, provider string) string {
	return promptToMiniMaxVoiceID(prompt)
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

// CreateVoiceClonePlaceholder 创建音色克隆占位 Resource
func (s *Service) CreateVoiceClonePlaceholder(ctx context.Context, userID string, req GenerateVoiceRequest) (*Resource, error) {
	if s.voiceClone == nil {
		return nil, fmt.Errorf("%w: 音色克隆服务未配置", pkg.ErrBadRequest)
	}
	if err := validateJSON(req.TagsJSON, "tags_json"); err != nil {
		return nil, err
	}
	r := &Resource{
		UserID:         userID,
		Name:           req.Name,
		LibraryType:    "voice",
		Modality:       "audio",
		TagsJSON:       orEmpty(req.TagsJSON, "[]"),
		MetadataJSON:   `{"_genStatus":"generating"}`,
		BindingIdsJSON: "[]",
		Description:    req.Description,
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// CompleteVoiceClone 后台完成音色克隆，更新占位 Resource
func (s *Service) CompleteVoiceClone(ctx context.Context, userID, resourceID string, req GenerateVoiceRequest) (*Resource, error) {
	if s.voiceClone == nil {
		return nil, fmt.Errorf("%w: 音色克隆服务未配置", pkg.ErrBadRequest)
	}
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
		SampleAudio:    audio,
		SampleFilename: filename,
		PreviewText:    previewText,
		Model:          model,
	})
	if err != nil {
		return nil, fmt.Errorf("音色克隆失败: %w", err)
	}

	r, err := s.data.GetByIDAndUser(ctx, resourceID, userID)
	if err != nil {
		return nil, fmt.Errorf("查询占位资源失败: %w", err)
	}
	r.MetadataJSON = fmt.Sprintf(`{"provider":"%s","voiceId":"%s","audioUrl":"%s"}`,
		result.Provider, result.VoiceID, result.DemoURL)
	r.ThumbnailURL = result.DemoURL
	if err := s.data.Update(ctx, r); err != nil {
		return nil, fmt.Errorf("更新资源失败: %w", err)
	}
	return r, nil
}

// GenerateVoice 音色克隆（同步，保留兼容）
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

// GenerateVoiceDesign 音色设计：根据 provider 分流
// - MiniMax：使用官方 /v1/voice_design（文生音色，同步返回）
// - 其他 TTS：使用预设音色映射 + 合成
func (s *Service) GenerateVoiceDesign(ctx context.Context, userID string, req GenerateVoiceDesignRequest) (*Resource, error) {
	previewText := req.PreviewText
	if previewText == "" {
		previewText = "你好，这是一段试听音频。"
	}

	// MiniMax：使用官方音色设计 API（文生音色）
	if s.voiceDesign != nil && strings.Contains(strings.ToLower(req.Provider), "minimax") {
		return s.generateVoiceDesignMinimax(ctx, userID, req, previewText)
	}

	// 其他 TTS Provider：使用预设音色映射 + 合成
	return s.generateVoiceDesignTTS(ctx, userID, req, previewText)
}

// generateVoiceDesignMinimax 调用 MiniMax /v1/voice_design，同步返回新音色 + 试听音频
func (s *Service) generateVoiceDesignMinimax(ctx context.Context, userID string, req GenerateVoiceDesignRequest, previewText string) (*Resource, error) {
	if s.store == nil {
		return nil, fmt.Errorf("%w: 存储未配置，无法保存试听音频", pkg.ErrBadRequest)
	}
	vdReq := capability.VoiceDesignRequest{
		Prompt:      req.Prompt,
		PreviewText: previewText,
		VoiceID:     req.VoiceID,
	}
	result, err := s.voiceDesign.Design(ctx, vdReq)
	if err != nil {
		return nil, fmt.Errorf("音色设计失败: %w", err)
	}
	var audioURL string
	if len(result.AudioData) > 0 {
		storagePath := fmt.Sprintf("resource/generated/voice_design_%d.mp3", time.Now().UnixNano())
		url, err := s.store.Put(ctx, storagePath, bytes.NewReader(result.AudioData), "audio/mpeg")
		if err != nil {
			return nil, fmt.Errorf("保存试听音频失败: %w", err)
		}
		audioURL = url
	}
	metadata := fmt.Sprintf(`{"provider":"%s","voiceId":"%s","audioUrl":"%s"}`, result.Provider, result.VoiceID, audioURL)
	r := &Resource{
		UserID:         userID,
		Name:           req.Name,
		LibraryType:    "voice",
		Modality:       "audio",
		ThumbnailURL:   audioURL,
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

// generateVoiceDesignTTS 使用 TTS 预设音色合成
// 优先走同步 TTS 直接拿到音频字节，避免在 HTTP handler 中阻塞轮询
func (s *Service) generateVoiceDesignTTS(ctx context.Context, userID string, req GenerateVoiceDesignRequest, previewText string) (*Resource, error) {
	voiceID := req.VoiceID
	if voiceID == "" {
		voiceID = promptToVoiceIDForProvider(req.Prompt, req.Provider)
	}
	ttsReq := capability.TTSRequest{
		Text:    previewText,
		VoiceID: voiceID,
		Model:   req.Model,
	}

	// 优先使用同步 TTS（直接返回音频字节，无需轮询）
	if s.ttsSyncProvider != nil {
		audioBytes, err := s.ttsSyncProvider.SynthesizeSync(ctx, ttsReq)
		if err != nil {
			return nil, fmt.Errorf("同步 TTS 合成失败: %w", err)
		}
		storagePath := fmt.Sprintf("resource/generated/tts_%d.mp3", time.Now().UnixNano())
		audioURL, err := s.store.Put(ctx, storagePath, bytes.NewReader(audioBytes), "audio/mpeg")
		if err != nil {
			return nil, fmt.Errorf("保存 TTS 音频失败: %w", err)
		}
		return s.saveVoiceDesignResource(ctx, userID, req, "sync_tts", voiceID, audioURL)
	}

	// 回退：异步 TTS（仅当无同步 provider 时）
	if s.ttsCap == nil {
		return nil, fmt.Errorf("%w: TTS 服务未配置", pkg.ErrBadRequest)
	}
	providerName, taskID, err := s.ttsCap.Submit(ctx, ttsReq, req.Provider)
	if err != nil {
		return nil, fmt.Errorf("TTS 提交失败: %w", err)
	}
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
	return s.saveVoiceDesignResource(ctx, userID, req, providerName, voiceID, audioURL)
}

func (s *Service) saveVoiceDesignResource(ctx context.Context, userID string, req GenerateVoiceDesignRequest, provider, voiceID, audioURL string) (*Resource, error) {
	metadata := fmt.Sprintf(`{"provider":"%s","voiceId":"%s","audioUrl":"%s"}`, provider, voiceID, audioURL)
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

// CreateVoiceDesignPlaceholder 创建占位 Resource（metadata 含 _genStatus=generating），立即返回
func (s *Service) CreateVoiceDesignPlaceholder(ctx context.Context, userID string, req GenerateVoiceDesignRequest) (*Resource, error) {
	metadata := fmt.Sprintf(`{"_genStatus":"generating","provider":"%s","voiceId":"","audioUrl":""}`, req.Provider)
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

// CompleteVoiceDesign 在后台 goroutine 中完成 TTS 合成，更新已有的占位 Resource
func (s *Service) CompleteVoiceDesign(ctx context.Context, userID, resourceID string, req GenerateVoiceDesignRequest) (*Resource, error) {
	previewText := req.PreviewText
	if previewText == "" {
		previewText = "你好，这是一段试听音频。"
	}

	var provider, voiceID, audioURL string

	// MiniMax 音色设计 API
	if s.voiceDesign != nil && strings.Contains(strings.ToLower(req.Provider), "minimax") {
		if s.store == nil {
			return nil, fmt.Errorf("%w: 存储未配置", pkg.ErrBadRequest)
		}
		result, err := s.voiceDesign.Design(ctx, capability.VoiceDesignRequest{
			Prompt:      req.Prompt,
			PreviewText: previewText,
			VoiceID:     req.VoiceID,
		})
		if err != nil {
			return nil, fmt.Errorf("音色设计失败: %w", err)
		}
		provider = result.Provider
		voiceID = result.VoiceID
		if len(result.AudioData) > 0 {
			storagePath := fmt.Sprintf("resource/generated/voice_design_%d.mp3", time.Now().UnixNano())
			url, err := s.store.Put(ctx, storagePath, bytes.NewReader(result.AudioData), "audio/mpeg")
			if err != nil {
				return nil, fmt.Errorf("保存试听音频失败: %w", err)
			}
			audioURL = url
		}
	} else {
		// 其他 TTS 路径
		vid := req.VoiceID
		if vid == "" {
			vid = promptToVoiceIDForProvider(req.Prompt, req.Provider)
		}
		ttsReq := capability.TTSRequest{
			Text:    previewText,
			VoiceID: vid,
			Model:   req.Model,
		}
		if s.ttsSyncProvider != nil {
			audioBytes, err := s.ttsSyncProvider.SynthesizeSync(ctx, ttsReq)
			if err != nil {
				return nil, fmt.Errorf("TTS 合成失败: %w", err)
			}
			storagePath := fmt.Sprintf("resource/generated/tts_%d.mp3", time.Now().UnixNano())
			url, err := s.store.Put(ctx, storagePath, bytes.NewReader(audioBytes), "audio/mpeg")
			if err != nil {
				return nil, fmt.Errorf("保存 TTS 音频失败: %w", err)
			}
			provider = "sync_tts"
			voiceID = vid
			audioURL = url
		} else if s.ttsCap != nil {
			provName, taskID, err := s.ttsCap.Submit(ctx, ttsReq, req.Provider)
			if err != nil {
				return nil, fmt.Errorf("TTS 提交失败: %w", err)
			}
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
					return nil, fmt.Errorf("TTS 生成失败: %s", res.Error)
				}
			}
			if audioURL == "" {
				return nil, fmt.Errorf("TTS 生成超时")
			}
			provider = provName
			voiceID = vid
		} else {
			return nil, fmt.Errorf("%w: TTS 服务未配置", pkg.ErrBadRequest)
		}
	}

	// 更新占位 Resource：填入实际音频数据，移除 _genStatus
	r, err := s.data.GetByIDAndUser(ctx, resourceID, userID)
	if err != nil {
		return nil, fmt.Errorf("查询占位资源失败: %w", err)
	}
	r.MetadataJSON = fmt.Sprintf(`{"provider":"%s","voiceId":"%s","audioUrl":"%s"}`, provider, voiceID, audioURL)
	r.ThumbnailURL = audioURL
	if err := s.data.Update(ctx, r); err != nil {
		return nil, fmt.Errorf("更新资源失败: %w", err)
	}
	return r, nil
}

// MarkResourceGenFailed 标记资源生成失败
func (s *Service) MarkResourceGenFailed(ctx context.Context, resourceID, userID, errMsg string) error {
	r, err := s.data.GetByIDAndUser(ctx, resourceID, userID)
	if err != nil {
		return err
	}
	r.MetadataJSON = fmt.Sprintf(`{"_genStatus":"failed","_genError":"%s"}`, errMsg)
	return s.data.Update(ctx, r)
}

// CreateImagePlaceholder 创建图生占位 Resource
func (s *Service) CreateImagePlaceholder(ctx context.Context, userID string, req GenerateImageRequest) (*Resource, error) {
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
	name := req.Name
	if name == "" {
		name = "生成图片"
	}
	r := &Resource{
		UserID:         userID,
		Name:           name,
		LibraryType:    libraryType,
		Modality:       modality,
		ThumbnailURL:   "",
		TagsJSON:       "[]",
		MetadataJSON:   fmt.Sprintf(`{"_genStatus":"generating","provider":"%s","model":"%s"}`, req.Provider, req.Model),
		BindingIdsJSON: "[]",
	}
	if err := s.data.Create(ctx, r); err != nil {
		return nil, err
	}
	return r, nil
}

// CompleteImage 在后台完成图生，更新占位 Resource
func (s *Service) CompleteImage(ctx context.Context, userID, resourceID string, req GenerateImageRequest) (*Resource, error) {
	if s.imageGen == nil {
		return nil, fmt.Errorf("%w: 图生服务未配置", pkg.ErrBadRequest)
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
	result, err := s.imageGen.Query(ctx, taskID)
	if err != nil {
		return nil, fmt.Errorf("图生查询失败: %w", err)
	}
	if result.Status == "failed" {
		return nil, fmt.Errorf("图生失败: %s", result.Error)
	}
	if len(result.URLs) == 0 {
		return nil, fmt.Errorf("图生未返回结果")
	}
	thumbnailURL := result.URLs[0]
	if s.store != nil && (strings.HasPrefix(thumbnailURL, "http://") || strings.HasPrefix(thumbnailURL, "https://")) {
		if localURL, dlErr := s.downloadToLocal(ctx, thumbnailURL, taskID); dlErr == nil {
			thumbnailURL = localURL
		}
	}

	r, err := s.data.GetByIDAndUser(ctx, resourceID, userID)
	if err != nil {
		return nil, fmt.Errorf("查询占位资源失败: %w", err)
	}
	r.ThumbnailURL = thumbnailURL
	r.MetadataJSON = fmt.Sprintf(`{"provider":"%s","model":"%s"}`, providerName, req.Model)
	if err := s.data.Update(ctx, r); err != nil {
		return nil, fmt.Errorf("更新资源失败: %w", err)
	}
	return r, nil
}

// GenerateImage 调用图生能力，写入 resources 表并返回（保留兼容，镜头生成等场景仍用同步模式）
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
	// Submit 内部已通过 SSE 流式等待结果，直接 Query 取回
	result, err := s.imageGen.Query(ctx, taskID)
	if err != nil {
		return nil, fmt.Errorf("图生查询失败: %w", err)
	}
	if result.Status == "failed" {
		return nil, fmt.Errorf("%w: 图生失败: %s", pkg.ErrBadRequest, result.Error)
	}
	if len(result.URLs) == 0 {
		return nil, fmt.Errorf("%w: 图生未返回结果", pkg.ErrBadRequest)
	}
	remoteURL := result.URLs[0]

	// 将外部临时 URL 下载到本地存储（火山 CDN 链接 24h 过期且存在 CORS 限制）
	thumbnailURL := remoteURL
	if s.store != nil && (strings.HasPrefix(remoteURL, "http://") || strings.HasPrefix(remoteURL, "https://")) {
		localURL, dlErr := s.downloadToLocal(ctx, remoteURL, taskID)
		if dlErr == nil {
			thumbnailURL = localURL
		}
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

// downloadToLocal 将远程图片下载到本地存储
func (s *Service) downloadToLocal(ctx context.Context, remoteURL, taskID string) (string, error) {
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, remoteURL, nil)
	if err != nil {
		return "", fmt.Errorf("创建下载请求: %w", err)
	}
	client := &http.Client{Timeout: 60 * time.Second}
	resp, err := client.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("下载图片: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("下载返回状态 %d", resp.StatusCode)
	}

	ext := ".png"
	ct := resp.Header.Get("Content-Type")
	if strings.Contains(ct, "jpeg") {
		ext = ".jpg"
	} else if strings.Contains(ct, "webp") {
		ext = ".webp"
	}

	storagePath := fmt.Sprintf("resource/generated/%s%s", taskID, ext)
	localURL, err := s.store.Put(ctx, storagePath, resp.Body, ct)
	if err != nil {
		return "", fmt.Errorf("存储写入: %w", err)
	}
	return localURL, nil
}
