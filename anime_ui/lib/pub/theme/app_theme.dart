import 'package:flutter/material.dart';

import 'colors.dart';

/// 深色主题、紫色强调
final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: Colors.purpleAccent,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  ),
);

/// 主题别名（兼容旧引用）
ThemeData get appTheme => appDarkTheme;
