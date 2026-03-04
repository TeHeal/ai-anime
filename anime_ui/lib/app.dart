import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
      builder: (ctx, child) => shadcn.Theme(
        data: const shadcn.ThemeData.dark(),
        // 内层恢复自定义 Material 主题，防止 shadcn Theme 覆盖
        child: Theme(
          data: appTheme,
          child: shadcn.ToastLayer(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
