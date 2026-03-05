import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/const/radius.dart';
import 'colors.dart';
import 'text.dart';

/// 深色主题、紫色强调
///
/// 使用 Theme.of(context) 获取颜色与文字样式，减少硬编码
final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: AppTextStyles.labelLarge,
    hintStyle: AppTextStyles.bodySmall,
    filled: true,
    fillColor: AppColors.inputBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.onSurface.withValues(alpha: 0.8),
      side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
      ),
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
  ),
  scaffoldBackgroundColor: AppColors.background,
  dividerColor: AppColors.divider,
  textTheme: TextTheme(
    headlineLarge: AppTextStyles.h1,
    headlineMedium: AppTextStyles.h2,
    headlineSmall: AppTextStyles.h3,
    titleLarge: AppTextStyles.h4,
    titleMedium: AppTextStyles.labelLarge,
    titleSmall: AppTextStyles.labelMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.caption,
  ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface),
);

/// 主题别名（兼容旧引用）
ThemeData get appTheme => appDarkTheme;
