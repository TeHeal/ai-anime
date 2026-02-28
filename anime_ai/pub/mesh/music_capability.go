package mesh

import (
	"context"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

// MusicCapability 音乐生成能力封装
type MusicCapability struct {
	router *MusicRouter
}

// NewMusicCapability 创建音乐生成能力
func NewMusicCapability(router *MusicRouter) *MusicCapability {
	return &MusicCapability{router: router}
}

// Submit 提交音乐生成任务
func (c *MusicCapability) Submit(ctx context.Context, req capability.MusicRequest, preferred string) (string, string, error) {
	return c.router.Submit(ctx, req, preferred)
}

// Query 查询音乐生成任务结果
func (c *MusicCapability) Query(ctx context.Context, taskID string) (*capability.MusicResult, error) {
	return c.router.Query(ctx, taskID)
}
