import 'package:flutter/material.dart' hide Theme, ThemeData;
import 'package:shadcn_flutter/shadcn_flutter.dart' show Theme, ThemeData, ToastLayer;

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/theme/app_theme.dart';
import 'package:anime_ui/route.dart';

/// 应用根组件
///
/// ProviderScope 由 main() 在根层级提供（含 storageService 等 overrides）
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      theme: appTheme,
      routerConfig: goRouter,
      // ToastLayer 依赖 shadcn_flutter 的 Theme，需用 Theme 包裹
      builder: (ctx, child) => Theme(
        data: ThemeData.dark(),
        child: ToastLayer(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
