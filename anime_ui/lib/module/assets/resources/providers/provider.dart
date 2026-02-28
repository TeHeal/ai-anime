import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/resource_svc.dart';
import 'package:anime_ui/pub/services/task_svc.dart';

import '../models/resource_category.dart';

final _resourceSvcProvider = Provider((_) => ResourceService());
final _taskSvcProvider = Provider((_) => TaskService()); // 供 generateVoice 等轮询任务用

/// 资源列表（桩实现，返回空列表）
class ResourceListNotifier extends Notifier<AsyncValue<List<Resource>>> {
  ResourceService get _svc => ref.read(_resourceSvcProvider);

  @override
  AsyncValue<List<Resource>> build() => const AsyncValue.data([]);

  Future<void> load() async {
    try {
      final result = await _svc.list(pageSize: 200);
      state = AsyncValue.data(result.items);
    } catch (e, _) {
      debugPrint('ResourceList load failed: $e');
      state = const AsyncValue.data([]);
    }
  }

  Future<void> handleRealtimeEvent(Map<String, dynamic> evt) async {}

  Future<void> addResource(Resource r) async {
    try {
      final created = await _svc.create(
        name: r.name,
        libraryType: r.libraryType,
        modality: r.modality,
        thumbnailUrl: r.thumbnailUrl,
        tagsJson: r.tagsJson,
        version: r.version,
        metadataJson: r.metadataJson,
        bindingIdsJson: r.bindingIdsJson,
        description: r.description,
      );
      final current = state.value ?? [];
      state = AsyncValue.data([...current, created]);
    } catch (e) {
      debugPrint('addResource failed: $e');
      final current = state.value ?? [];
      state = AsyncValue.data([...current, r]);
    }
  }

  Future<void> removeResource(int id) async {
    try {
      await _svc.delete(id);
    } catch (e) {
      debugPrint('removeResource($id) failed: $e');
    }
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((r) => r.id != id).toList());
  }

  Future<void> updateResource(Resource updated) async {
    try {
      if (updated.id != null) {
        await _svc.update(
          updated.id!,
          name: updated.name,
          thumbnailUrl: updated.thumbnailUrl,
          tagsJson: updated.tagsJson,
          version: updated.version,
          metadataJson: updated.metadataJson,
          bindingIdsJson: updated.bindingIdsJson,
          description: updated.description,
        );
      }
    } catch (e) {
      debugPrint('updateResource(${updated.id}) failed: $e');
    }
    final current = state.value ?? [];
    state = AsyncValue.data([
      for (final r in current)
        if (r.id == updated.id) updated else r,
    ]);
  }

  Future<void> batchRemove(Set<int> ids) async {
    for (final id in ids) {
      try {
        await _svc.delete(id);
      } catch (e) {
        debugPrint('batchRemove($id) failed: $e');
      }
    }
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((r) => !ids.contains(r.id)).toList());
  }

  Future<void> batchMoveToLibrary(
      Set<int> ids, String newLibraryType, String newModality) async {
    final current = state.value ?? [];
    final updated = <Resource>[];
    for (final r in current) {
      if (ids.contains(r.id) && r.id != null) {
        updated.add(r.copyWith(
            libraryType: newLibraryType, modality: newModality));
      } else {
        updated.add(r);
      }
    }
    state = AsyncValue.data(updated);
  }

  /// 音色克隆生成
  Future<void> generateVoice({
    required String name,
    required String sampleUrl,
    String tagsJson = '',
    String description = '',
    void Function(int)? onProgress,
  }) async {
    final result = await _svc.generateVoice(
      name: name,
      sampleUrl: sampleUrl,
      tagsJson: tagsJson,
      description: description,
    );
    final current = state.value ?? [];
    state = AsyncValue.data([...current, result.resource]);
    if (result.taskId.isNotEmpty) {
      final taskSvc = ref.read(_taskSvcProvider);
      await for (final t in taskSvc.poll(result.taskId)) {
        onProgress?.call(t.progress);
        if (t.isCompleted) {
          await load();
          break;
        }
        if (t.isFailed) throw Exception('音色生成失败');
      }
    }
  }

  /// 音色设计生成（文本提示）
  Future<Resource> generateVoiceDesign({
    required String name,
    required String prompt,
    String previewText = '',
    String provider = '',
    String model = '',
    String voiceId = '',
    String tagsJson = '',
    String description = '',
    void Function(int)? onProgress,
  }) async {
    final result = await _svc.generateVoiceDesign(
      name: name,
      prompt: prompt,
      previewText: previewText,
      provider: provider,
      model: model,
      voiceId: voiceId,
      tagsJson: tagsJson,
      description: description,
    );
    final current = state.value ?? [];
    state = AsyncValue.data([...current, result.resource]);
    if (result.taskId.isNotEmpty) {
      final taskSvc = ref.read(_taskSvcProvider);
      await for (final t in taskSvc.poll(result.taskId)) {
        onProgress?.call(t.progress);
        if (t.isFinished) {
          await load();
          break;
        }
      }
    }
    final latest = state.value ?? [];
    return latest.firstWhere(
      (r) => r.id == result.resource.id,
      orElse: () => result.resource,
    );
  }

  /// 生成预览文本
  Future<String> generatePreviewText({
    required String voicePrompt,
  }) async {
    return _svc.generatePreviewText(voicePrompt: voicePrompt);
  }

  /// LLM 提示词生成
  Future<Resource> generatePrompt({
    required String name,
    required String instruction,
    String targetModel = '',
    String category = '',
    String tagsJson = '',
    String description = '',
    String libraryType = '',
    String language = '',
  }) async {
    final resource = await _svc.generatePrompt(
      name: name,
      instruction: instruction,
      targetModel: targetModel,
      category: category,
      tagsJson: tagsJson,
      description: description,
      libraryType: libraryType,
      language: language,
    );
    final current = state.value ?? [];
    state = AsyncValue.data([...current, resource]);
    return resource;
  }
}

final resourceListProvider =
    NotifierProvider<ResourceListNotifier, AsyncValue<List<Resource>>>(
  ResourceListNotifier.new,
);

/// 选中模态
class _ValueNotifier<T> extends Notifier<T> {
  _ValueNotifier(this._initial);
  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

final selectedModalityProvider =
    NotifierProvider<_ValueNotifier<ResourceModality>, ResourceModality>(
  () => _ValueNotifier(ResourceModality.visual),
);

final selectedLibraryTypeProvider =
    NotifierProvider<_ValueNotifier<ResourceLibraryType>, ResourceLibraryType>(
  () => _ValueNotifier(ResourceLibraryType.style),
);
