import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/style.dart';
import 'package:anime_ui/pub/providers/project.dart';
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
}

final assetStylesProvider =
    NotifierProvider<AssetStylesNotifier, AsyncValue<List<Style>>>(
  AssetStylesNotifier.new,
);
