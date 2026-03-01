import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/dashboard.dart';

/// 整体进度概览
class ProgressOverview extends StatelessWidget {
  const ProgressOverview({super.key, required this.dash});

  final Dashboard dash;

  @override
  Widget build(BuildContext context) {
    final total = dash.totalEpisodes;
    final done = dash.statusCounts['completed'] ?? 0;
    final inProg = dash.statusCounts['in_progress'] ?? 0;
    final pending = total - done - inProg;
    final pct = total > 0 ? done / total : 0.0;

    return Container(
      padding: EdgeInsets.all(Spacing.mid.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.surface.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
        border: Border.all(
          color: AppColors.surfaceMutedDark.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '整体进度',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toInt()}%',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.gridGap.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
            child: SizedBox(
              height: Spacing.iconGapSm.h,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => Row(
                  children: [
                    if (done > 0)
                      Expanded(
                        flex: done,
                        child: Container(
                          color: AppColors.success.withValues(alpha: value),
                        ),
                      ),
                    if (inProg > 0)
                      Expanded(
                        flex: inProg,
                        child: Container(
                          color: AppColors.info.withValues(alpha: value),
                        ),
                      ),
                    if (pending > 0)
                      Expanded(
                        flex: pending,
                        child: Container(color: AppColors.surfaceContainer),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: Spacing.gridGap.h),
          Row(
            children: [
              _legendDot(AppColors.success, '已完成 $done'),
              SizedBox(width: Spacing.mid.w),
              _legendDot(AppColors.info, '进行中 $inProg'),
              SizedBox(width: Spacing.mid.w),
              _legendDot(AppColors.mutedDarker, '待开始 $pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Spacing.sm.w,
          height: Spacing.sm.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Spacing.sm.w),
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
