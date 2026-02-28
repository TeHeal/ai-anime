package config

import (
	"fmt"
	"net/url"
	"strings"

	"github.com/spf13/viper"
)

// Config 应用全局配置
type Config struct {
	App     AppConfig
	DB      DBConfig
	Redis   RedisConfig
	Storage StorageConfig
	Admin   AdminConfig
	LLM     LLMConfig
	Image   ImageConfig
	Video   VideoConfig
	TTS     TTSConfig
	Music   MusicConfig
	KIE     KIEConfig
}

// AppConfig 应用基础配置
type AppConfig struct {
	Port   int    `mapstructure:"port"`
	Secret string `mapstructure:"secret"`
	Mode   string `mapstructure:"mode"` // debug, release
}

// DBConfig PostgreSQL 数据库配置
// 优先使用 DSN；若为空则由 Host/Port/User/Password/DBName 组装
type DBConfig struct {
	DSN      string `mapstructure:"dsn"`       // 完整连接串：postgres://user:password@host:port/dbname?sslmode=disable
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	User     string `mapstructure:"user"`
	Password string `mapstructure:"password"`
	DBName   string `mapstructure:"dbname"`
}

// GetDSN 返回 PostgreSQL 连接串，敏感信息建议通过环境变量 APP_DB_PASSWORD 等注入
func (c *DBConfig) GetDSN() string {
	if c.DSN != "" {
		return c.DSN
	}
	port := c.Port
	if port == 0 {
		port = 5432
	}
	host := c.Host
	if host == "" {
		host = "localhost"
	}
	dbname := c.DBName
	if dbname == "" {
		dbname = "ai_anime"
	}
	user := c.User
	if user == "" {
		user = "postgres"
	}
	// 密码含特殊字符时需 URL 编码，建议使用 DSN 或环境变量
	password := url.QueryEscape(c.Password)
	return fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=disable", user, password, host, port, dbname)
}

// RedisConfig Redis 配置
type RedisConfig struct {
	Addr     string `mapstructure:"addr"`
	Password string `mapstructure:"password"`
	DB       int    `mapstructure:"db"`
}

// StorageConfig 文件存储配置
type StorageConfig struct {
	Driver    string `mapstructure:"driver"` // local, s3, oss
	LocalRoot string `mapstructure:"local_root"`
	BaseURL   string `mapstructure:"base_url"`
	// S3/OSS 可选配置（driver=s3 或 oss 时使用）
	Endpoint  string `mapstructure:"endpoint"`
	Bucket    string `mapstructure:"bucket"`
	Region    string `mapstructure:"region"`
	AccessKey string `mapstructure:"access_key"`
	SecretKey string `mapstructure:"secret_key"`
}

// AdminConfig 管理员初始账号（仅用于首次种子数据）
type AdminConfig struct {
	Username string `mapstructure:"username"`
	Password string `mapstructure:"password"`
}

// LLMConfig LLM 服务 API Key
type LLMConfig struct {
	DeepSeekKey string `mapstructure:"deepseek_key"`
	KimiKey     string `mapstructure:"kimi_key"`
	DoubaoKey   string `mapstructure:"doubao_key"`
	AliyunKey   string `mapstructure:"aliyun_key"`
}

// ImageConfig 文生图服务 API Key
type ImageConfig struct {
	SeedreamKey  string `mapstructure:"seedream_key"`
	WanxKey      string `mapstructure:"wanx_key"`
	CogViewKey   string `mapstructure:"cogview_key"`
	FluxKey      string `mapstructure:"flux_key"`
	StabilityKey string `mapstructure:"stability_key"`
}

// VideoConfig 文生视频服务 API Key
type VideoConfig struct {
	RunwayKey   string `mapstructure:"runway_key"`
	SeedanceKey string `mapstructure:"seedance_key"`
	KlingKey    string `mapstructure:"kling_key"`
	CogVideoKey string `mapstructure:"cogvideo_key"`
}

// TTSConfig TTS 服务 API Key
type TTSConfig struct {
	VolcengineKey   string `mapstructure:"volcengine_key"`
	VolcengineAppID string `mapstructure:"volcengine_appid"`
	CosyVoiceKey   string `mapstructure:"cosyvoice_key"`
	FishAudioKey   string `mapstructure:"fish_audio_key"`
	MiniMaxKey     string `mapstructure:"minimax_key"`
}

// MusicConfig 音乐生成服务配置
type MusicConfig struct {
	SunoKey     string `mapstructure:"suno_key"`
	SunoBaseURL string `mapstructure:"suno_base_url"`
}

// KIEConfig 多模态理解服务 API Key
type KIEConfig struct {
	APIKey string `mapstructure:"api_key"`
}

// Load 从 config.yaml 与环境变量加载配置，环境变量以 APP_ 为前缀，点号替换为下划线
func Load() (*Config, error) {
	v := viper.New()

	v.SetConfigName("config")
	v.SetConfigType("yaml")
	v.AddConfigPath(".")
	v.AddConfigPath("./config")

	v.SetEnvPrefix("APP")
	v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	v.AutomaticEnv()

	// 默认值
	v.SetDefault("app.port", 3737)
	v.SetDefault("app.mode", "debug")
	v.SetDefault("app.secret", "change-me-in-production")
	v.SetDefault("db.host", "localhost")
	v.SetDefault("db.port", 5432)
	v.SetDefault("db.user", "postgres")
	v.SetDefault("db.dbname", "ai_anime")
	v.SetDefault("redis.addr", "localhost:6379")
	v.SetDefault("redis.password", "")
	v.SetDefault("redis.db", 0)
	v.SetDefault("storage.driver", "local")
	v.SetDefault("storage.local_root", "./data/uploads")
	v.SetDefault("storage.base_url", "/files")
	v.SetDefault("admin.username", "admin")
	v.SetDefault("admin.password", "admin123")
	v.SetDefault("llm.deepseek_key", "")
	v.SetDefault("llm.kimi_key", "")
	v.SetDefault("llm.doubao_key", "")
	v.SetDefault("llm.aliyun_key", "")
	v.SetDefault("image.seedream_key", "")
	v.SetDefault("image.wanx_key", "")
	v.SetDefault("image.cogview_key", "")
	v.SetDefault("image.flux_key", "")
	v.SetDefault("image.stability_key", "")
	v.SetDefault("video.runway_key", "")
	v.SetDefault("video.seedance_key", "")
	v.SetDefault("video.kling_key", "")
	v.SetDefault("video.cogvideo_key", "")
	v.SetDefault("tts.volcengine_key", "")
	v.SetDefault("tts.volcengine_appid", "")
	v.SetDefault("tts.cosyvoice_key", "")
	v.SetDefault("tts.fish_audio_key", "")
	v.SetDefault("tts.minimax_key", "")
	v.SetDefault("music.suno_key", "")
	v.SetDefault("music.suno_base_url", "")
	v.SetDefault("kie.api_key", "")

	// 尝试读取配置文件，未找到则忽略
	_ = v.ReadInConfig()

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}
