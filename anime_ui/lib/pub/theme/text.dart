import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppTextStyles {
  /// 全局字体族，与 app_theme.dart 保持一致
  static const String fontFamily = 'Noto Sans SC';

  // Display
  static TextStyle get displayLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 27.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.3,
      );

  // Titles
  static TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.3,
      );
  static TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 21.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
      );
  static TextStyle get h3 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 19.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );
  static TextStyle get h4 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  // Body text（递减：17 > 16 > 15 > 14）
  static TextStyle get bodyXLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 17.sp,
        height: 1.5,
      );
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        height: 1.5,
      );
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.sp,
        height: 1.5,
      );
  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );
  static TextStyle get labelMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );
  static TextStyle get labelTinySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.sp,
        height: 1.4,
      );
  static TextStyle get labelTiny => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10.sp,
        height: 1.4,
      );

  // Captions & tiny
  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.sp,
        height: 1.4,
        letterSpacing: 0.1,
      );
  static TextStyle get tiny => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        height: 1.4,
        letterSpacing: 0.1,
      );
}
