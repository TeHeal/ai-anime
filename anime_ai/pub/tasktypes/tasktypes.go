// Package tasktypes 定义 Asynq 任务类型常量，供 worker 路由与入队使用。
package tasktypes

const (
	// TypeImageGeneration 镜图/角色图/场景图生成
	TypeImageGeneration = "gen:image"
	// TypeVideoGeneration 镜头视频生成
	TypeVideoGeneration = "gen:video"
	// TypeCharacterGeneration 角色形象生成
	TypeCharacterGeneration = "gen:character"
	// TypeTTS 语音合成
	TypeTTS = "gen:tts"
	// TypeVoiceClone 声音克隆
	TypeVoiceClone = "gen:voice_clone"
	// TypeMusicGeneration 音乐生成
	TypeMusicGeneration = "gen:music"
	// TypeExport 成片导出
	TypeExport = "gen:export"
	// TypePackage 按集打包 ZIP
	TypePackage = "gen:package"
	// TypeScriptParse 脚本解析
	TypeScriptParse = "gen:script_parse"
	// TypeStoryboardGenerate 分镜生成
	TypeStoryboardGenerate = "gen:storyboard"

	// --- 素材库资源生成（无 project 归属） ---

	// TypeResourceVoiceDesign 素材库音色设计
	TypeResourceVoiceDesign = "gen:res_voice_design"
	// TypeResourceVoiceClone 素材库音色克隆
	TypeResourceVoiceClone = "gen:res_voice_clone"
	// TypeResourceImage 素材库图片生成
	TypeResourceImage = "gen:res_image"
	// TypeResourceText 素材库提示词生成
	TypeResourceText = "gen:res_text"
)
