import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 可复用的搜索输入框，统一深色主题样式。
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = '搜索…',
    this.width = 220,
    this.height = 36,
    this.accentColor,
    /// 可选：自定义填充色。不传则用 surfaceMutedDarker；传入 inputFill 可更亮（如筛选栏）
    this.fillColor,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final double width;
  final double height;
  final Color? accentColor;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    final fill = fillColor ?? AppColors.surfaceMutedDarker;
    final borderColor = fillColor != null ? AppColors.inputBorder : AppColors.surfaceMutedDark;

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
          fillColor: fill,
          contentPadding: EdgeInsets.symmetric(vertical: 0.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: BorderSide(color: borderColor),
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
