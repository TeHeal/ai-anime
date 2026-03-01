import 'package:flutter/material.dart';

import 'colors.dart';
import 'text.dart';

/// 深色主题、紫色强调
///
/// 使用 Theme.of(context) 获取颜色与文字样式，减少硬编码
final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
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
