import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 冻结前检查 / 冻结时资产状态
/// 冻结范围：仅已确认的角色、场景、道具；锁定后仍可新增
class VersionsReadinessCheck extends StatelessWidget {
  const VersionsReadinessCheck({
    super.key,
    required this.charTotal,
    required this.charConfirmed,
    required this.locTotal,
    required this.locConfirmed,
    required this.propTotal,
    required this.propConfirmed,
    required this.isLocked,
  });

  final int charTotal;
  final int charConfirmed;
  final int locTotal;
  final int locConfirmed;
  final int propTotal;
  final int propConfirmed;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.mid.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.checkOutline, size: 18.r, color: AppColors.muted),
              SizedBox(width: Spacing.sm.w),
              Text(
                isLocked ? '冻结时资产状态' : '冻结前检查',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.lg.h),
          _checkRow(
            AppIcons.person,
            '角色',
            '$charConfirmed / $charTotal 已确认',
            charTotal > 0 && charConfirmed == charTotal,
            charTotal > 0 && charConfirmed < charTotal
                ? '${charTotal - charConfirmed} 个待确认'
                : null,
          ),
          Divider(color: AppColors.surfaceContainer, height: 20.h),
          _checkRow(
            AppIcons.landscape,
            '场景',
            '$locConfirmed / $locTotal 已确认',
            locTotal > 0 && locConfirmed == locTotal,
            locTotal > 0 && locConfirmed < locTotal
                ? '${locTotal - locConfirmed} 个待确认'
                : null,
          ),
          Divider(color: AppColors.surfaceContainer, height: 20.h),
          _checkRow(
            AppIcons.category,
            '道具',
            '$propConfirmed / $propTotal 已确认',
            propTotal > 0 && propConfirmed == propTotal,
            propTotal > 0 && propConfirmed < propTotal
                ? '${propTotal - propConfirmed} 个待确认'
                : null,
          ),
          Divider(color: AppColors.surfaceContainer, height: 20.h),
          _checkRow(AppIcons.brush, '风格', '已设定', true, null),
          SizedBox(height: Spacing.md.h),
          Text(
            '冻结范围：仅已确认的角色、场景、道具；锁定后仍可新增',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(
    IconData icon,
    String label,
    String value,
    bool ok,
    String? warning,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxs.h),
      child: Row(
        children: [
          Icon(
            ok ? AppIcons.check : AppIcons.warning,
            size: 16.r,
            color: ok ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: Spacing.md.w),
          Icon(icon, size: 16.r, color: AppColors.mutedDark),
          SizedBox(width: Spacing.sm.w),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
          const Spacer(),
          if (warning != null) ...[
            Text(
              warning,
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
            SizedBox(width: Spacing.md.w),
          ],
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
