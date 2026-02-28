// Package worker 提供 Asynq 异步任务服务初始化与 Redis 连接。
package worker

import (
	"context"
	"time"

	"github.com/hibiken/asynq"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
)

// NewServer 创建 Asynq Server，用于消费 Redis 队列中的任务。
func NewServer(redisAddr, redisPassword string, redisDB int, log *zap.Logger) *asynq.Server {
	return asynq.NewServer(
		asynq.RedisClientOpt{
			Addr:     redisAddr,
			Password: redisPassword,
			DB:       redisDB,
		},
		asynq.Config{
			Concurrency: 10,
			Queues: map[string]int{
				"critical": 5,
				"default":  3,
				"low":      1,
			},
			Logger: newAsynqLogger(log),
		},
	)
}

// NewClient 创建 Asynq Client，用于向 Redis 队列入队任务。
func NewClient(redisAddr, redisPassword string, redisDB int) *asynq.Client {
	return asynq.NewClient(asynq.RedisClientOpt{
		Addr:     redisAddr,
		Password: redisPassword,
		DB:       redisDB,
	})
}

// asynqLogger 将 asynq 日志转发到 zap。
type asynqLogger struct {
	log *zap.Logger
}

func newAsynqLogger(log *zap.Logger) *asynqLogger {
	return &asynqLogger{log: log.Named("asynq")}
}

func (l *asynqLogger) Debug(args ...interface{}) { l.log.Sugar().Debug(args...) }
func (l *asynqLogger) Info(args ...interface{})  { l.log.Sugar().Info(args...) }
func (l *asynqLogger) Warn(args ...interface{})  { l.log.Sugar().Warn(args...) }
func (l *asynqLogger) Error(args ...interface{}) { l.log.Sugar().Error(args...) }
func (l *asynqLogger) Fatal(args ...interface{}) { l.log.Sugar().Fatal(args...) }

// PingRedis 检测 Redis 是否可用。
func PingRedis(addr, password string, db int) bool {
	rdb := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
		DB:       db,
	})
	defer rdb.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	return rdb.Ping(ctx).Err() == nil
}
