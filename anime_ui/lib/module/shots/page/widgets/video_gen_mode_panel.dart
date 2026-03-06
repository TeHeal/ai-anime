import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shots/page/provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 视频生成模式选择面板
/// 支持：文生视频、首帧图生视频、首尾帧生视频、参考图生视频
class VideoGenModePanel extends ConsumerWidget {
  const VideoGenModePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(compositeConfigProvider);
    final notifier = ref.read(compositeConfigProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '生成模式',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.sm.h,
          children: VideoGenMode.values.map((mode) {
            final selected = config.videoGenMode == mode;
            return _ModeChip(
              mode: mode,
              selected: selected,
              onTap: () => notifier.setVideoGenMode(mode),
            );
          }).toList(),
        ),
        SizedBox(height: Spacing.md.h),
        _ModeDescription(mode: config.videoGenMode),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final VideoGenMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon => switch (mode) {
        VideoGenMode.text2video => AppIcons.text,
        VideoGenMode.firstFrame => AppIcons.image,
        VideoGenMode.firstLastFrame => AppIcons.film,
        VideoGenMode.referenceImages => AppIcons.images,
      };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                size: 14.r,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurface.withValues(alpha: 0.5),
              ),
              SizedBox(width: Spacing.xs.w),
              Text(
                mode.label,
                style: AppTextStyles.caption.copyWith(
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurface.withValues(alpha: 0.6),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeDescription extends StatelessWidget {
  final VideoGenMode mode;
  const _ModeDescription({required this.mode});

  String get _hint => switch (mode) {
        VideoGenMode.text2video => '根据提示词生成视频，适合灵感探索。建议先用生图模型生成参考图后再使用图生视频获得更好效果。',
        VideoGenMode.firstFrame => '上传首帧图片，模型基于该图片生成连贯视频。上传高清图片效果更好。',
        VideoGenMode.firstLastFrame => '同时指定视频首帧和尾帧图片，生成流畅衔接两帧的过渡视频，实现360°环绕等效果。',
        VideoGenMode.referenceImages => '上传1~4张参考图，模型提取关键特征并在视频中高度还原形态、色彩和纹理。需在提示词中用 [图N] 引用。',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.sm.r),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.info,
            size: 13.r,
            color: AppColors.info.withValues(alpha: 0.7),
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              _hint,
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.info.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
