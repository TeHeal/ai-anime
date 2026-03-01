import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// A filter chip descriptor for the toolbar.
class FilterChipData {
  final String key;
  final String label;
  final int count;
  final Color? color;

  const FilterChipData({
    required this.key,
    required this.label,
    this.count = 0,
    this.color,
  });
}

/// A group chip for pagination (e.g. "1-10", "11-20").
class GroupChipData {
  final String key;
  final String label;

  const GroupChipData({required this.key, required this.label});
}

/// Reusable filter toolbar with status chips and optional group chips.
class FilterToolbar extends StatelessWidget {
  final List<FilterChipData> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final List<GroupChipData> groups;
  final String activeGroup;
  final ValueChanged<String>? onGroupChanged;

  const FilterToolbar({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
    this.groups = const [],
    this.activeGroup = '',
    this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.gridGap.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      ),
      child: Row(
        children: [
          Icon(AppIcons.tune, size: 15.r, color: AppColors.mutedDark),
          SizedBox(width: Spacing.sm.w),
          for (int i = 0; i < filters.length; i++) ...[
            _buildFilterChip(filters[i]),
            if (i < filters.length - 1) SizedBox(width: Spacing.sm.w),
          ],
          if (groups.isNotEmpty) ...[
            const Spacer(),
            Text(
              '分组:',
              style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
            ),
            SizedBox(width: Spacing.sm.w),
            for (int i = 0; i < groups.length; i++) ...[
              _buildGroupChip(groups[i]),
              if (i < groups.length - 1) SizedBox(width: Spacing.xs.w),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(FilterChipData chip) {
    final isActive = activeFilter == chip.key;
    final activeColor = chip.color ?? AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onFilterChanged(chip.key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.chipPaddingH.w,
            vertical: Spacing.chipPaddingV.h,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chip.label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? activeColor : AppColors.muted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (chip.count > 0) ...[
                SizedBox(width: Spacing.xs.w),
                Text(
                  '${chip.count}',
                  style: AppTextStyles.labelTinySmall.copyWith(
                    color: isActive
                        ? activeColor.withValues(alpha: 0.7)
                        : AppColors.mutedDarker,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupChip(GroupChipData chip) {
    final isActive = activeGroup == chip.key;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onGroupChanged?.call(chip.key),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          ),
          child: Text(
            chip.label,
            style: AppTextStyles.tiny.copyWith(
              color: isActive ? AppColors.primary : AppColors.mutedDark,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
