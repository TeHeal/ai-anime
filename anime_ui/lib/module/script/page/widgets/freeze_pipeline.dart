import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/lock_status.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 生产流水线——剧本 → 资产 → 脚本三阶段锁定状态
class FreezePipeline extends StatelessWidget {
  const FreezePipeline({super.key, required this.lockStatus});

  final LockStatus lockStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.xl.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.layers, size: 16.r, color: AppColors.muted),
              SizedBox(width: Spacing.sm.w),
              Text(
                '生产流水线',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.lg.h),
          Row(
            children: [
              Expanded(
                child: _phaseNode(
                  icon: AppIcons.book,
                  label: '剧本',
                  locked: lockStatus.storyLocked,
                  lockedAt: lockStatus.storyLockedAt,
                ),
              ),
              _connector(lockStatus.storyLocked),
              Expanded(
                child: _phaseNode(
                  icon: AppIcons.person,
                  label: '资产',
                  locked: lockStatus.assetsLocked,
                  lockedAt: lockStatus.assetsLockedAt,
                ),
              ),
              _connector(lockStatus.assetsLocked),
              Expanded(
                child: _phaseNode(
                  icon: AppIcons.film,
                  label: '脚本',
                  locked: lockStatus.scriptLocked,
                  lockedAt: lockStatus.scriptLockedAt,
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _phaseNode({
    required IconData icon,
    required String label,
    required bool locked,
    DateTime? lockedAt,
    bool highlight = false,
  }) {
    final color = locked ? AppColors.success : AppColors.muted;
    final bgAlpha = locked ? 0.10 : 0.05;
    final borderColor = highlight && locked
        ? AppColors.success.withValues(alpha: 0.4)
        : (locked
            ? AppColors.success.withValues(alpha: 0.2)
            : AppColors.border);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.md.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.r, color: color),
          SizedBox(height: Spacing.xs.h),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: locked ? AppColors.onSurface : AppColors.mutedDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Spacing.xxs.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                locked ? AppIcons.lock : AppIcons.lockUnlocked,
                size: 10.r,
                color: color,
              ),
              SizedBox(width: Spacing.xxs.w),
              Text(
                locked ? '已锁定' : '未锁定',
                style: AppTextStyles.tiny.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (locked && lockedAt != null) ...[
            SizedBox(height: Spacing.xxs.h),
            Text(
              '${lockedAt.month}/${lockedAt.day}',
              style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
            ),
          ],
        ],
      ),
    );
  }

  /// 连接线，已锁定阶段为绿色实线，未锁定为灰色虚线效果
  Widget _connector(bool prevLocked) {
    return SizedBox(
      width: 24.w,
      child: Center(
        child: Container(
          height: 2.h,
          width: 24.w,
          decoration: BoxDecoration(
            color: prevLocked
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
