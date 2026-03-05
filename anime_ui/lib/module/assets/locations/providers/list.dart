import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/location_svc.dart';

final locationServiceProvider = Provider((_) => LocationService());

/// 场景列表
class AssetLocationsNotifier extends Notifier<AsyncValue<List<Location>>> {
  @override
  AsyncValue<List<Location>> build() => const AsyncValue.data([]);

  LocationService get _svc => ref.read(locationServiceProvider);
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

  Future<void> add(Location loc) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final created = await _svc.create(pid,
          name: loc.name,
          time: loc.time,
          interiorExterior: loc.interiorExterior,
          atmosphere: loc.atmosphere,
          colorTone: loc.colorTone,
          layout: loc.layout,
          style: loc.style,
          styleOverride: loc.styleOverride,
          styleNote: loc.styleNote);
      state = AsyncValue.data([...state.value ?? [], created]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Location loc) async {
    final pid = _projectId;
    if (pid == null || loc.id == null) return;
    try {
      final updated = await _svc.update(pid, loc.id!,
          name: loc.name,
          time: loc.time,
          interiorExterior: loc.interiorExterior,
          atmosphere: loc.atmosphere,
          colorTone: loc.colorTone,
          layout: loc.layout,
          style: loc.style,
          styleOverride: loc.styleOverride,
          styleNote: loc.styleNote);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((l) => l.id == loc.id ? updated : l).toList(),
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
      state = AsyncValue.data(list.where((l) => l.id != id).toList());
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
        list.map((l) => l.id == id ? updated : l).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 批量确认：调用批量接口
  Future<int> batchConfirm(List<String> ids) async {
    final pid = _projectId;
    if (pid == null) return 0;
    try {
      final updatedList = await _svc.batchConfirm(pid, ids);
      if (updatedList.isEmpty) return 0;

      final idSet = updatedList.map((l) => l.id).whereType<String>().toSet();
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((l) => l.id != null && idSet.contains(l.id!)
            ? updatedList.firstWhere((u) => u.id == l.id)
            : l).toList(),
      );
      return updatedList.length;
    } catch (e, _) {
      rethrow;
    }
  }
}

final assetLocationsProvider =
    NotifierProvider<AssetLocationsNotifier, AsyncValue<List<Location>>>(
  AssetLocationsNotifier.new,
);
