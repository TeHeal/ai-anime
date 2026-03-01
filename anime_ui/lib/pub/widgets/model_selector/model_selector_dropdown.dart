import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';

/// Dropdown-style model selector. Best for config pages and inline forms.
class ModelSelectorDropdown extends StatelessWidget {
  const ModelSelectorDropdown({
    super.key,
    required this.models,
    required this.selected,
    required this.accent,
    required this.isLoading,
    required this.onChanged,
    this.label = '模型',
    this.leadingIcon,
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final Color accent;
  final bool isLoading;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final String label;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedDarker,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[leadingIcon!, SizedBox(width: Spacing.sm.w)],
          Expanded(child: _buildDropdown()),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    if (isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 14.w,
            height: 14.h,
            child: CircularProgressIndicator(strokeWidth: 2.r, color: accent),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            '加载中…',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
          ),
        ],
      );
    }

    if (models.isEmpty) {
      return Text(
        '暂无可用模型',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected?.modelId,
        isExpanded: true,
        dropdownColor: AppColors.surfaceMutedDarker,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
        items: models.map((m) {
          return DropdownMenuItem<String>(
            value: m.modelId,
            child: Row(
              children: [
                Expanded(
                  child: Text(m.displayName, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: Spacing.sm.w),
                Text(
                  m.operatorLabel,
                  style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
                ),
                if (m.isRecommended) ...[
                  SizedBox(width: Spacing.sm.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xs.w,
                      vertical: Spacing.xxs.h,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                    ),
                    child: Text(
                      '推荐',
                      style: AppTextStyles.labelTiny.copyWith(
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: (modelId) {
          if (modelId == null) return;
          final m = models.firstWhere((m) => m.modelId == modelId);
          onChanged(m);
        },
      ),
    );
  }
}

/// Inline dropdown for selecting a model by display name only.
/// Used in forms where minimal display is needed (e.g. text gen "target model").
class ModelSelectorMini extends StatelessWidget {
  const ModelSelectorMini({
    super.key,
    required this.models,
    required this.selected,
    required this.onChanged,
    this.isLoading = false,
    this.allowEmpty = true,
    this.emptyLabel = '通用',
    this.label = '目标模型',
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final bool isLoading;
  final bool allowEmpty;
  final String emptyLabel;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark),
        ),
        SizedBox(height: Spacing.xs.h),
        Container(
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedDarker,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(color: AppColors.border),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 12.w,
                    height: 12.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.r,
                      color: AppColors.mutedDark,
                    ),
                  ),
                )
              : DropdownButton<String>(
                  value: selected?.modelId ?? '',
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: AppColors.surfaceMutedDarker,
                  style: AppTextStyles.caption.copyWith(color: AppColors.onSurface),
                  items: [
                    if (allowEmpty)
                      DropdownMenuItem(value: '', child: Text(emptyLabel)),
                    ...models.map(
                      (m) => DropdownMenuItem(
                        value: m.modelId,
                        child: Text(m.displayName),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null || v.isEmpty) {
                      onChanged(null);
                    } else {
                      onChanged(
                        models.where((m) => m.modelId == v).firstOrNull,
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }
}
