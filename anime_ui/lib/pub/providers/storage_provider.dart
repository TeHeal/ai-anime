import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/services/storage_svc.dart';

/// 本地存储服务 Provider
///
/// 由 main() 在启动时通过 ProviderScope.overrides 注入已初始化的实例，
/// 避免全局单例，便于测试时 mock。
final storageServiceProvider = Provider<StorageService>((ref) {
  throw StateError('StorageService 必须在 main() 中通过 ProviderScope.overrides 注入');
});
