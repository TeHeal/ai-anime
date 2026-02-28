import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_ui/route.dart';
import 'package:anime_ui/pub/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AnimeApp(),
    ),
  );
}

class AnimeApp extends StatelessWidget {
  const AnimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AI-Anime 漫剧智能创作平台',
      theme: appDarkTheme,
      routerConfig: appRouter,
    );
  }
}
