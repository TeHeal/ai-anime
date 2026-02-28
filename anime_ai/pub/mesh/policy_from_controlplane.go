package mesh

import (
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/controlplane"
)

// FromRoutePolicy 从 controlplane.RoutePolicy 转换为 mesh.Policy
func FromRoutePolicy(rp *controlplane.RoutePolicy) Policy {
	p := DefaultPolicy()
	if rp == nil || rp.Capabilities == nil {
		return p
	}

	if chat, ok := rp.Capabilities["chat"]; ok {
		if len(chat.PrimaryChain) > 0 {
			p.Chat.PrimaryChain = chat.PrimaryChain
		}
		if chat.TimeoutMS > 0 {
			p.Chat.Timeout = time.Duration(chat.TimeoutMS) * time.Millisecond
		}
		if chat.Retry.MaxAttempts > 0 {
			p.Chat.Retry.MaxAttempts = chat.Retry.MaxAttempts
		}
		if len(chat.Retry.BackoffMS) > 0 {
			backoff := make([]time.Duration, 0, len(chat.Retry.BackoffMS))
			for _, ms := range chat.Retry.BackoffMS {
				if ms > 0 {
					backoff = append(backoff, time.Duration(ms)*time.Millisecond)
				}
			}
			if len(backoff) > 0 {
				p.Chat.Retry.Backoff = backoff
			}
		}
	}

	if image, ok := rp.Capabilities["image"]; ok && len(image.PrimaryChain) > 0 {
		p.Image = image.PrimaryChain
	}
	if video, ok := rp.Capabilities["video"]; ok && len(video.PrimaryChain) > 0 {
		p.Video = video.PrimaryChain
	}
	if tts, ok := rp.Capabilities["tts"]; ok && len(tts.PrimaryChain) > 0 {
		p.TTS = tts.PrimaryChain
	}
	if music, ok := rp.Capabilities["music"]; ok && len(music.PrimaryChain) > 0 {
		p.Music = music.PrimaryChain
	}

	return p
}
