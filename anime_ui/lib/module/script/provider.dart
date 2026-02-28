import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/models/scene.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'package:anime_ui/pub/models/segment.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/pub/services/episode_svc.dart';
import 'package:anime_ui/pub/services/scene_svc.dart';
import 'package:anime_ui/pub/services/segment_svc.dart';

final episodeServiceProvider = Provider((_) => EpisodeService());
final sceneServiceProvider = Provider((_) => SceneService());
final segmentServiceProvider = Provider((_) => SegmentService());

// ---------------------------------------------------------------------------
// 集列表
// ---------------------------------------------------------------------------

/// 集列表 Notifier
class EpisodesNotifier extends Notifier<AsyncValue<List<Episode>>> {
  @override
  AsyncValue<List<Episode>> build() => const AsyncValue.data([]);

  EpisodeService get _svc => ref.read(episodeServiceProvider);
  String? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> load() async {
    final pid = _projectId;
    if (pid == null) return;
    state = const AsyncValue.loading();
    try {
      final list = await _svc.list(pid);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Episode> add(String title) async {
    final pid = _projectId;
    if (pid == null) throw Exception('没有选中项目');
    final ep = await _svc.create(pid, title: title);
    state = AsyncValue.data([...state.value ?? [], ep]);
    return ep;
  }

  Future<void> update(String episodeId, {String? title, String? summary}) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final updated = await _svc.update(pid, episodeId,
          title: title, summary: summary);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((e) => e.id == episodeId ? updated : e).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String episodeId) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      await _svc.delete(pid, episodeId);
      final list = state.value ?? [];
      state = AsyncValue.data(list.where((e) => e.id != episodeId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reorder(List<String> orderedIds) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      await _svc.reorder(pid, orderedIds);
      final list = state.value ?? [];
      final map = {for (final e in list) e.id: e};
      state = AsyncValue.data(
        orderedIds
            .where((id) => map.containsKey(id))
            .map((id) => map[id]!)
            .toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final episodesProvider =
    NotifierProvider<EpisodesNotifier, AsyncValue<List<Episode>>>(
        EpisodesNotifier.new);

// ---------------------------------------------------------------------------
// 剧本选择状态（当前选中的集/场）
// ---------------------------------------------------------------------------

/// 剧本选择 Notifier
class ScriptSelectionNotifier
    extends Notifier<({String? episodeId, String? sceneId})> {
  @override
  ({String? episodeId, String? sceneId}) build() =>
      (episodeId: null, sceneId: null);

  void selectEpisode(String id) =>
      state = (episodeId: id, sceneId: null);

  void selectScene(String episodeId, String sceneId) =>
      state = (episodeId: episodeId, sceneId: sceneId);

  void clear() => state = (episodeId: null, sceneId: null);
}

final scriptSelectionProvider = NotifierProvider<ScriptSelectionNotifier,
    ({String? episodeId, String? sceneId})>(ScriptSelectionNotifier.new);

// ---------------------------------------------------------------------------
// 场景列表（按集）
// ---------------------------------------------------------------------------

/// 场景列表 Notifier
class ScenesNotifier extends Notifier<AsyncValue<List<Scene>>> {
  @override
  AsyncValue<List<Scene>> build() => const AsyncValue.data([]);

  SceneService get _svc => ref.read(sceneServiceProvider);
  String? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> loadForEpisode(String episodeId) async {
    final pid = _projectId;
    if (pid == null) return;
    state = const AsyncValue.loading();
    try {
      final list = await _svc.list(pid, episodeId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Scene> add(
    String episodeId, {
    required String sceneId,
    String location = '',
    List<String> characters = const [],
  }) async {
    final pid = _projectId;
    if (pid == null) throw Exception('没有选中项目');
    final scene = await _svc.create(
      pid,
      episodeId,
      sceneId: sceneId,
      location: location,
      characters: characters,
    );
    state = AsyncValue.data([...state.value ?? [], scene]);
    return scene;
  }

  Future<void> update(
    String episodeId,
    String sceneDbId, {
    String? sceneId,
    String? location,
    String? time,
    String? interiorExterior,
    List<String>? characters,
  }) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final updated = await _svc.update(
        pid,
        episodeId,
        sceneDbId,
        sceneId: sceneId,
        location: location,
        time: time,
        interiorExterior: interiorExterior,
        characters: characters,
      );
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((s) => s.id == sceneDbId ? updated : s).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String episodeId, String sceneDbId) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      await _svc.delete(pid, episodeId, sceneDbId);
      final list = state.value ?? [];
      state =
          AsyncValue.data(list.where((s) => s.id != sceneDbId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveBlocks(
    String episodeId,
    String sceneDbId,
    List<SceneBlock> blocks,
  ) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final saved = await _svc.saveBlocks(pid, episodeId, sceneDbId, blocks);
      final list = state.value ?? [];
      state = AsyncValue.data(
        list.map((s) {
          if (s.id == sceneDbId) {
            return s.copyWith(blocks: saved);
          }
          return s;
        }).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final scenesProvider =
    NotifierProvider<ScenesNotifier, AsyncValue<List<Scene>>>(
        ScenesNotifier.new);

// ---------------------------------------------------------------------------
// 段落列表（兼容旧版）
// ---------------------------------------------------------------------------

/// 段落列表 Notifier
class SegmentsNotifier extends Notifier<AsyncValue<List<ScriptSegment>>> {
  @override
  AsyncValue<List<ScriptSegment>> build() => const AsyncValue.data([]);

  SegmentService get _svc => ref.read(segmentServiceProvider);
  String? get _projectId => ref.read(currentProjectProvider).value?.id;

  Future<void> load() async {
    final pid = _projectId;
    if (pid == null) return;
    state = const AsyncValue.loading();
    try {
      final segments = await _svc.list(pid);
      state = AsyncValue.data(segments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> bulkSave(List<ScriptSegment> segments) async {
    final pid = _projectId;
    if (pid == null) return;
    try {
      final result = await _svc.bulkCreate(pid, segments);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final segmentsProvider =
    NotifierProvider<SegmentsNotifier, AsyncValue<List<ScriptSegment>>>(
        SegmentsNotifier.new);
