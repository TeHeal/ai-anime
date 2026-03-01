import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

InputDecoration darkInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.caption.copyWith(color: AppColors.mutedDarker),
    filled: true,
    fillColor: AppColors.surfaceMutedDarker,
    contentPadding: EdgeInsets.symmetric(
      horizontal: Spacing.md.w,
      vertical: Spacing.lg.h,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}

class DarkFieldLabel extends StatelessWidget {
  const DarkFieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.hint,
  });

  final String text;
  final bool required;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
        ),
        if (required)
          Text(
            ' *',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        if (hint != null) ...[
          SizedBox(width: Spacing.sm.w),
          Text(
            hint!,
            style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
          ),
        ],
      ],
    );
  }
}
