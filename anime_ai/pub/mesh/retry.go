package mesh

import (
	"context"
	"time"

	"github.com/TeHeal/ai-anime/anime_ai/pub/capability"
)

func shouldRetry(err error) bool {
	switch capability.CodeOf(err) {
	case capability.ErrTimeout, capability.ErrRateLimited, capability.ErrUpstream:
		return true
	default:
		return false
	}
}

func withRetry(ctx context.Context, rp RetryPolicy, fn func(context.Context) error) error {
	attempts := rp.MaxAttempts
	if attempts <= 0 {
		attempts = 1
	}
	var err error
	for i := 0; i < attempts; i++ {
		err = fn(ctx)
		if err == nil {
			return nil
		}
		if !shouldRetry(err) || i == attempts-1 {
			return err
		}
		delay := 200 * time.Millisecond
		if i < len(rp.Backoff) {
			delay = rp.Backoff[i]
		}
		select {
		case <-ctx.Done():
			return capability.Wrap(capability.ErrTimeout, "retry canceled", ctx.Err())
		case <-time.After(delay):
		}
	}
	return err
}
