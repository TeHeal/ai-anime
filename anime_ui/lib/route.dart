import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 路由配置（集中注册）
/// 连接后端需使用: --dart-define=API_BASE_URL=http://localhost:3737/api/v1
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _HomePage(),
    ),
  ],
);

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Anime 漫剧智能创作平台'),
      ),
      body: const Center(
        child: Text('欢迎使用 AI-Anime'),
      ),
    );
  }
}
