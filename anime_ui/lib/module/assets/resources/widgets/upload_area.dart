import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

/// 上传区域：支持图片或音频，点击/拖拽上传后回调 URL
enum UploadFileType { image, audio }

class ResourceUploadArea extends StatefulWidget {
  const ResourceUploadArea({
    super.key,
    required this.accentColor,
    required this.fileType,
    this.currentUrl,
    this.label,
    this.onUploaded,
    this.height,
  });

  final Color accentColor;
  final UploadFileType fileType;
  final String? currentUrl;
  final String? label;
  final void Function(String url)? onUploaded;

  /// 自定义上传区域高度，默认 120.h
  final double? height;

  @override
  State<ResourceUploadArea> createState() => _ResourceUploadAreaState();
}

class _ResourceUploadAreaState extends State<ResourceUploadArea> {
  bool _isHovered = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.fileType == UploadFileType.audio
          ? FileType.audio
          : FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    try {
      final url = await FileService().upload(
        file.bytes!,
        file.name,
        category: 'general',
      );
      widget.onUploaded?.call(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上传失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String get _hintText {
    if (widget.label != null) return widget.label!;
    return widget.fileType == UploadFileType.audio ? '点击上传音频' : '点击上传图片';
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.currentUrl != null && widget.currentUrl!.isNotEmpty;
    if (hasValue) return _buildUploaded();
    return _buildEmpty();
  }

  Widget _buildEmpty() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickAndUpload,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height ?? 120.h,
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.08)
                : widget.accentColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: _isHovered
                  ? widget.accentColor.withValues(alpha: 0.4)
                  : widget.accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(Spacing.md.r),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(
                    alpha: _isHovered ? 0.15 : 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.upload,
                  size: 24.r,
                  color: widget.accentColor.withValues(
                    alpha: _isHovered ? 0.8 : 0.5,
                  ),
                ),
              ),
              SizedBox(height: Spacing.sm.h),
              Text(
                _hintText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.accentColor.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: Spacing.xs.h),
              Text(
                widget.fileType == UploadFileType.audio
                    ? '支持 MP3、WAV 格式'
                    : '支持 JPG、PNG、WebP',
                style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploaded() {
    final hasHeight = widget.height != null;
    final isImage = widget.fileType == UploadFileType.image;

    // 有自定义高度时（双栏布局）用纵向堆叠展示大缩略图
    if (hasHeight && isImage) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _pickAndUpload,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withValues(alpha: 0.4)
                    : widget.accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                  child: Image.network(
                    resolveFileUrl(widget.currentUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, Object? err, StackTrace? stack) =>
                        Center(
                      child: Icon(
                        AppIcons.gallery,
                        size: 40.r,
                        color: widget.accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                // 悬浮时显示操作蒙层
                if (_isHovered)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(RadiusTokens.xl.r),
                      color: AppColors.shadowOverlay.withValues(alpha: 0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppIcons.refresh,
                          size: 24.r,
                          color: AppColors.onPrimary,
                        ),
                        SizedBox(height: Spacing.xs.h),
                        Text(
                          '点击替换',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                // 右上角删除按钮
                Positioned(
                  top: Spacing.xs.h,
                  right: Spacing.xs.w,
                  child: _SmallIconButton(
                    icon: AppIcons.close,
                    onTap: () => widget.onUploaded?.call(''),
                    tooltip: '移除',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 默认紧凑横向布局（音频或无自定义高度时）
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              child: Image.network(
                resolveFileUrl(widget.currentUrl!),
                width: 64.w,
                height: 64.h,
                fit: BoxFit.cover,
                errorBuilder: (_, Object? err, StackTrace? stack) => Icon(
                  AppIcons.gallery,
                  size: 32.r,
                  color: widget.accentColor.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            Icon(
              AppIcons.music,
              size: 32.r,
              color: widget.accentColor.withValues(alpha: 0.7),
            ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Text(
              '已上传',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 16.r, color: AppColors.mutedDark),
            onPressed: () => widget.onUploaded?.call(''),
            tooltip: '移除',
          ),
          IconButton(
            icon:
                Icon(AppIcons.refresh, size: 16.r, color: AppColors.mutedDark),
            onPressed: _pickAndUpload,
            tooltip: '重新选择',
          ),
        ],
      ),
    );
  }
}

/// 小型圆形图标按钮（用于图片覆盖层上的操作）
class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Spacing.xs.r),
        decoration: BoxDecoration(
          color: AppColors.shadowOverlay.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14.r, color: AppColors.onPrimary),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: child);
    }
    return child;
  }
}
