import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/domain/resource_list_port.dart';

/// 资源列表端口 Provider 槽位
///
/// 由 layout 作为组合根通过 ProviderScope.overrides 注入实现，
/// 供 image_gen、voice_gen、text_gen 等 pub 组件使用。
final resourceListPortProvider = Provider<ResourceListPort>((ref) {
  throw StateError(
    'resourceListPortProvider 必须在 layout 中通过 ProviderScope.overrides 注入',
  );
});
