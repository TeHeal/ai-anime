import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/theme/app_theme.dart';
import 'package:anime_ui/pub/router/router.dart';

/// 应用根组件
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: appName,
        theme: appTheme,
        routerConfig: goRouter,
      ),
    );
  }
}
