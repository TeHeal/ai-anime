import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/asset_version.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/pub/services/asset_version_svc.dart';

final _versionSvcProvider = Provider((_) => AssetVersionService());

/// 资产版本列表
class AssetVersionsNotifier extends Notifier<AsyncValue<List<AssetVersion>>> {
  @override
  AsyncValue<List<AssetVersion>> build() => const AsyncValue.data([]);

  AssetVersionService get _svc => ref.read(_versionSvcProvider);
  int? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> load() async {
    final pid = _projectId;
    if (pid == null) return;
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _svc.list(pid));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AssetVersion?> freeze() async {
    final pid = _projectId;
    if (pid == null) return null;
    try {
      final v = await _svc.freeze(pid);
      await load();
      return v;
    } catch (_) {
      return null;
    }
  }

  Future<void> unfreeze() async {
    final pid = _projectId;
    if (pid == null) return;
    await _svc.unfreeze(pid);
    await load();
  }

  /// 解冻影响分析：返回下游受影响内容列表
  Future<Map<String, dynamic>> impact() async {
    final pid = _projectId;
    if (pid == null) return {};
    return _svc.impact(pid);
  }
}

final assetVersionsProvider =
    NotifierProvider<AssetVersionsNotifier, AsyncValue<List<AssetVersion>>>(
  AssetVersionsNotifier.new,
);
