import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';

/// Horizontal chip-style model selector. Best for small model lists (≤5).
class ModelSelectorChips extends StatelessWidget {
  const ModelSelectorChips({
    super.key,
    required this.models,
    required this.selected,
    required this.accent,
    required this.isLoading,
    required this.onChanged,
    this.label = '模型',
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final Color accent;
  final bool isLoading;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
        ),
        SizedBox(height: Spacing.sm.h),
        if (isLoading)
          _buildLoading()
        else if (models.isEmpty)
          Text(
            '暂无可用模型',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          )
        else
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: models.map((m) => _chip(m)).toList(),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return Row(
      children: [
        SizedBox(
          width: Spacing.gridGap.w,
          height: Spacing.gridGap.h,
          child: CircularProgressIndicator(strokeWidth: 2.r, color: accent),
        ),
        SizedBox(width: Spacing.sm.w),
        Text(
          '加载模型中…',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.mutedDark),
        ),
      ],
    );
  }

  Widget _chip(ModelCatalogItem m) {
    final isSelected = selected?.id == m.id;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.chipPaddingH.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.15)
                : AppColors.surfaceMutedDarker,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.5)
                  : AppColors.surfaceContainer,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (m.isRecommended) ...[
                Icon(
                  AppIcons.bolt,
                  size: (AppTextStyles.labelMedium.fontSize ?? 14).r,
                  color: AppColors.tagAmber,
                ),
                SizedBox(width: Spacing.xs.w),
              ],
              Text(
                m.displayName,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? accent : AppColors.mutedLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              SizedBox(width: Spacing.xs.w),
              Text(
                m.operatorLabel,
                style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
