import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'dashed_border_painter.dart';

/// 上传文件类型
enum UploadFileType { image, audio, text }

/// 上传后的文件信息，用于自动填充名称、分辨率等
class UploadFileInfo {
  const UploadFileInfo({required this.fileName, this.resolution});
  final String fileName;
  final String? resolution;
}

/// 通用资产上传区域，支持单文件（图片/音频/文本）上传。
///
/// 包含空态虚线边框、已上传态预览、hover 替换、移除等交互。
class AssetUploadArea extends StatefulWidget {
  const AssetUploadArea({
    super.key,
    required this.fileType,
    this.accentColor,
    this.currentUrl,
    this.label,
    this.onUploaded,
    this.onFileInfo,
    this.onTextContent,
    this.height,
    this.textPreview,
    this.uploadCategory = 'general',
    this.onFileNameChanged,
  });

  final UploadFileType fileType;

  /// 主题色，默认按文件类型自动选色
  final Color? accentColor;

  /// 当前已上传文件 URL
  final String? currentUrl;
  final String? label;
  final void Function(String url)? onUploaded;
  final void Function(UploadFileInfo info)? onFileInfo;

  /// 文本文件上传后回调解析出的文本内容
  final void Function(String content)? onTextContent;
  final double? height;

  /// 已上传的文本内容摘要
  final String? textPreview;

  /// 上传分类标识
  final String uploadCategory;

  /// 当文件名称更新时回调
  final void Function(String fileName)? onFileNameChanged;

  @override
  State<AssetUploadArea> createState() => _AssetUploadAreaState();
}

class _AssetUploadAreaState extends State<AssetUploadArea> {
  bool _isHovered = false;
  bool _isUploading = false;
  String? _uploadedFileName;
  Uint8List? _localImageBytes;

  @override
  void didUpdateWidget(AssetUploadArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果外部将 URL 置空，则清空本地缓存
    if ((widget.currentUrl == null || widget.currentUrl!.isEmpty) &&
        (oldWidget.currentUrl != null && oldWidget.currentUrl!.isNotEmpty)) {
      _localImageBytes = null;
      _uploadedFileName = null;
    }
  }

  Color get _accent =>
      widget.accentColor ??
      switch (widget.fileType) {
        UploadFileType.image => AppColors.primary,
        UploadFileType.audio => AppColors.info,
        UploadFileType.text => AppColors.success,
      };

