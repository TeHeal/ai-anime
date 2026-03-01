import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/asset_version.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 版本历史列表
class VersionsHistoryList extends StatelessWidget {
  const VersionsHistoryList({super.key, required this.versions});

  final List<AssetVersion> versions;

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.history, size: 18.r, color: AppColors.mutedDark),
            SizedBox(width: Spacing.sm.w),
            Text(
              '版本历史',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        ...versions.map((v) => _VersionTile(v: v, formatTime: _formatTime)),
      ],
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile({required this.v, required this.formatTime});

  final AssetVersion v;
  final String Function(DateTime?) formatTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.sm.h),
      padding: EdgeInsets.all(Spacing.gridGap.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
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
              'v${v.version}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.actionLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (v.note.isNotEmpty)
                  Text(
                    v.note,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedDark,
                    ),
                  ),
              ],
            ),
          ),
          if (v.createdAt != null)
            Text(
              formatTime(v.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedDarker,
              ),
            ),
        ],
      ),
    );
  }
}
