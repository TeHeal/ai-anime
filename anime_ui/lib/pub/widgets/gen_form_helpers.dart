import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 生成类弹窗通用表单标签（支持必填星号）
Widget genFormLabel(String text, {bool required = false}) {
  return Row(
    children: [
      Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
      if (required)
        Padding(
          padding: EdgeInsets.only(left: Spacing.xs.w),
          child: Text(
            '*',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
    ],
  );
}

/// 生成类弹窗通用输入框装饰
InputDecoration genFormInputDeco(String hint, Color accent) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDarker),
    filled: true,
    fillColor: AppColors.surfaceMutedDarker,
    contentPadding: EdgeInsets.symmetric(
      horizontal: Spacing.md.w,
      vertical: Spacing.lg.h,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      borderSide: const BorderSide(color: AppColors.surfaceMutedDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      borderSide: BorderSide(color: accent),
    ),
  );
}
