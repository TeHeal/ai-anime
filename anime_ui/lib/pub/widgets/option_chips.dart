import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


class OptionChips<T> extends StatelessWidget {
  const OptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.chipPadding,
    this.fontSize = 13.0,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsets? chipPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final padding = chipPadding ??
        EdgeInsets.symmetric(
          horizontal: Spacing.gridGap.w,
          vertical: Spacing.sm.h,
        );
    return Wrap(
      spacing: Spacing.sm.w,
      runSpacing: Spacing.sm.h,
      children: options.entries.map((e) {
        final isSelected = e.key == selected;
        return GestureDetector(
          onTap: () => onSelected(e.key),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
              ),
            ),
            child: Text(
              e.value,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: fontSize,
                color: isSelected ? AppColors.primary : AppColors.muted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
