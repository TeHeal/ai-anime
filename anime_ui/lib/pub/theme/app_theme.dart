import 'package:flutter/material.dart';

/// 深色主题、紫色强调
final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurple,
    secondary: Colors.purpleAccent,
    surface: const Color(0xFF121212),
    onSurface: Colors.white,
  ),
);
