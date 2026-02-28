package provider

import (
	"fmt"
	"sync"
)

// Registry 按名称注册的 Provider 集合
type Registry struct {
	mu     sync.RWMutex
	llms   map[string]LLMProvider
	images map[string]ImageProvider
	videos map[string]VideoProvider
	tts    map[string]TTSProvider
	music  map[string]MusicProvider
}

// NewRegistry 创建 Registry
func NewRegistry() *Registry {
	return &Registry{
		llms:   make(map[string]LLMProvider),
		images: make(map[string]ImageProvider),
		videos: make(map[string]VideoProvider),
		tts:    make(map[string]TTSProvider),
		music:  make(map[string]MusicProvider),
	}
}

// RegisterLLM 注册 LLM Provider
func (r *Registry) RegisterLLM(p LLMProvider) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.llms[p.Name()] = p
}

// GetLLM 获取 LLM Provider
func (r *Registry) GetLLM(name string) (LLMProvider, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	p, ok := r.llms[name]
	if !ok {
		return nil, fmt.Errorf("LLM provider not found: %s", name)
	}
	return p, nil
}

// RegisterImage 注册 Image Provider
func (r *Registry) RegisterImage(p ImageProvider) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.images[p.Name()] = p
}

// GetImage 获取 Image Provider
func (r *Registry) GetImage(name string) (ImageProvider, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	p, ok := r.images[name]
	if !ok {
		return nil, fmt.Errorf("image provider not found: %s", name)
	}
	return p, nil
}

// RegisterVideo 注册 Video Provider
func (r *Registry) RegisterVideo(p VideoProvider) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.videos[p.Name()] = p
}

// GetVideo 获取 Video Provider
func (r *Registry) GetVideo(name string) (VideoProvider, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	p, ok := r.videos[name]
	if !ok {
		return nil, fmt.Errorf("video provider not found: %s", name)
	}
	return p, nil
}

// RegisterTTS 注册 TTS Provider
func (r *Registry) RegisterTTS(p TTSProvider) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.tts[p.Name()] = p
}

// GetTTS 获取 TTS Provider
func (r *Registry) GetTTS(name string) (TTSProvider, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	p, ok := r.tts[name]
	if !ok {
		return nil, fmt.Errorf("TTS provider not found: %s", name)
	}
	return p, nil
}

// RegisterMusic 注册 Music Provider
func (r *Registry) RegisterMusic(p MusicProvider) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.music[p.Name()] = p
}

// GetMusic 获取 Music Provider
func (r *Registry) GetMusic(name string) (MusicProvider, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	p, ok := r.music[name]
	if !ok {
		return nil, fmt.Errorf("music provider not found: %s", name)
	}
	return p, nil
}

// ListLLMs 列出所有 LLM Provider 名称
func (r *Registry) ListLLMs() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	names := make([]string, 0, len(r.llms))
	for k := range r.llms {
		names = append(names, k)
	}
	return names
}

// ListImages 列出所有 Image Provider 名称
func (r *Registry) ListImages() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	names := make([]string, 0, len(r.images))
	for k := range r.images {
		names = append(names, k)
	}
	return names
}

// GetFirstImage 获取第一个 Image Provider
func (r *Registry) GetFirstImage() (ImageProvider, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	for _, p := range r.images {
		return p, nil
	}
	return nil, fmt.Errorf("no image provider registered")
}

// ListVideos 列出所有 Video Provider 名称
func (r *Registry) ListVideos() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	names := make([]string, 0, len(r.videos))
	for k := range r.videos {
		names = append(names, k)
	}
	return names
}

// ListMusic 列出所有 Music Provider 名称
func (r *Registry) ListMusic() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	names := make([]string, 0, len(r.music))
	for k := range r.music {
		names = append(names, k)
	}
	return names
}

// ListTTS 列出所有 TTS Provider 名称
func (r *Registry) ListTTS() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	names := make([]string, 0, len(r.tts))
	for k := range r.tts {
		names = append(names, k)
	}
	return names
}
