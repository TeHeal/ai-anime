import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

/// 上传区域：支持图片或音频，点击/拖拽上传后回调 URL
enum UploadFileType { image, audio }

class ResourceUploadArea extends StatelessWidget {
  const ResourceUploadArea({
    super.key,
    required this.accentColor,
    required this.fileType,
    this.currentUrl,
    this.label,
    this.onUploaded,
  });

  final Color accentColor;
  final UploadFileType fileType;
  final String? currentUrl;
  final String? label;
  final void Function(String url)? onUploaded;

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: fileType == UploadFileType.audio ? FileType.audio : FileType.image,
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
      onUploaded?.call(url);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String get _hintText {
    if (label != null) return label!;
    return fileType == UploadFileType.audio
        ? '点击上传音频'
        : '点击上传图片';
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = currentUrl != null && currentUrl!.isNotEmpty;

    if (hasValue) {
      return _buildUploaded(context);
    }
    return _buildEmpty(context);
  }

  Widget _buildEmpty(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickAndUpload(context),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.upload,
              size: 28.r,
              color: accentColor.withValues(alpha: 0.5),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              _hintText,
              style: AppTextStyles.bodySmall.copyWith(
                color: accentColor.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: Spacing.xs.h),
            Text(
              fileType == UploadFileType.audio
                  ? '支持 MP3、WAV 格式'
                  : '支持 JPG、PNG、WebP',
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploaded(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          if (fileType == UploadFileType.image)
            ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              child: Image.network(
                resolveFileUrl(currentUrl!),
                width: 64.w,
                height: 64.h,
                fit: BoxFit.cover,
                errorBuilder: (_, Object? err, StackTrace? stack) => Icon(
                  AppIcons.gallery,
                  size: 32.r,
                  color: accentColor.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            Icon(
              AppIcons.music,
              size: 32.r,
              color: accentColor.withValues(alpha: 0.7),
            ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Text(
              '已上传',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 16.r, color: AppColors.mutedDark),
            onPressed: () => onUploaded?.call(''),
            tooltip: '移除',
          ),
          IconButton(
            icon: Icon(AppIcons.refresh, size: 16.r, color: AppColors.mutedDark),
            onPressed: () => _pickAndUpload(context),
            tooltip: '重新选择',
          ),
        ],
      ),
    );
  }
}
