import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 字号缩放边界
///
/// 设计稿 1920×1080 下，小屏时 .sp 会过度缩小，大屏时过度放大。
/// 通过 fontSizeResolver 限制缩放比例，保证字号在合理范围内。
abstract final class FontScale {
  /// 最小缩放比例（相对设计稿字号）
  /// 例：14.sp 在小屏下不会小于 14 * 0.65 ≈ 9
  static const double minScale = 0.7;

  /// 最大缩放比例（相对设计稿字号）
  /// 例：14.sp 在大屏下不会大于 14 * 1.2 ≈ 17
  static const double maxScale = 1.6;

  /// 带边界限制的字号解析器
  ///
  /// 用于 ScreenUtilInit.fontSizeResolver，避免字号随屏幕过度缩放
  static double resolve(num fontSize, ScreenUtil instance) {
    final scaled = instance.setWidth(fontSize);
    return scaled.clamp(fontSize * minScale, fontSize * maxScale);
  }
}
