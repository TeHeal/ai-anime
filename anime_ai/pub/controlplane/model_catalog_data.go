package controlplane

// ModelCatalogAPIItem 模型目录 API 响应项，与 Flutter ModelCatalogItem 契约一致
type ModelCatalogAPIItem struct {
	ID           int    `json:"id"`
	Operator     string `json:"operator"`
	OperatorLabel string `json:"operator_label"`
	Brand        string `json:"brand"`
	ModelID      string `json:"model_id"`
	DisplayName  string `json:"display_name"`
	Service      string `json:"service"`
	Priority     int    `json:"priority"`
	Features     string `json:"features"`
	BestFor      string `json:"best_for"`
	ProviderName string `json:"provider_name"`
}

// ListResponse 模型目录列表响应
type ListResponse struct {
	Items []ModelCatalogAPIItem `json:"items"`
}

// ServiceAliases 前端 serviceType 到后端 canonical service 的映射
func ServiceAliases() map[string]string {
	return map[string]string{
		"image_gen":   "image",
		"video_gen":   "video",
		"music_gen":   "music",
		"voice_clone": "tts",
	}
}

// BuildModelCatalog 构建内置模型目录，与实际 Provider 对齐
func BuildModelCatalog() []ModelCatalogAPIItem {
	// 按 service 分组，id 全局递增以保持稳定
	id := 0
	nextID := func() int {
		id++
		return id
	}

	return []ModelCatalogAPIItem{
		// ── 文生图 (image) ──
		{
			ID:            nextID(),
			Operator:      "seedream",
			OperatorLabel: "火山即梦 | Volcengine Seedream",
			Brand:         "seedream",
			ModelID:       "doubao-seedream-4-5-251128",
			DisplayName:   "即梦 4.5 | Seedream 4.5",
			Service:       "image",
			Priority:      100,
			Features:      "text2img,img2img",
			BestFor:       "anime,character",
			ProviderName:  "volcengine",
		},
		{
			ID:            nextID(),
			Operator:      "kie",
			OperatorLabel: "KIE",
			Brand:         "flux",
			ModelID:       "flux-pro-1.1",
			DisplayName:   "Flux 专业版 1.1 | Flux Pro 1.1",
			Service:       "image",
			Priority:      100,
			Features:      "text2img,img2img",
			BestFor:       "anime,general",
			ProviderName:  "kie",
		},
		{
			ID:            nextID(),
			Operator:      "kie",
			OperatorLabel: "KIE",
			Brand:         "flux",
			ModelID:       "flux-flex",
			DisplayName:   "Flux 灵活版 | Flux Flex",
			Service:       "image",
			Priority:      50,
			Features:      "text2img",
			BestFor:       "fast,explore",
			ProviderName:  "kie",
		},
		{
			ID:            nextID(),
			Operator:      "kie",
			OperatorLabel: "KIE",
			Brand:         "seedream",
			ModelID:       "seedream-3.0",
			DisplayName:   "即梦 3.0 | Seedream 3.0",
			Service:       "image",
			Priority:      50,
			Features:      "text2img,img2img",
			BestFor:       "anime",
			ProviderName:  "kie",
		},
		// ── 视频 (video) ──
		{
			ID:            nextID(),
			Operator:      "seedance",
			OperatorLabel: "字节可灵 | Volcengine Seedance",
			Brand:         "seedance",
			ModelID:       "seedance-1.5-pro",
			DisplayName:   "可灵 1.5 专业版 | Seedance 1.5 Pro",
			Service:       "video",
			Priority:      100,
			Features:      "text2video,img2video",
			BestFor:       "anime,video",
			ProviderName:  "volcengine",
		},
		{
			ID:            nextID(),
			Operator:      "seedance",
			OperatorLabel: "字节可灵 | Volcengine Seedance",
			Brand:         "seedance",
			ModelID:       "seedance-1.0-pro",
			DisplayName:   "可灵 1.0 专业版 | Seedance 1.0 Pro",
			Service:       "video",
			Priority:      80,
			Features:      "text2video,img2video",
			BestFor:       "video",
			ProviderName:  "volcengine",
		},
		{
			ID:            nextID(),
			Operator:      "seedance",
			OperatorLabel: "字节可灵 | Volcengine Seedance",
			Brand:         "seedance",
			ModelID:       "seedance-1.0-lite-i2v",
			DisplayName:   "可灵 1.0 轻量图生视频 | Seedance 1.0 Lite I2V",
			Service:       "video",
			Priority:      50,
			Features:      "img2video",
			BestFor:       "img2video",
			ProviderName:  "volcengine",
		},
		{
			ID:            nextID(),
			Operator:      "kie_video",
			OperatorLabel: "KIE Video",
			Brand:         "runway",
			ModelID:       "runway/gen3a_turbo",
			DisplayName:   "Runway Gen3a 极速版 | Runway Gen3a Turbo",
			Service:       "video",
			Priority:      70,
			Features:      "text2video,img2video",
			BestFor:       "video",
			ProviderName:  "kie",
		},
		{
			ID:            nextID(),
			Operator:      "kie_video",
			OperatorLabel: "KIE Video",
			Brand:         "kling",
			ModelID:       "kling-2.6/image-to-video",
			DisplayName:   "可灵 2.6 图生视频 | Kling 2.6 I2V",
			Service:       "video",
			Priority:      60,
			Features:      "img2video",
			BestFor:       "img2video",
			ProviderName:  "kie",
		},
		// ── TTS (tts) ──
		{
			ID:            nextID(),
			Operator:      "minimax_tts",
			OperatorLabel: "MiniMax 语音 | MiniMax TTS",
			Brand:         "minimax",
			ModelID:       "speech-2.8-hd",
			DisplayName:   "语音 2.8 高清版 | Speech 2.8 HD",
			Service:       "tts",
			Priority:      100,
			Features:      "tts,audio",
			BestFor:       "narration,dialogue",
			ProviderName:  "minimax",
		},
		{
			ID:            nextID(),
			Operator:      "minimax_voice_clone",
			OperatorLabel: "MiniMax 声音克隆 | MiniMax Voice Clone",
			Brand:         "minimax",
			ModelID:       "speech-2.8-hd",
			DisplayName:   "声音克隆 | Voice Clone",
			Service:       "tts",
			Priority:      90,
			Features:      "voice_clone,tts",
			BestFor:       "voice_clone",
			ProviderName:  "minimax",
		},
		// ── 音乐 (music) ──
		{
			ID:            nextID(),
			Operator:      "kie",
			OperatorLabel: "KIE 音乐 | KIE Music",
			Brand:         "suno",
			ModelID:       "suno-v4",
			DisplayName:   "孙诺 V4 | Suno V4",
			Service:       "music",
			Priority:      100,
			Features:      "music,bgm",
			BestFor:       "bgm",
			ProviderName:  "kie",
		},
		{
			ID:            nextID(),
			Operator:      "kie",
			OperatorLabel: "KIE 音乐 | KIE Music",
			Brand:         "suno",
			ModelID:       "suno-v4-sfx",
			DisplayName:   "孙诺 V4 音效 | Suno V4 SFX",
			Service:       "music",
			Priority:      80,
			Features:      "music,sfx",
			BestFor:       "sfx",
			ProviderName:  "kie",
		},
		// ── LLM (llm) ──
		{
			ID:            nextID(),
			Operator:      "deepseek",
			OperatorLabel: "深度求索 | DeepSeek",
			Brand:         "deepseek",
			ModelID:       "deepseek-chat",
			DisplayName:   "深度求索对话 | DeepSeek Chat",
			Service:       "llm",
			Priority:      100,
			Features:      "chat,reasoning",
			BestFor:       "script,storyboard",
			ProviderName:  "deepseek",
		},
		{
			ID:            nextID(),
			Operator:      "kimi",
			OperatorLabel: "月之暗面 | Kimi",
			Brand:         "moonshot",
			ModelID:       "moonshot-v1",
			DisplayName:   "月之暗面 | Kimi Moonshot",
			Service:       "llm",
			Priority:      90,
			Features:      "chat,reasoning",
			BestFor:       "script",
			ProviderName:  "moonshot",
		},
		{
			ID:            nextID(),
			Operator:      "doubao",
			OperatorLabel: "豆包 | DouBao",
			Brand:         "doubao",
			ModelID:       "doubao-pro",
			DisplayName:   "豆包专业版 | DouBao Pro",
			Service:       "llm",
			Priority:      80,
			Features:      "chat",
			BestFor:       "script",
			ProviderName:  "volcengine",
		},
	}
}
