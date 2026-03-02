// Package ffmpeg 封装 FFmpeg CLI 操作，供成片导出 Worker 使用。
package ffmpeg

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	"go.uber.org/zap"
)

// AudioTrack 音频轨道配置（用于 MixAudio）
type AudioTrack struct {
	Path    string  // 音频文件路径
	StartMs int64   // 起始时间（毫秒）
	Volume  float64 // 音量（0.0~1.0，1.0 为原始音量）
}

var log *zap.Logger

func init() {
	log, _ = zap.NewProduction()
}

// SetLogger 设置日志实例（由调用方注入）
func SetLogger(l *zap.Logger) {
	if l != nil {
		log = l.Named("ffmpeg")
	}
}

// ConcatVideos 使用 FFmpeg concat demuxer 拼接视频文件
// 输入文件按顺序拼接，输出到 outputPath
func ConcatVideos(ctx context.Context, inputPaths []string, outputPath string) error {
	if len(inputPaths) == 0 {
		return fmt.Errorf("输入文件列表为空")
	}
	if len(inputPaths) == 1 {
		return copyFile(inputPaths[0], outputPath)
	}

	// 创建 concat 列表文件
	listFile := outputPath + ".concat.txt"
	var sb strings.Builder
	for _, p := range inputPaths {
		absPath, err := filepath.Abs(p)
		if err != nil {
			return fmt.Errorf("获取绝对路径失败 %s: %w", p, err)
		}
		sb.WriteString(fmt.Sprintf("file '%s'\n", absPath))
	}
	if err := os.WriteFile(listFile, []byte(sb.String()), 0o644); err != nil {
		return fmt.Errorf("创建 concat 列表文件失败: %w", err)
	}
	defer os.Remove(listFile)

	args := []string{
		"-y",
		"-f", "concat",
		"-safe", "0",
		"-i", listFile,
		"-c", "copy",
		outputPath,
	}

	return runFFmpeg(ctx, args, "ConcatVideos")
}

// BurnSubtitles 将 SRT/ASS 字幕烧录到视频中
func BurnSubtitles(ctx context.Context, videoPath, subtitlePath, outputPath string) error {
	if videoPath == "" || subtitlePath == "" {
		return fmt.Errorf("视频或字幕路径为空")
	}

	// 使用 subtitles filter 烧录字幕（需转义路径中的特殊字符）
	escapedSub := strings.ReplaceAll(subtitlePath, ":", "\\:")
	escapedSub = strings.ReplaceAll(escapedSub, "'", "\\'")

	args := []string{
		"-y",
		"-i", videoPath,
		"-vf", fmt.Sprintf("subtitles='%s'", escapedSub),
		"-c:a", "copy",
		outputPath,
	}

	return runFFmpeg(ctx, args, "BurnSubtitles")
}

// MixAudio 混合多条音频轨道到视频中
func MixAudio(ctx context.Context, videoPath string, tracks []AudioTrack, outputPath string) error {
	if videoPath == "" {
		return fmt.Errorf("视频路径为空")
	}
	if len(tracks) == 0 {
		return copyFile(videoPath, outputPath)
	}

	args := []string{"-y", "-i", videoPath}

	// 添加每条音频轨道作为输入
	for _, t := range tracks {
		args = append(args, "-i", t.Path)
	}

	// 构建 filter_complex：为每条音轨设置延迟和音量
	var filters []string
	var amixInputs []string
	for i, t := range tracks {
		inputIdx := i + 1
		label := fmt.Sprintf("a%d", i)
		delayMs := t.StartMs
		vol := t.Volume
		if vol <= 0 {
			vol = 1.0
		}
		filters = append(filters,
			fmt.Sprintf("[%d:a]adelay=%d|%d,volume=%.2f[%s]",
				inputIdx, delayMs, delayMs, vol, label))
		amixInputs = append(amixInputs, fmt.Sprintf("[%s]", label))
	}

	// 原视频音频 + 新音轨混合
	amixInputStr := "[0:a]" + strings.Join(amixInputs, "")
	mixCount := len(tracks) + 1
	filters = append(filters,
		fmt.Sprintf("%samix=inputs=%d:duration=longest[out]", amixInputStr, mixCount))

	filterComplex := strings.Join(filters, ";")
	args = append(args,
		"-filter_complex", filterComplex,
		"-map", "0:v",
		"-map", "[out]",
		"-c:v", "copy",
		outputPath,
	)

	return runFFmpeg(ctx, args, "MixAudio")
}

// GenerateThumbnail 从视频指定时间提取缩略图
func GenerateThumbnail(ctx context.Context, videoPath string, atSecond float64, outputPath string) error {
	if videoPath == "" {
		return fmt.Errorf("视频路径为空")
	}

	args := []string{
		"-y",
		"-ss", fmt.Sprintf("%.2f", atSecond),
		"-i", videoPath,
		"-vframes", "1",
		"-q:v", "2",
		outputPath,
	}

	return runFFmpeg(ctx, args, "GenerateThumbnail")
}

// GetDuration 获取视频/音频文件时长（秒）
func GetDuration(ctx context.Context, filePath string) (float64, error) {
	if filePath == "" {
		return 0, fmt.Errorf("文件路径为空")
	}

	args := []string{
		"-v", "error",
		"-show_entries", "format=duration",
		"-of", "default=noprint_wrappers=1:nokey=1",
		filePath,
	}

	var stdout, stderr bytes.Buffer
	cmd := exec.CommandContext(ctx, "ffprobe", args...)
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	log.Debug("执行 ffprobe", zap.Strings("args", args))
	if err := cmd.Run(); err != nil {
		return 0, fmt.Errorf("ffprobe 执行失败: %w, stderr: %s", err, stderr.String())
	}

	durStr := strings.TrimSpace(stdout.String())
	dur, err := strconv.ParseFloat(durStr, 64)
	if err != nil {
		return 0, fmt.Errorf("解析时长失败: %q: %w", durStr, err)
	}
	return dur, nil
}

// runFFmpeg 执行 FFmpeg 命令，记录 stderr 用于调试
func runFFmpeg(ctx context.Context, args []string, operation string) error {
	var stderr bytes.Buffer
	cmd := exec.CommandContext(ctx, "ffmpeg", args...)
	cmd.Stderr = &stderr

	log.Info("执行 FFmpeg",
		zap.String("operation", operation),
		zap.Strings("args", args),
	)

	if err := cmd.Run(); err != nil {
		errOutput := stderr.String()
		log.Error("FFmpeg 执行失败",
			zap.String("operation", operation),
			zap.String("stderr", errOutput),
			zap.Error(err),
		)
		return fmt.Errorf("ffmpeg %s 失败: %w, stderr: %s", operation, err, errOutput)
	}

	log.Debug("FFmpeg 执行完成", zap.String("operation", operation))
	return nil
}

// copyFile 复制单个文件（当只有一个输入时避免 FFmpeg 调用）
func copyFile(src, dst string) error {
	data, err := os.ReadFile(src)
	if err != nil {
		return fmt.Errorf("读取源文件失败: %w", err)
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("创建输出目录失败: %w", err)
	}
	return os.WriteFile(dst, data, 0o644)
}
