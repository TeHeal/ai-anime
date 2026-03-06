import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shots/providers/review_ui.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 顶部播放器栏：视频预览 + 音轨混音器 + 播放模式选择
class ReviewPlayerBar extends ConsumerWidget {
  final dynamic shot;

  const ReviewPlayerBar({super.key, required this.shot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(shotsReviewUiProvider);
    final uiNotifier = ref.read(shotsReviewUiProvider.notifier);

    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.rightPanelBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.onSurface.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _videoPlaceholder(),
              SizedBox(width: Spacing.lg.w),
              Expanded(child: _audioMixer()),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          _playbackModeRow(uiState, uiNotifier),
        ],
      ),
    );
  }

  Widget _videoPlaceholder() {
    return Container(
      width: 320.w,
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkest,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.play, size: 36.r, color: AppColors.surfaceMuted),
            SizedBox(height: Spacing.sm.h),
            Text(
              '视频播放器',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.mutedDarker,
              ),
            ),
            SizedBox(height: Spacing.xs.h),
            Text(
              '00:00 / ${shot?.duration ?? 0}s',
              style: AppTextStyles.tiny.copyWith(color: AppColors.surfaceMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _audioMixer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '#${(shot?.sortIndex ?? 0) + 1} ${shot?.cameraType ?? ''} · ${shot?.duration ?? 0}s',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: Spacing.md.h),
        _audioTrackRow('🎤 VO', 0.8),
        _audioTrackRow('🎵 BGM', 0.6),
        _audioTrackRow('🔊 拟声', 0.7),
        _audioTrackRow('🔊 氛围', 0.4),
      ],
    );
  }

  Widget _audioTrackRow(String label, double volume) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.tinyGap.h),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              label,
              style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
            ),
          ),
          Icon(AppIcons.play, size: 12.r, color: AppColors.mutedDarker),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
              child: LinearProgressIndicator(
                value: volume,
                backgroundColor: AppColors.surfaceContainer,
                color: AppColors.primary.withValues(alpha: 0.6),
                minHeight: 4.h,
              ),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          SizedBox(
            width: 28.w,
            child: Text(
              volume.toStringAsFixed(1),
              style: AppTextStyles.labelTinySmall.copyWith(
                color: AppColors.mutedDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _playbackModeRow(
    ShotsReviewUiState uiState,
    ShotsReviewUiNotifier uiNotifier,
  ) {
    const modes = [
      ('composite', '🎬 完整合成'),
      ('video_only', '📹 仅视频'),
      ('vo_only', '🎤 仅VO'),
      ('bgm_only', '🎵 仅BGM'),
      ('video_vo', '📹+🎤'),
      ('lip_focus', '👄 口型聚焦'),
    ];

    return Row(
      children: [
        Text(
          '播放模式:',
          style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
        ),
        SizedBox(width: Spacing.sm.w),
        for (final (key, label) in modes) ...[
          _playbackModeChip(key, label, uiState, uiNotifier),
          SizedBox(width: Spacing.xs.w),
        ],
      ],
    );
  }

  Widget _playbackModeChip(
    String mode,
    String label,
    ShotsReviewUiState uiState,
    ShotsReviewUiNotifier uiNotifier,
  ) {
    final active = uiState.playbackMode == mode;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => uiNotifier.setPlaybackMode(mode),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.surfaceContainer,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelTinySmall.copyWith(
              color: active ? AppColors.primary : AppColors.mutedDark,
            ),
          ),
        ),
      ),
    );
  }
}
