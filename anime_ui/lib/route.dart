import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/router/router.dart';

/// 路由配置（集中注册）
/// 主路由已迁移至 pub/router/router.dart，此处保留 appRouter 别名以兼容旧引用
/// 连接后端需使用: --dart-define=API_BASE_URL=http://localhost:3737/api/v1
GoRouter get appRouter => goRouter;
