import 'package:flutter/material.dart';

/// 统一响应式断点
///
/// 用法：LayoutBuilder 内用 `Breakpoints.isLg(context)` 或
/// `Breakpoints.columnCountForWidth(width, maxCols: 3)` 计算列数
abstract final class Breakpoints {
  /// 小屏（手机竖屏）
  static const double sm = 500;

  /// 中屏（平板竖屏 / 手机横屏）
  static const double md = 600;

  /// 大屏（平板横屏 / 小桌面）
  static const double lg = 900;

  /// 超大屏（桌面）
  static const double xl = 1200;

  /// 当前宽度是否 >= sm
  static bool isSmOrUp(double width) => width >= sm;

  /// 当前宽度是否 >= md
  static bool isMdOrUp(double width) => width >= md;

  /// 当前宽度是否 >= lg
  static bool isLgOrUp(double width) => width >= lg;

  /// 当前宽度是否 >= xl
  static bool isXlOrUp(double width) => width >= xl;

  /// 当前宽度是否 < md（窄屏，单栏布局）
  static bool isNarrow(double width) => width < md;

  /// 根据宽度计算网格列数
  ///
  /// [width] 可用 constraints.maxWidth
  /// [maxCols] 最大列数，默认 4
  /// 断点：< 500 → 1 列，500–900 → 2 列，>= 900 → maxCols
  static int columnCountForWidth(double width, {int maxCols = 4}) {
    if (width < sm) return 1;
    if (width < lg) return 2;
    return maxCols.clamp(1, 6);
  }

  /// 从 MediaQuery 获取当前宽度
  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  /// 从 MediaQuery 判断是否窄屏
  static bool isNarrowContext(BuildContext context) {
    return isNarrow(screenWidth(context));
  }
}