  Future<void> _pickAndUpload() async {
    FileType pickerType;
    List<String>? allowedExt;
    switch (widget.fileType) {
      case UploadFileType.audio:
        pickerType = FileType.audio;
      case UploadFileType.image:
        pickerType = FileType.image;
      case UploadFileType.text:
        pickerType = FileType.custom;
        allowedExt = ['txt', 'md', 'json', 'csv', 'srt', 'ass'];
    }

    final result = await FilePicker.platform.pickFiles(
      type: pickerType,
      allowedExtensions: allowedExt,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _isUploading = true;
      if (widget.fileType == UploadFileType.image) {
        _localImageBytes = file.bytes;
      }
    });
    try {
      await _notifyFileInfo(file.name, file.bytes!);

      if (widget.fileType == UploadFileType.text) {
        _handleTextFile(file.bytes!);
      }

      final url = await FileService().upload(
        file.bytes!,
        file.name,
        category: widget.uploadCategory,
      );
      _uploadedFileName = file.name;
      widget.onUploaded?.call(url);
      
      // 回调文件名，以便自动填充名称字段
      if (widget.onFileNameChanged != null) {
        final name = file.name.contains('.') 
            ? file.name.substring(0, file.name.lastIndexOf('.'))
            : file.name;
        widget.onFileNameChanged!(name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上传失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _handleTextFile(Uint8List bytes) {
    try {
      final content = utf8.decode(bytes, allowMalformed: true);
      widget.onTextContent?.call(content);
    } catch (_) {}
  }

  Future<void> _notifyFileInfo(String fullName, Uint8List bytes) async {
    final baseName = fullName.contains('.')
        ? fullName.substring(0, fullName.lastIndexOf('.'))
        : fullName;
    String? resolution;
    if (widget.fileType == UploadFileType.image) {
      try {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        resolution = '${frame.image.width}x${frame.image.height}';
        frame.image.dispose();
      } catch (_) {}
    }
    if (!mounted) return;
    widget.onFileInfo?.call(UploadFileInfo(
      fileName: baseName,
      resolution: resolution,
    ));
  }

  String get _emptyHint {
    if (widget.label != null) return widget.label!;
    return switch (widget.fileType) {
      UploadFileType.image => '点击上传图片',
      UploadFileType.audio => '点击上传音频',
      UploadFileType.text => '点击上传文本文件',
    };
  }

  String get _formatHint => switch (widget.fileType) {
        UploadFileType.image => '支持 JPG、PNG、WebP',
        UploadFileType.audio => '支持 MP3、WAV 格式',
        UploadFileType.text => '支持 TXT、MD、JSON、CSV',
      };

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.currentUrl != null && widget.currentUrl!.isNotEmpty;
    if (hasValue) return _buildUploaded();
    return _buildEmpty();
  }

  // ─────────────────── 空态：虚线边框 ───────────────────

  Widget _buildEmpty() {
    final color = _accent;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isUploading ? null : _pickAndUpload,
        child: AnimatedContainer(
          duration: MotionTokens.durationMedium,
          curve: MotionTokens.curveStandard,
          height: widget.height ?? 100.h,
          decoration: BoxDecoration(
            color: _isHovered
                ? color.withValues(alpha: 0.06)
                : color.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          ),
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: _isHovered
                  ? color.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0.25),
              borderRadius: RadiusTokens.lg.r,
              strokeWidth: 1.2,
              dashLength: 6,
              gapLength: 4,
            ),
            child: _isUploading
                ? Center(
                    child: SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                  )
                : Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.upload,
                          size: 20.r,
                          color:
                              color.withValues(alpha: _isHovered ? 0.7 : 0.4),
                        ),
                        SizedBox(width: Spacing.sm.w),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _emptyHint,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: color.withValues(alpha: 0.7),
                              ),
                            ),
                            SizedBox(height: Spacing.xxs.h),
                            Text(
                              _formatHint,
                              style: AppTextStyles.tiny.copyWith(
                                color: AppColors.mutedDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ─────────────────── 已上传态 ───────────────────

  Widget _buildUploaded() {
    return switch (widget.fileType) {
      UploadFileType.image => _buildUploadedImage(),
      UploadFileType.audio =>
        _buildUploadedCompact(AppIcons.music, '音频已上传'),
      UploadFileType.text => _buildUploadedText(),
    };
  }

  Widget _buildUploadedImage() {
    final h = widget.height ?? 120.h;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _pickAndUpload,
        child: AnimatedContainer(
          duration: MotionTokens.durationMedium,
          curve: MotionTokens.curveStandard,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: _isHovered
                  ? _accent.withValues(alpha: 0.4)
                  : _accent.withValues(alpha: 0.15),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                child: _localImageBytes != null
                    ? Image.memory(
                        _localImageBytes!,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        resolveFileUrl(widget.currentUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            AppIcons.gallery,
                            size: 36.r,
                            color: _accent.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
              ),
              if (_isHovered)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                    color: AppColors.backgroundDarkest.withValues(alpha: 0.55),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.refresh,
                            size: 18.r, color: AppColors.onPrimary),
                        SizedBox(width: Spacing.xs.w),
                        Text(
                          '替换图片',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: Spacing.xs.h,
                right: Spacing.xs.w,
                child: _MiniIconBtn(
                  icon: AppIcons.close,
                  onTap: () {
                    setState(() {
                      _localImageBytes = null;
                      _uploadedFileName = null;
                    });
                    widget.onUploaded?.call('');
                  },
                  tooltip: '移除',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedText() {
    final preview = widget.textPreview ?? '';
    final summary =
        preview.length > 120 ? '${preview.substring(0, 120)}…' : preview;
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: _accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.document,
                  size: 18.r, color: _accent.withValues(alpha: 0.6)),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: Text(
                  _uploadedFileName ?? '文本文件已上传',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _MiniIconBtn(
                icon: AppIcons.refresh,
                onTap: _pickAndUpload,
                tooltip: '替换',
              ),
              SizedBox(width: Spacing.xxs.w),
              _MiniIconBtn(
                icon: AppIcons.close,
                onTap: () {
                  _uploadedFileName = null;
                  widget.onUploaded?.call('');
                  widget.onTextContent?.call('');
                },
                tooltip: '移除',
              ),
            ],
          ),
          if (summary.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Spacing.sm.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceMutedDarker,
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              ),
              child: Text(
                summary,
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.muted,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadedCompact(IconData icon, String fallbackLabel) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: _accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Spacing.sm.r),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18.r,
              color: _accent.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Text(
              _uploadedFileName ?? fallbackLabel,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _MiniIconBtn(
            icon: AppIcons.refresh,
            onTap: _pickAndUpload,
            tooltip: '替换',
          ),
          SizedBox(width: Spacing.xxs.w),
          _MiniIconBtn(
            icon: AppIcons.close,
            onTap: () {
              _uploadedFileName = null;
              widget.onUploaded?.call('');
            },
            tooltip: '移除',
          ),
        ],
      ),
    );
  }
}

/// 迷你圆形图标按钮
class _MiniIconBtn extends StatelessWidget {
  const _MiniIconBtn({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: EdgeInsets.all(Spacing.xs.r),
        child: Icon(icon, size: 14.r, color: AppColors.muted),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: child);
    return child;
  }
}
