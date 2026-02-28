package cache

import (
	"context"
	"encoding/json"
	"time"

	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
)

// RedisCache Redis 缓存封装（§8.5 缓存策略：热点数据缓存 + 写时失效）
type RedisCache struct {
	client *redis.Client
	logger *zap.Logger
}

// NewRedisCache 创建 Redis 缓存实例
func NewRedisCache(addr, password string, db int, logger *zap.Logger) *RedisCache {
	client := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
		DB:       db,
	})
	return &RedisCache{client: client, logger: logger}
}

// Get 从缓存获取数据，反序列化到 dest
func (c *RedisCache) Get(ctx context.Context, key string, dest interface{}) error {
	val, err := c.client.Get(ctx, key).Bytes()
	if err != nil {
		return err
	}
	return json.Unmarshal(val, dest)
}

// Set 设置缓存（带 TTL）
func (c *RedisCache) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
	data, err := json.Marshal(value)
	if err != nil {
		return err
	}
	return c.client.Set(ctx, key, data, ttl).Err()
}

// Delete 写时失效：删除缓存（数据更新时调用）
func (c *RedisCache) Delete(ctx context.Context, keys ...string) error {
	if len(keys) == 0 {
		return nil
	}
	return c.client.Del(ctx, keys...).Err()
}

// DeleteByPattern 按模式删除缓存（如 project:123:*）
func (c *RedisCache) DeleteByPattern(ctx context.Context, pattern string) error {
	iter := c.client.Scan(ctx, 0, pattern, 100).Iterator()
	var keys []string
	for iter.Next(ctx) {
		keys = append(keys, iter.Val())
	}
	if err := iter.Err(); err != nil {
		return err
	}
	if len(keys) > 0 {
		return c.client.Del(ctx, keys...).Err()
	}
	return nil
}

// ProjectListKey 项目列表缓存 key
func ProjectListKey(userID string) string {
	return "cache:projects:" + userID
}

// ProjectKey 项目详情缓存 key
func ProjectKey(projectID string) string {
	return "cache:project:" + projectID
}

// CharacterListKey 角色列表缓存 key
func CharacterListKey(projectID string) string {
	return "cache:characters:" + projectID
}
