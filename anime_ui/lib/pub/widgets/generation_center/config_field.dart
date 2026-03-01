import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// A labelled text field for generation configuration (prompts, notes, etc.).
class ConfigField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final String? hint;
  final int maxLines;

  const ConfigField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppTextStyles.bodySmall.fontSize,
                color: AppColors.mutedDark,
              ),
              SizedBox(width: Spacing.iconGapSm.w),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        SizedBox(height: Spacing.contentGap.h),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedDarker,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.gridGap.w,
              vertical: Spacing.md.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
