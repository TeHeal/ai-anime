import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/dashboard.dart';

/// 整体进度概览 — 渐变卡片 + 环形进度提示 + 三态图例
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.info],
                ).createShader(bounds),
                child: Text(
                  '整体进度',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct * 100),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.info],
                  ).createShader(bounds),
                  child: Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.gridGap.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
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
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success.withValues(alpha: value),
                                AppColors.success.withValues(alpha: value * 0.75),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (inProg > 0)
                      Expanded(
                        flex: inProg,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.info.withValues(alpha: value),
                                AppColors.primary.withValues(alpha: value * 0.7),
                              ],
                            ),
                          ),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4.r,
              ),
            ],
          ),
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
