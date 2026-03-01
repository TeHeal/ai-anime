import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/asset_version.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 资产版本状态头部卡片
class VersionsHeader extends StatelessWidget {
  const VersionsHeader({
    super.key,
    required this.isLocked,
    required this.lockedAt,
    required this.versions,
  });

  final bool isLocked;
  final DateTime? lockedAt;
  final List<AssetVersion> versions;

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final latestVersion = versions.isNotEmpty
        ? 'v${versions.first.version}'
        : '—';
    return Container(
      padding: EdgeInsets.all(Spacing.mid.r),
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(
          color: isLocked
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Spacing.md.r),
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            ),
            child: Icon(
              isLocked ? AppIcons.lock : AppIcons.history,
              size: 24.r,
              color: isLocked ? AppColors.success : AppColors.primary,
            ),
          ),
          SizedBox(width: Spacing.lg.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isLocked ? '已冻结' : '未冻结',
                      style: AppTextStyles.h3.copyWith(
                        color: isLocked
                            ? AppColors.success
                            : AppColors.onSurface,
                      ),
                    ),
                    SizedBox(width: Spacing.md.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.md.w,
                        vertical: Spacing.xs.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                      ),
                      child: Text(
                        latestVersion,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Spacing.xs.h),
                Text(
                  isLocked
                      ? '冻结于 ${_formatTime(lockedAt)}，资产已锁定为生产基线'
                      : '确认资产后冻结，创建生产基线版本',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
