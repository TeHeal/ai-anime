import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

/// Upload area for voice clone sample audio.
class VoiceSampleUpload extends StatelessWidget {
  const VoiceSampleUpload({
    super.key,
    required this.accent,
    required this.sampleUrl,
    required this.sampleFileName,
    required this.onUpload,
    required this.onRemove,
  });

  final Color accent;
  final String sampleUrl;
  final String sampleFileName;
  final Future<void> Function(List<int> bytes, String fileName) onUpload;
  final VoidCallback onRemove;

  bool get _hasSample => sampleUrl.isNotEmpty;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    await onUpload(file.bytes!, file.name);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSample) return _buildUploaded(context);
    return _buildEmpty();
  }

  Widget _buildEmpty() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pick,
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(
              color: accent.withValues(alpha: 0.2),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.upload,
                size: 28.r,
                color: accent.withValues(alpha: 0.5),
              ),
              SizedBox(height: Spacing.sm.h),
              Text(
                '上传音频样本',
                style: AppTextStyles.bodySmall.copyWith(
                  color: accent.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: Spacing.xs.h),
              Text(
                '支持 MP3、WAV 格式，建议 10-60 秒',
                style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploaded(BuildContext context) {
    final playback = AudioPlaybackService.instance;
    return ListenableBuilder(
      listenable: playback,
      builder: (_, _) {
        final isPlaying = playback.isPlayingUrl(sampleUrl);
        return Container(
          padding: EdgeInsets.all(Spacing.gridGap.r),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => playback.play(sampleUrl),
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isPlaying ? 0.25 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? AppIcons.stop : AppIcons.playArrow,
                      size: 22.r,
                      color: accent,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleFileName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Spacing.xxs.h),
                    Text(
                      isPlaying
                          ? '${formatDuration(playback.position)} / ${formatDuration(playback.duration)}'
                          : '已上传',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  AppIcons.close,
                  size: 16.r,
                  color: AppColors.mutedDark,
                ),
                onPressed: onRemove,
                tooltip: '移除',
              ),
              IconButton(
                icon: Icon(
                  AppIcons.refresh,
                  size: 16.r,
                  color: AppColors.mutedDark,
                ),
                onPressed: _pick,
                tooltip: '重新选择',
              ),
            ],
          ),
        );
      },
    );
  }
}
