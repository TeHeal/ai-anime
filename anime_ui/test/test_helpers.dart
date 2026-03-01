// 测试辅助：ScreenUtilInit 等，供 Widget 测试使用

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/const/font_scale.dart';

/// 使用 ScreenUtilInit 包裹被测 Widget，避免 .w/.h 等扩展报错
Widget wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(1920, 1080),
    minTextAdapt: true,
    splitScreenMode: true,
    fontSizeResolver: FontScale.resolve,
    builder: (context, _) => child,
  );
}
