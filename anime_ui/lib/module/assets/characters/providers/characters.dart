import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/character_svc.dart';
import 'package:anime_ui/pub/services/storyboard_svc.dart'
    show ExtractResult, StoryboardService;
import 'package:anime_ui/module/assets/locations/providers/list.dart';
import 'package:anime_ui/module/assets/props/providers/list.dart';

final _characterSvcProvider = Provider((_) => CharacterService());
final _storyboardSvcProvider = Provider((_) => StoryboardService());

/// 角色列表
class AssetCharactersNotifier extends Notifier<AsyncValue<List<Character>>> {
  @override
  AsyncValue<List<Character>> build() => const AsyncValue.data([]);

  CharacterService get _svc => ref.read(_characterSvcProvider);
  String? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> load() async {
    final pid = _projectId;
    if (pid == null) return;
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _svc.listByProject(pid));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Character c) async {
    try {
      final created = await _svc.create(
        projectId: _projectId,
        name: c.name,
        appearance: c.appearance,
        style: c.style,
        personality: c.personality,
        voiceHint: c.voiceHint,
        emotions: c.emotions,
        scenes: c.scenes,
        gender: c.gender,
        ageGroup: c.ageGroup,
        voiceId: c.voiceId,
        voiceName: c.voiceName,
        imageUrl: c.imageUrl,
      );
      state = AsyncValue.data([...state.value ?? [], created]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Character c) async {
    if (c.id == null) return;
    try {
      final updated = await _svc.update(
        c.id!,
        name: c.name,
        appearance: c.appearance,
        style: c.style,
        personality: c.personality,
        voiceHint: c.voiceHint,
        emotions: c.emotions,
        scenes: c.scenes,
        gender: c.gender,
        ageGroup: c.ageGroup,
        voiceId: c.voiceId,
        voiceName: c.voiceName,
        imageUrl: c.imageUrl,
        importance: c.importance,
        consistency: c.consistency,
        roleType: c.roleType,
        tagsJson: c.tagsJson,
        propsJson: c.propsJson,
        bio: c.bio,
        bioFragmentsJson: c.bioFragmentsJson,
        imageGenOverrideJson: c.imageGenOverrideJson,
      );
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == c.id ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReferenceImage(
    String charId, {
    required String angle,
    required String url,
    Map<String, dynamic>? genMeta,
  }) async {
    try {
      final updated = await _svc.addReferenceImage(
        charId,
        angle: angle,
        url: url,
        genMeta: genMeta,
      );
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteReferenceImage(String charId, int idx) async {
    try {
      final updated = await _svc.deleteReferenceImage(charId, idx);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ─── 人物小传 ──────────────────────────────────────────────

  Future<void> extractBio(String charId) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final updated = await _svc.extractBio(pid, charId);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBio(String charId, String bio) async {
    try {
      final updated = await _svc.updateBio(charId, bio);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> regenerateBio(String charId) async {
    try {
      final updated = await _svc.regenerateBio(charId);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ─── 变体 ──────────────────────────────────────────────

  Future<void> addVariant(
    String charId, {
    required String label,
    String? appearance,
    String? episodeId,
    String? sceneId,
  }) async {
    try {
      final updated = await _svc.addVariant(
        charId,
        label: label,
        appearance: appearance,
        episodeId: episodeId,
        sceneId: sceneId,
      );
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateVariant(
    String charId,
    int idx, {
    String? label,
    String? appearance,
  }) async {
    try {
      final updated = await _svc.updateVariant(
        charId,
        idx,
        label: label,
        appearance: appearance,
      );
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteVariant(String charId, int idx) async {
    try {
      final updated = await _svc.deleteVariant(charId, idx);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == charId ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 批量 AI 补全
  Future<int> batchAIComplete(List<String> ids) async {
    try {
      final count = await _svc.batchAIComplete(ids);
      await load();
      return count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return 0;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _svc.delete(id);
      final list = state.value ?? [];
      state = AsyncValue.data(list.where((ch) => ch.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> confirm(String id) async {
    try {
      final updated = await _svc.confirm(id);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id == id ? updated : ch).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 批量确认：用接口返回的已更新角色列表合并到 state，与场景 confirm 行为一致，不 refetch
  Future<int> batchConfirm(List<String> ids) async {
    try {
      final updatedList = await _svc.batchConfirm(ids);
      if (updatedList.isEmpty) return 0;
      final idSet = updatedList.map((c) => c.id).whereType<String>().toSet();
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((ch) => ch.id != null && idSet.contains(ch.id!)
            ? updatedList.firstWhere((u) => u.id == ch.id)
            : ch).toList(),
      );
      return updatedList.length;
    } catch (e, _) {
      // 批量确认失败时保留原数据，仅 rethrow 供上层展示 toast
      rethrow;
    }
  }
}

final assetCharactersProvider =
    NotifierProvider<AssetCharactersNotifier, AsyncValue<List<Character>>>(
      AssetCharactersNotifier.new,
    );

// ─── AI 资产提取 ──────────────────────────────────────────────

/// 提取状态
class ExtractState {
  final bool isLoading;
  final ExtractResult? result;
  final String? error;

  const ExtractState({this.isLoading = false, this.result, this.error});

  ExtractState copyWith({
    bool? isLoading,
    ExtractResult? result,
    String? error,
  }) => ExtractState(
    isLoading: isLoading ?? this.isLoading,
    result: result ?? this.result,
    error: error,
  );
}

/// 资产提取 Notifier
class AssetExtractNotifier extends Notifier<ExtractState> {
  @override
  ExtractState build() => const ExtractState();

  StoryboardService get _svc => ref.read(_storyboardSvcProvider);
  String? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> extract({
    String mode = 'script_only',
    String characterProfileContent = '',
  }) async {
    final pid = _projectId;
    if (pid == null) return;
    state = const ExtractState(isLoading: true);
    try {
      final result = await _svc.extract(
        pid,
        mode: mode,
        characterProfileContent: characterProfileContent,
      );
      state = ExtractState(result: result);
    } catch (e) {
      state = ExtractState(error: e.toString());
    }
  }

  Future<void> confirmAndApply() async {
    final pid = _projectId;
    final result = state.result;
    if (pid == null || result == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _svc.confirmExtract(pid, result);
      ref.read(assetCharactersProvider.notifier).load();
      ref.read(assetLocationsProvider.notifier).load();
      ref.read(assetPropsProvider.notifier).load();
      state = const ExtractState();
    } catch (e) {
      state = ExtractState(result: result, error: e.toString());
    }
  }

  void reset() => state = const ExtractState();
}

final assetExtractProvider =
    NotifierProvider<AssetExtractNotifier, ExtractState>(
      AssetExtractNotifier.new,
    );

// ─── 集数筛选 ──────────────────────────────────────────────

class AssetEpisodeFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? value) => state = value;
}

final assetEpisodeFilterProvider =
    NotifierProvider<AssetEpisodeFilterNotifier, int?>(
      AssetEpisodeFilterNotifier.new,
    );
