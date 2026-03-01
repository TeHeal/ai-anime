import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// Reusable batch action bar with select-all toggle and a primary action button.
class BatchActionBar extends StatelessWidget {
  final int totalCount;
  final int selectedCount;
  final bool allSelected;
  final VoidCallback onToggleSelectAll;
  final VoidCallback? onBatchAction;
  final String batchLabel;
  final IconData batchIcon;
  final bool batchEnabled;

  const BatchActionBar({
    super.key,
    required this.totalCount,
    required this.selectedCount,
    required this.allSelected,
    required this.onToggleSelectAll,
    this.onBatchAction,
    this.batchLabel = '批量生成',
    this.batchIcon = AppIcons.magicStick,
    this.batchEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSelectAllChip(),
        SizedBox(width: Spacing.md.w),
        _buildBatchButton(),
      ],
    );
  }

  Widget _buildSelectAllChip() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggleSelectAll,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.chipPaddingVSmall.h,
          ),
          decoration: BoxDecoration(
            color: allSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceMutedDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: allSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.surfaceMuted,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                allSelected ? AppIcons.checkOutline : AppIcons.circleOutline,
                size: Spacing.gridGap.r,
                color: allSelected ? AppColors.primary : AppColors.muted,
              ),
              SizedBox(width: Spacing.iconGapSm.w),
              Text(
                allSelected ? '取消全选' : '全选',
                style: AppTextStyles.labelMedium.copyWith(
                  color: allSelected ? AppColors.primary : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchButton() {
    final enabled = selectedCount > 0 && batchEnabled;
    return FilledButton.icon(
      onPressed: enabled ? onBatchAction : null,
      icon: Icon(batchIcon, size: 15.r),
      label: Text('$batchLabel ($selectedCount)'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.surfaceMutedDark,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg.w,
          vertical: Spacing.buttonPaddingV.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
