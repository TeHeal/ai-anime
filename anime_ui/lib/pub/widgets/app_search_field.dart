import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// Reusable search text field with consistent dark-theme styling.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = '搜索…',
    this.width = 220,
    this.height = 36,
    this.accentColor,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final double width;
  final double height;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;

    return SizedBox(
      width: width.w,
      height: height.h,
      child: TextField(
        controller: controller,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mutedDarker,
          ),
          prefixIcon: Icon(
            AppIcons.search,
            size: Spacing.lg.r,
            color: AppColors.mutedDark,
          ),
          filled: true,
          fillColor: AppColors.surfaceMutedDarker,
          contentPadding: EdgeInsets.symmetric(vertical: 0.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(color: AppColors.surfaceMutedDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: BorderSide(color: accent),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
