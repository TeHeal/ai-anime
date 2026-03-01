import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 镜图审核：脚本对照区域
class ReviewScriptRef extends StatelessWidget {
  const ReviewScriptRef({super.key, required this.shot});

  final StoryboardShot shot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Spacing.lg.w, vertical: Spacing.md.h),
            child: Row(
              children: [
                Icon(AppIcons.document, size: 16.r, color: AppColors.muted),
                SizedBox(width: Spacing.sm.w),
                Text(
                  '脚本对照',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.h, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(Spacing.lg.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _refField('画面描述', shot.prompt),
                SizedBox(height: Spacing.sm.h),
                _refField('风格提示', shot.stylePrompt),
                SizedBox(height: Spacing.sm.h),
                Wrap(
                  spacing: Spacing.sm.w,
                  runSpacing: Spacing.sm.h,
                  children: [
                    _cameraChip('景别', shot.cameraType ?? ''),
                    _cameraChip('运镜', shot.cameraAngle ?? ''),
                    _durationChip('时长', '${shot.duration}s'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _refField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
        ),
        SizedBox(height: Spacing.xxs.h),
        Text(
          value.isNotEmpty ? value : '—',
        style: AppTextStyles.bodySmall.copyWith(
          color: value.isNotEmpty
              ? AppColors.mutedLight
              : AppColors.surfaceMuted,
        ),
        ),
      ],
    );
  }

  Widget _cameraChip(String label, String value) {
    final chipColor = label == '景别'
        ? AppColors.primary
        : (label == '运镜' ? AppColors.primary : AppColors.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelTinySmall.copyWith(
            color: AppColors.mutedDarker,
          ),
        ),
        SizedBox(height: Spacing.xxs.h),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w, vertical: Spacing.xs.h),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            border: Border.all(
              color: chipColor.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Text(
            value.isNotEmpty ? value : '—',
            style: AppTextStyles.caption.copyWith(
              color: value.isNotEmpty ? chipColor : AppColors.mutedDarker,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _durationChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelTinySmall.copyWith(
            color: AppColors.mutedDarker,
          ),
        ),
        SizedBox(height: Spacing.xxs.h),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w, vertical: Spacing.xs.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
          ),
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
