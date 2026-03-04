import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppTextStyles {
  // Display
  static TextStyle get displayLarge => TextStyle(
        fontSize: 27.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.3,
      );

  // Titles
  static TextStyle get h1 => TextStyle(
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.3,
      );
  static TextStyle get h2 => TextStyle(
        fontSize: 21.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
      );
  static TextStyle get h3 => TextStyle(
        fontSize: 19.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );
  static TextStyle get h4 => TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  // Body text（递减：17 > 16 > 15 > 14）
  static TextStyle get bodyXLarge => TextStyle(
        fontSize: 17.sp,
        height: 1.5,
      );
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        height: 1.5,
      );
  static TextStyle get bodyMedium => TextStyle(
        fontSize: 15.sp,
        height: 1.5,
      );
  static TextStyle get bodySmall => TextStyle(
        fontSize: 14.sp,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );
  static TextStyle get labelMedium => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );
  static TextStyle get labelTinySmall => TextStyle(
        fontSize: 11.sp,
        height: 1.4,
      );
  static TextStyle get labelTiny => TextStyle(
        fontSize: 10.sp,
        height: 1.4,
      );

  // Captions & tiny
  static TextStyle get caption => TextStyle(
        fontSize: 13.sp,
        height: 1.4,
        letterSpacing: 0.1,
      );
  static TextStyle get tiny => TextStyle(
        fontSize: 12.sp,
        height: 1.4,
        letterSpacing: 0.1,
      );
}
