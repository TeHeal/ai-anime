// Package controlplane 特性开关、模型目录、路由策略
package controlplane

import (
	"os"

	"gopkg.in/yaml.v3"
)

// RoutePolicy 路由策略配置
type RoutePolicy struct {
	Version      int                            `yaml:"version"`
	Capabilities map[string]CapabilityRouteRule `yaml:"capabilities"`
}

// RetryRule 重试规则
type RetryRule struct {
	MaxAttempts int   `yaml:"max_attempts"`
	BackoffMS   []int `yaml:"backoff_ms"`
}

// CapabilityRouteRule 单能力路由规则
type CapabilityRouteRule struct {
	PrimaryChain []string  `yaml:"primary_chain"`
	TimeoutMS    int       `yaml:"timeout_ms"`
	Retry        RetryRule `yaml:"retry"`
}

// LoadRoutePolicy 从 YAML 文件加载路由策略
func LoadRoutePolicy(path string) (*RoutePolicy, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var p RoutePolicy
	if err := yaml.Unmarshal(b, &p); err != nil {
		return nil, err
	}
	return &p, nil
}
