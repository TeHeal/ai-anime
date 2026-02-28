package episode

// PackageConfig 按集打包下载配置（README 生成物下载，可配置）
// 用户可选择打包内容：镜图、配音、音色、成片等
type PackageConfig struct {
	IncludeShotImages bool `json:"include_shot_images"` // 镜图
	IncludeVoices     bool `json:"include_voices"`      // 音色/配音
	IncludeShots      bool `json:"include_shots"`       // 镜头视频
	IncludeFinal      bool `json:"include_final"`       // 成片
}

// DefaultPackageConfig 默认全选
func DefaultPackageConfig() PackageConfig {
	return PackageConfig{
		IncludeShotImages: true,
		IncludeVoices:     true,
		IncludeShots:      true,
		IncludeFinal:      true,
	}
}
