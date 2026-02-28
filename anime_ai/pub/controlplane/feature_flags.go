package controlplane

import (
	"os"

	"gopkg.in/yaml.v3"
)

// FeatureFlags 特性开关配置
type FeatureFlags struct {
	Providers      map[string]bool   `yaml:"providers"`
	Capabilities   map[string]bool   `yaml:"capabilities"`
	ForceProviders map[string]string `yaml:"force_providers"`
	FailProviders  []string          `yaml:"fail_providers"`
}

// LoadFeatureFlags 从 YAML 文件加载特性开关
func LoadFeatureFlags(path string) (*FeatureFlags, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var f FeatureFlags
	if err := yaml.Unmarshal(b, &f); err != nil {
		return nil, err
	}
	return &f, nil
}

// IsProviderEnabled 判断 Provider 是否启用
func (f *FeatureFlags) IsProviderEnabled(name string) bool {
	if f == nil || f.Providers == nil {
		return true
	}
	v, ok := f.Providers[name]
	if !ok {
		return true
	}
	return v
}

// IsCapabilityEnabled 判断能力是否启用
func (f *FeatureFlags) IsCapabilityEnabled(name string) bool {
	if f == nil || f.Capabilities == nil {
		return true
	}
	v, ok := f.Capabilities[name]
	if !ok {
		return true
	}
	return v
}

// ForcedProvider 获取强制指定的 Provider
func (f *FeatureFlags) ForcedProvider(capability string) string {
	if f == nil || f.ForceProviders == nil {
		return ""
	}
	return f.ForceProviders[capability]
}
