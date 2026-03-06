package bootstrap

import (
	"log"

	"anime_ai/pub/config"
	"anime_ai/pub/mesh"
	"anime_ai/pub/provider"
	"anime_ai/pub/provider/audio"
	"anime_ai/pub/provider/image"
	"anime_ai/pub/provider/kie"
	"anime_ai/pub/provider/llm"
	"anime_ai/pub/provider/music"
	"anime_ai/pub/provider/video"
)

// initLLM 按优先级注册 LLM Provider
func initLLM(cfg *config.Config) *llm.LLMService {
	var providers []provider.LLMProvider
	if cfg.LLM.DeepSeekKey != "" {
		providers = append(providers, llm.NewDeepSeekProvider(cfg.LLM.DeepSeekKey))
		log.Println("LLM Provider 已注册: deepseek")
	}
	if cfg.LLM.KimiKey != "" {
		providers = append(providers, llm.NewKimiProvider(cfg.LLM.KimiKey))
		log.Println("LLM Provider 已注册: kimi")
	}
	if cfg.LLM.DoubaoKey != "" {
		providers = append(providers, llm.NewDoubaoProvider(cfg.LLM.DoubaoKey))
		log.Println("LLM Provider 已注册: doubao")
	}
	svc := llm.NewLLMService(providers...)
	if svc.Available() {
		log.Printf("LLM 服务就绪，可用 Provider: %v", svc.ProviderNames())
	} else {
		log.Println("LLM 服务未配置 API Key，AI 辅助功能将不可用")
	}
	return svc
}

// initImageRouter 注册文生图 Provider
func initImageRouter(cfg *config.Config) *mesh.ImageRouter {
	policy := mesh.DefaultPolicy()
	breaker := mesh.NewBreaker(3)
	router := mesh.NewImageRouter(policy, breaker)
	if cfg.Image.SeedreamKey != "" {
		router.RegisterProvider(image.NewSeedreamProvider(cfg.Image.SeedreamKey))
	}
	if cfg.Image.WanxKey != "" {
		router.RegisterProvider(image.NewWanxProvider(cfg.Image.WanxKey))
	}
	if cfg.KIE.APIKey != "" {
		router.RegisterProvider(kie.NewKIEImageProvider(cfg.KIE.APIKey))
	}
	return router
}

// initMusicRouter 注册音乐 Provider
func initMusicRouter(cfg *config.Config) *mesh.MusicRouter {
	policy := mesh.DefaultPolicy()
	breaker := mesh.NewBreaker(3)
	router := mesh.NewMusicRouter(policy, breaker)
	if cfg.KIE.APIKey != "" {
		router.RegisterProvider(music.NewKieMusicProvider(cfg.KIE.APIKey))
	}
	if cfg.Music.SunoKey != "" {
		router.RegisterProvider(music.NewSunoProvider(cfg.Music.SunoKey, cfg.Music.SunoBaseURL))
	}
	return router
}

// initVideoRouter 注册文生视频 Provider
func initVideoRouter(cfg *config.Config) *mesh.VideoRouter {
	policy := mesh.DefaultPolicy()
	breaker := mesh.NewBreaker(3)
	router := mesh.NewVideoRouter(policy, breaker)
	if cfg.Video.SeedanceKey != "" {
		router.RegisterProvider(video.NewSeedanceProvider(cfg.Video.SeedanceKey))
	}
	return router
}

// initTTSRouter 注册 TTS Provider
func initTTSRouter(cfg *config.Config) *mesh.TTSRouter {
	policy := mesh.DefaultPolicy()
	breaker := mesh.NewBreaker(3)
	router := mesh.NewTTSRouter(policy, breaker)
	if cfg.TTS.MiniMaxKey != "" {
		router.RegisterProvider(audio.NewMiniMaxTTSProvider(cfg.TTS.MiniMaxKey))
		log.Println("TTS Provider 已注册: minimax_tts")
	}
	if cfg.TTS.VolcengineKey != "" {
		router.RegisterProvider(audio.NewVolcengineTTSProvider(cfg.TTS.VolcengineKey, cfg.TTS.VolcengineAppID))
		log.Println("TTS Provider 已注册: volcengine_tts")
	}
	return router
}
