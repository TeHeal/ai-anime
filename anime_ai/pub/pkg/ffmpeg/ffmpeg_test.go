package ffmpeg

import (
	"context"
	"os"
	"path/filepath"
	"testing"
)

func TestConcatVideos_EmptyInput(t *testing.T) {
	err := ConcatVideos(context.Background(), nil, "/tmp/out.mp4")
	if err == nil {
		t.Error("空输入列表应返回错误")
	}
}

func TestConcatVideos_SingleFile(t *testing.T) {
	tmpDir := t.TempDir()
	srcPath := filepath.Join(tmpDir, "src.mp4")
	dstPath := filepath.Join(tmpDir, "dst.mp4")

	if err := os.WriteFile(srcPath, []byte("fake-video-data"), 0o644); err != nil {
		t.Fatal(err)
	}

	if err := ConcatVideos(context.Background(), []string{srcPath}, dstPath); err != nil {
		t.Fatalf("单文件 concat 应成功: %v", err)
	}

	data, err := os.ReadFile(dstPath)
	if err != nil {
		t.Fatal(err)
	}
	if string(data) != "fake-video-data" {
		t.Error("单文件应直接复制")
	}
}

func TestBurnSubtitles_EmptyPaths(t *testing.T) {
	err := BurnSubtitles(context.Background(), "", "", "/tmp/out.mp4")
	if err == nil {
		t.Error("空路径应返回错误")
	}
}

func TestMixAudio_NoTracks(t *testing.T) {
	tmpDir := t.TempDir()
	srcPath := filepath.Join(tmpDir, "src.mp4")
	dstPath := filepath.Join(tmpDir, "dst.mp4")

	if err := os.WriteFile(srcPath, []byte("fake-video-data"), 0o644); err != nil {
		t.Fatal(err)
	}

	// 无音轨时应直接复制
	err := MixAudio(context.Background(), srcPath, nil, dstPath)
	if err != nil {
		t.Fatalf("无音轨应直接复制: %v", err)
	}

	data, err := os.ReadFile(dstPath)
	if err != nil {
		t.Fatal(err)
	}
	if string(data) != "fake-video-data" {
		t.Error("无音轨应直接复制内容")
	}
}

func TestGenerateThumbnail_EmptyPath(t *testing.T) {
	err := GenerateThumbnail(context.Background(), "", 0, "/tmp/out.jpg")
	if err == nil {
		t.Error("空路径应返回错误")
	}
}

func TestGetDuration_EmptyPath(t *testing.T) {
	_, err := GetDuration(context.Background(), "")
	if err == nil {
		t.Error("空路径应返回错误")
	}
}

func TestIsHTTPURL(t *testing.T) {
	// 使用 worker 包中的 isHTTPURL 间接测试；这里只测 copyFile
	tmpDir := t.TempDir()
	srcPath := filepath.Join(tmpDir, "a.txt")
	dstPath := filepath.Join(tmpDir, "sub", "b.txt")

	if err := os.WriteFile(srcPath, []byte("test"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := copyFile(srcPath, dstPath); err != nil {
		t.Fatalf("copyFile: %v", err)
	}
	data, err := os.ReadFile(dstPath)
	if err != nil {
		t.Fatal(err)
	}
	if string(data) != "test" {
		t.Error("copyFile 内容不匹配")
	}
}
