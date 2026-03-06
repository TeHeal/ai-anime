import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

/// Preview player for the generated voice result.
class VoiceResultPreview extends StatelessWidget {
  const VoiceResultPreview({
    super.key,
    required this.accent,
    required this.audioUrl,
    required this.isGenerating,
    required this.progress,
    this.errorMsg,
  });

  final Color accent;
  final String audioUrl;
  final bool isGenerating;
  final int progress;
  final String? errorMsg;

  @override
  Widget build(BuildContext context) {
    if (errorMsg != null) return _buildError();
    if (isGenerating) return _buildGenerating();
    if (audioUrl.isNotEmpty) return _buildResult();
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.04),
            accent.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.mic,
              size: 28.r,
              color: accent.withValues(alpha: 0.25),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              '生成结果将在此处显示',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedDarker,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36.w,
              height: 36.h,
              child: CircularProgressIndicator(strokeWidth: 3.r, color: accent),
            ),
            SizedBox(height: Spacing.gridGap.h),
            Text(
              progress > 0 ? '生成中 $progress%…' : '音色生成中…',
              style: AppTextStyles.bodySmall.copyWith(color: accent),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              '此过程可能需要 10-60 秒',
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.error, size: 20.r, color: AppColors.error),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '生成失败',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                if (errorMsg!.isNotEmpty) ...[
                  SizedBox(height: Spacing.xs.h),
                  Text(
                    errorMsg!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final playback = AudioPlaybackService.instance;
    return ListenableBuilder(
      listenable: playback,
      builder: (_, _) {
        final isPlaying = playback.isPlayingUrl(audioUrl);
        return Container(
          padding: EdgeInsets.all(Spacing.lg.r),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => playback.play(audioUrl),
                      child: Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: accent.withValues(
                            alpha: isPlaying ? 0.3 : 0.15,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          isPlaying ? AppIcons.stop : AppIcons.playArrow,
                          size: 26.r,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Spacing.gridGap.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppIcons.check,
                              size: 14.r,
                              color: AppColors.success,
                            ),
                            SizedBox(width: Spacing.iconGapSm.w),
                            Text(
                              '生成成功',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Spacing.xs.h),
                        Text(
                          isPlaying ? '正在播放试听…' : '点击播放试听效果',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMiniWaveform(isPlaying),
                ],
              ),
              if (isPlaying && playback.duration.inMilliseconds > 0) ...[
                SizedBox(height: Spacing.md.h),
                Row(
                  children: [
                    Text(
                      formatDuration(playback.position),
                      style: AppTextStyles.labelTinySmall.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                    SizedBox(width: Spacing.sm.w),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3.r,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 5.r,
                          ),
                          activeTrackColor: accent,
                          inactiveTrackColor: accent.withValues(alpha: 0.15),
                          thumbColor: accent,
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 10.r,
                          ),
                        ),
                        child: Slider(
                          value: playback.progress,
                          onChanged: (v) {
                            final dur = playback.duration;
                            playback.seek(
                              Duration(
                                milliseconds: (v * dur.inMilliseconds).toInt(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.sm.w),
                    Text(
                      formatDuration(playback.duration),
                      style: AppTextStyles.labelTinySmall.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniWaveform(bool active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (i) {
        final h = active
            ? (8.0 + (i * 5 + DateTime.now().millisecond) % 16)
            : (6.0 + (i * 3) % 10);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 3.w,
          height: h.h,
          margin: EdgeInsets.symmetric(horizontal: Spacing.xxs.w),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: active ? 0.7 : 0.25),
            borderRadius: BorderRadius.circular((RadiusTokens.xs / 2).r),
          ),
        );
      }),
    );
  }
}
