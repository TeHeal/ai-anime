import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/prop_svc.dart';

final _propSvcProvider = Provider((_) => PropService());

/// 道具列表
class AssetPropsNotifier extends Notifier<AsyncValue<List<Prop>>> {
  @override
  AsyncValue<List<Prop>> build() => const AsyncValue.data([]);

  PropService get _svc => ref.read(_propSvcProvider);
  Object? get _projectId => ref.read(currentProjectProvider).value?.id;

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

  Future<void> add(Prop p) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final created = await _svc.create(pid,
          name: p.name,
          appearance: p.appearance,
          isKeyProp: p.isKeyProp,
          style: p.style,
          imageUrl: p.imageUrl);
      state = AsyncValue.data([...state.value ?? [], created]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Prop p) async {
    final pid = _projectId;
    if (pid == null || p.id == null) return;
    try {
      final updated = await _svc.update(pid, p.id!,
          name: p.name,
          appearance: p.appearance,
          isKeyProp: p.isKeyProp,
          style: p.style,
          styleOverride: p.styleOverride,
          referenceImagesJson: p.referenceImagesJson,
          imageUrl: p.imageUrl,
          status: p.status);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((pr) => pr.id == p.id ? updated : pr).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String id) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      await _svc.delete(pid, id);
      final list = state.value ?? [];
      state = AsyncValue.data(list.where((p) => p.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> confirm(String id) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final updated = await _svc.confirm(pid, id);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((p) => p.id == id ? updated : p).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final assetPropsProvider =
    NotifierProvider<AssetPropsNotifier, AsyncValue<List<Prop>>>(
  AssetPropsNotifier.new,
);
