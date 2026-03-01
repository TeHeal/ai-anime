import 'package:flutter/material.dart';

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
    );
  }
}
