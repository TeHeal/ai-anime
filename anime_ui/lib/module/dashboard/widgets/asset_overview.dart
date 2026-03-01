import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 资产概况卡片
class AssetOverview extends StatelessWidget {
  const AssetOverview({super.key, required this.summary});

  final AssetSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) return const SizedBox.shrink();
    final s = summary!;

    return Container(
      padding: EdgeInsets.all(Spacing.mid.r),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.category,
                size: 16.r,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              SizedBox(width: Spacing.sm.w),
              Text(
                '资产概况',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => context.go(Routes.assets),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.gridGap.w,
                    vertical: Spacing.sm.h,
                  ),
                  minimumSize: Size(0, 36.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '管理资产',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: Spacing.xs.w),
                    Icon(AppIcons.chevronRight, size: 14.r),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.lg.h),
          Row(
            children: [
              Expanded(
                child: _assetItem(
                  AppIcons.person,
                  '角色',
                  s.charactersConfirmed,
                  s.charactersTotal,
                ),
              ),
              SizedBox(width: Spacing.lg.w),
              Expanded(
                child: _assetItem(
                  AppIcons.landscape,
                  '场景',
                  s.locationsConfirmed,
                  s.locationsTotal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetItem(IconData icon, String label, int confirmed, int total) {
    final allDone = confirmed == total && total > 0;
    return Row(
      children: [
        Icon(
          icon,
          size: 16.r,
          color: AppColors.onSurface.withValues(alpha: 0.55),
        ),
        SizedBox(width: Spacing.sm.w),
        Text(
          '$label ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          '$confirmed',
          style: AppTextStyles.bodyMedium.copyWith(
            color: allDone ? AppColors.success : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '/$total',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
