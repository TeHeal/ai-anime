package pkg

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// FFmpegConcatConfig 视频拼接配置
type FFmpegConcatConfig struct {
	InputFiles []string // 输入视频文件路径列表
	OutputFile string   // 输出文件路径
	Resolution string   // 分辨率（如 "1920x1080"）
	Format     string   // 输出格式（如 "mp4"）
}

// FFmpegCompositeConfig 成片合成配置
type FFmpegCompositeConfig struct {
	VideoFile    string   // 主视频文件
	AudioFiles   []string // 音频轨道文件列表
	SubtitleFile string   // 字幕文件路径（SRT/ASS）
	OutputFile   string   // 输出文件路径
	Resolution   string   // 分辨率
}

// ConcatVideos 拼接多段视频（使用 concat demuxer）
func ConcatVideos(cfg FFmpegConcatConfig) error {
	if len(cfg.InputFiles) == 0 {
		return fmt.Errorf("输入文件列表为空")
	}

	// 创建 concat 文件列表
	listFile := cfg.OutputFile + ".list.txt"
	var lines []string
	for _, f := range cfg.InputFiles {
		absPath, _ := filepath.Abs(f)
		lines = append(lines, fmt.Sprintf("file '%s'", absPath))
	}
	if err := os.WriteFile(listFile, []byte(strings.Join(lines, "\n")), 0644); err != nil {
		return fmt.Errorf("创建 concat 列表失败: %w", err)
	}
	defer os.Remove(listFile)

	args := []string{
		"-y", "-f", "concat", "-safe", "0",
		"-i", listFile,
		"-c", "copy",
	}
	if cfg.Resolution != "" {
		parts := strings.Split(cfg.Resolution, "x")
		if len(parts) == 2 {
			args = append(args, "-vf", fmt.Sprintf("scale=%s:%s", parts[0], parts[1]))
			// 重编码以适配分辨率
			args[len(args)-3] = "-c:v"
			args[len(args)-2] = "libx264"
		}
	}
	args = append(args, cfg.OutputFile)

	cmd := exec.Command("ffmpeg", args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("ffmpeg concat 失败: %w, 输出: %s", err, string(output))
	}
	return nil
}

// CompositeVideo 合成成片（视频+音频+字幕）
func CompositeVideo(cfg FFmpegCompositeConfig) error {
	if cfg.VideoFile == "" {
		return fmt.Errorf("主视频文件不能为空")
	}

	args := []string{"-y", "-i", cfg.VideoFile}

	// 添加音频输入
	for _, af := range cfg.AudioFiles {
		args = append(args, "-i", af)
	}

	// 构建 filter_complex 混音
	if len(cfg.AudioFiles) > 0 {
		// 视频流 + 所有音频流混合
		audioInputs := ""
		for i := range cfg.AudioFiles {
			audioInputs += fmt.Sprintf("[%d:a]", i+1)
		}
		if len(cfg.AudioFiles) > 1 {
			args = append(args, "-filter_complex",
				fmt.Sprintf("%samix=inputs=%d:duration=longest", audioInputs, len(cfg.AudioFiles)))
		}
		args = append(args, "-c:v", "copy")
	} else {
		args = append(args, "-c", "copy")
	}

	// 添加字幕
	if cfg.SubtitleFile != "" {
		args = append(args, "-vf", fmt.Sprintf("subtitles='%s'", cfg.SubtitleFile))
		// 字幕需要重编码视频
		for i, a := range args {
			if a == "-c:v" && i+1 < len(args) && args[i+1] == "copy" {
				args[i+1] = "libx264"
			}
			if a == "-c" && i+1 < len(args) && args[i+1] == "copy" {
				args[i] = "-c:v"
				args[i+1] = "libx264"
				args = append(args[:i+2], append([]string{"-c:a", "aac"}, args[i+2:]...)...)
				break
			}
		}
	}

	args = append(args, cfg.OutputFile)

	cmd := exec.Command("ffmpeg", args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("ffmpeg composite 失败: %w, 输出: %s", err, string(output))
	}
	return nil
}

// GetVideoDuration 获取视频时长（秒）
func GetVideoDuration(filePath string) (float64, error) {
	cmd := exec.Command("ffprobe",
		"-v", "error",
		"-show_entries", "format=duration",
		"-of", "default=noprint_wrappers=1:nokey=1",
		filePath,
	)
	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("ffprobe 失败: %w", err)
	}
	var duration float64
	_, err = fmt.Sscanf(strings.TrimSpace(string(output)), "%f", &duration)
	return duration, err
}
