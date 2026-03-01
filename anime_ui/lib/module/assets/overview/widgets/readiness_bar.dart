import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/overview/providers/overview.dart';

/// 资产就绪度进度条
class ReadinessBar extends StatelessWidget {
  const ReadinessBar({super.key, required this.data});

  final AssetOverviewData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.lg.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '资产就绪度',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.75),
                ),
              ),
              SizedBox(width: Spacing.md.w),
              if (!data.isLoading)
                Text(
                  '${data.totalConfirmed} / ${data.totalAssets}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              const Spacer(),
              if (!data.isLoading)
                Text(
                  '${data.readinessPct}%',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: data.readinessPct >= 100
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            child: LinearProgressIndicator(
              value: data.isLoading ? null : data.readinessPct / 100,
              minHeight: 6.h,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: data.readinessPct >= 100
                  ? AppColors.success
                  : AppColors.primary,
            ),
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              _chip(
                AppIcons.person,
                '角色',
                data.charConfirmed,
                data.charTotal,
                AppColors.categoryCharacter,
              ),
              SizedBox(width: Spacing.lg.w),
              _chip(
                AppIcons.landscape,
                '场景',
                data.locConfirmed,
                data.locTotal,
                AppColors.categoryLocation,
              ),
              SizedBox(width: Spacing.lg.w),
              _chip(
                AppIcons.category,
                '道具',
                data.propConfirmed,
                data.propTotal,
                AppColors.categoryProp,
              ),
              SizedBox(width: Spacing.lg.w),
              _chip(
                AppIcons.mic,
                '音色',
                data.voiceConfigured,
                data.voiceNeeded,
                AppColors.categoryVoice,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, int done, int total, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.r, color: color.withValues(alpha: 0.7)),
        SizedBox(width: Spacing.xs.w),
        Text(
          '$label ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.55),
          ),
        ),
        Text(
          '$done',
          style: AppTextStyles.caption.copyWith(
            color: done == total && total > 0 ? AppColors.success : color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '/$total',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
