import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/style.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/style_svc.dart';

final _styleSvcProvider = Provider((_) => StyleService());

/// 风格列表
class AssetStylesNotifier extends Notifier<AsyncValue<List<Style>>> {
  @override
  AsyncValue<List<Style>> build() => const AsyncValue.data([]);

  StyleService get _svc => ref.read(_styleSvcProvider);
  String? get _projectId => ref.read(currentProjectProvider).value?.id;

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

  Future<void> add(Style s) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final created = await _svc.create(pid,
          name: s.name,
          description: s.description,
          negativePrompt: s.negativePrompt,
          referenceImagesJson: s.referenceImagesJson,
          thumbnailUrl: s.thumbnailUrl,
          isProjectDefault: s.isProjectDefault);
      state = AsyncValue.data([...state.value ?? [], created]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Style s) async {
    if (s.id == null) return;
    final pid = _projectId;
    if (pid == null) return;
    try {
      final updated = await _svc.update(pid, s.id!,
          name: s.name,
          description: s.description,
          negativePrompt: s.negativePrompt,
          referenceImagesJson: s.referenceImagesJson,
          thumbnailUrl: s.thumbnailUrl,
          isProjectDefault: s.isProjectDefault);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((st) => st.id == s.id ? updated : st).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String styleId) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      await _svc.delete(pid, styleId);
      final list = state.value ?? [];
      state = AsyncValue.data(list.where((s) => s.id != styleId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 设为项目默认风格，同时前端 state 互斥更新
  Future<void> setDefault(String styleId) async {
    final pid = _projectId;
    if (pid == null) return;
    final list = state.value ?? [];
    final target = list.where((s) => s.id == styleId).firstOrNull;
    if (target == null) return;
    try {
      final updated = await _svc.update(pid, styleId,
          isProjectDefault: true);
      state = AsyncValue.data(
        list.map((s) {
          if (s.id == styleId) return updated;
          if (s.isProjectDefault) return s.copyWith(isProjectDefault: false);
          return s;
        }).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 将风格应用到所有资产（角色、场景、道具）
  Future<int> applyAll(String styleId) async {
    final pid = _projectId;
    if (pid == null) return 0;
    return _svc.applyAll(pid, styleId);
  }
}

final assetStylesProvider =
    NotifierProvider<AssetStylesNotifier, AsyncValue<List<Style>>>(
  AssetStylesNotifier.new,
);

/// 风格名称搜索（用于自定义风格网格筛选）
class StyleNameSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final styleNameSearchProvider =
    NotifierProvider<StyleNameSearchNotifier, String>(
  StyleNameSearchNotifier.new,
);
