package pkg

import (
	"archive/zip"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
)

// ZipFiles 将文件列表打包为 ZIP（§2.7 按集打包下载）
func ZipFiles(outputPath string, files map[string]string) error {
	zipFile, err := os.Create(outputPath)
	if err != nil {
		return fmt.Errorf("创建 ZIP 文件失败: %w", err)
	}
	defer zipFile.Close()

	w := zip.NewWriter(zipFile)
	defer w.Close()

	for name, srcPath := range files {
		if err := addFileToZip(w, name, srcPath); err != nil {
			return fmt.Errorf("添加文件 %s 到 ZIP 失败: %w", name, err)
		}
	}
	return nil
}

func addFileToZip(w *zip.Writer, name, srcPath string) error {
	f, err := os.Open(srcPath)
	if err != nil {
		return err
	}
	defer f.Close()

	info, err := f.Stat()
	if err != nil {
		return err
	}

	header, err := zip.FileInfoHeader(info)
	if err != nil {
		return err
	}
	header.Name = name
	header.Method = zip.Deflate

	writer, err := w.CreateHeader(header)
	if err != nil {
		return err
	}
	_, err = io.Copy(writer, f)
	return err
}

// DownloadFile 下载远程文件到本地路径
func DownloadFile(url, destPath string) error {
	dir := filepath.Dir(destPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("创建目录失败: %w", err)
	}

	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("下载失败: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("下载返回非 200 状态: %d", resp.StatusCode)
	}

	out, err := os.Create(destPath)
	if err != nil {
		return fmt.Errorf("创建文件失败: %w", err)
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	return err
}
