import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppTextStyles {
  // Titles
  static TextStyle get h1 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
      );
  static TextStyle get h2 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get h3 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get h4 => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      );

  // Body text
  static TextStyle get bodyXLarge => TextStyle(fontSize: 15.sp);
  static TextStyle get bodyLarge => TextStyle(fontSize: 16.sp);
  static TextStyle get bodyMedium => TextStyle(fontSize: 14.sp);
  static TextStyle get bodySmall => TextStyle(fontSize: 13.sp);

  // Captions & Labels
  static TextStyle get labelTiny => TextStyle(fontSize: 9.sp);
  static TextStyle get labelTinySmall => TextStyle(fontSize: 10.sp);
  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get caption => TextStyle(fontSize: 12.sp);
  static TextStyle get tiny => TextStyle(fontSize: 11.sp);

  // Display (larger than h1)
  static TextStyle get displayLarge => TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
      );
}
