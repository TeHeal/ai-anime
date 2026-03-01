import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 待发布变更项
class PendingItem {
  final String name;
  final String status;
  final String statusLabel;

  const PendingItem({
    required this.name,
    required this.status,
    required this.statusLabel,
  });
}

/// 待发布变更区块
class VersionsPendingChanges extends StatelessWidget {
  const VersionsPendingChanges({
    super.key,
    required this.pendingChars,
    required this.pendingLocs,
    required this.pendingProps,
  });

  final List<Character> pendingChars;
  final List<Location> pendingLocs;
  final List<Prop> pendingProps;

  @override
  Widget build(BuildContext context) {
    final totalPending =
        pendingChars.length + pendingLocs.length + pendingProps.length;

    return Container(
      padding: EdgeInsets.all(Spacing.mid.r),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.edit, size: 20.r, color: AppColors.warning),
              SizedBox(width: Spacing.sm.w),
              Text(
                '待发布变更',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.xxs.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Text(
                  '$totalPending',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '以下资产尚未确认，冻结时将自动确认',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.gridGap.h),
          if (pendingChars.isNotEmpty)
            _pendingSection(
              AppIcons.person,
              AppColors.categoryCharacter,
              '角色',
              pendingChars.map(
                (c) => PendingItem(
                  name: c.name,
                  status: c.status,
                  statusLabel: c.status == 'skeleton' ? '骨架' : '待确认',
                ),
              ),
            ),
          if (pendingLocs.isNotEmpty) ...[
            if (pendingChars.isNotEmpty)
              Divider(color: AppColors.divider, height: 20.h),
            _pendingSection(
              AppIcons.landscape,
              AppColors.categoryLocation,
              '场景',
              pendingLocs.map(
                (l) => PendingItem(
                  name: l.name,
                  status: l.status,
                  statusLabel: l.status == 'skeleton' ? '骨架' : '待确认',
                ),
              ),
            ),
          ],
          if (pendingProps.isNotEmpty) ...[
            if (pendingChars.isNotEmpty || pendingLocs.isNotEmpty)
              Divider(color: AppColors.divider, height: 20.h),
            _pendingSection(
              AppIcons.category,
              AppColors.categoryProp,
              '道具',
              pendingProps.map(
                (p) => PendingItem(
                  name: p.name,
                  status: p.status,
                  statusLabel: p.status == 'skeleton' ? '骨架' : '待确认',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pendingSection(
    IconData icon,
    Color color,
    String label,
    Iterable<PendingItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.r, color: color),
            SizedBox(width: Spacing.sm.w),
            Text(
              '$label (${items.length})',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.sm.h,
          children: items.map((item) => _pendingChip(item, color)).toList(),
        ),
      ],
    );
  }

  Widget _pendingChip(PendingItem item, Color color) {
    final isSkeleton = item.status == 'skeleton';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name.isEmpty ? '未命名' : item.name,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.xs.w,
              vertical: Spacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: isSkeleton
                  ? AppColors.error.withValues(alpha: 0.15)
                  : AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
            ),
            child: Text(
              item.statusLabel,
              style: AppTextStyles.tiny.copyWith(
                color: isSkeleton
                    ? AppColors.error.withValues(alpha: 0.9)
                    : AppColors.warning.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
