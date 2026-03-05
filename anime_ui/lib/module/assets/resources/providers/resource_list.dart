import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/image_gen_output.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/ai_svc.dart';
import 'package:anime_ui/pub/services/realtime_svc.dart';
import 'package:anime_ui/pub/services/resource_svc.dart';
import 'package:anime_ui/pub/services/task_svc.dart';

import 'resource_filters.dart';

final _resourceSvcProvider = Provider((_) => ResourceService());
final _aiSvcProvider = Provider((_) => AiService());
final _taskSvcProvider = Provider(
  (_) => TaskService(),
);

/// 资源生成任务的实时状态
class ResourceTaskState {
  const ResourceTaskState({
    this.status = 'pending',
    this.progress = 0,
    this.resourceId,
  });
  final String status;
  final int progress;
  final String? resourceId;

  bool get isGenerating =>
      status == 'pending' || status == 'running' || status == 'processing';
  bool get isCompleted => status == 'completed' || status == 'success';
  bool get isFailed => status == 'failed' || status == 'error';
}

/// 实时任务状态 Provider（taskId -> ResourceTaskState）
class ResourceTasksNotifier extends Notifier<Map<String, ResourceTaskState>> {
  @override
  Map<String, ResourceTaskState> build() => {};

  void upsert(String taskId, ResourceTaskState task) {
    state = {...state, taskId: task};
  }

  void remove(String taskId) {
    state = {...state}..remove(taskId);
  }

  void clear() => state = {};
}

final resourceTasksProvider =
    NotifierProvider<ResourceTasksNotifier, Map<String, ResourceTaskState>>(
  ResourceTasksNotifier.new,
);

/// 资源列表（CRUD + 生成操作 + 实时任务合并）
class ResourceListNotifier extends Notifier<AsyncValue<List<Resource>>> {
  ResourceService get _svc => ref.read(_resourceSvcProvider);
  StreamSubscription<Map<String, dynamic>>? _wsSub;
  Timer? _flushTimer;

  @override
  AsyncValue<List<Resource>> build() {
    _listenRealtimeEvents();
    ref.onDispose(() {
      _wsSub?.cancel();
      _flushTimer?.cancel();
    });
    return const AsyncValue.data([]);
  }

  /// 监听 WebSocket 事件：resource_created 刷新列表，task.updated 合并生成进度
  void _listenRealtimeEvents() {
    _wsSub?.cancel();
    _wsSub = realtimeWS.events.listen((event) {
      final type = event['type'] as String?;

      if (type == 'resource_created') {
        _scheduleFlush();
        return;
      }

      if (type == 'task.updated') {
        _handleTaskUpdate(event);
      }
    });
  }

  /// 防抖刷新（合并短时间内的多个 resource_created 事件）
  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(milliseconds: 200), () => load());
  }

  /// 处理 task.updated 事件，更新生成任务状态
  void _handleTaskUpdate(Map<String, dynamic> event) {
    final taskId = event['taskId'] as String? ?? '';
    if (taskId.isEmpty) return;

    final status = event['status'] as String? ?? '';
    final progress = (event['progress'] as num?)?.toInt() ?? 0;
    final resourceId = event['resourceId'] as String?;

    final taskState = ResourceTaskState(
      status: status,
      progress: progress,
      resourceId: resourceId,
    );
    ref.read(resourceTasksProvider.notifier).upsert(taskId, taskState);

    if (taskState.isCompleted) {
      _scheduleFlush();
      Future.delayed(const Duration(seconds: 2), () {
        ref.read(resourceTasksProvider.notifier).remove(taskId);
      });
    }
  }

  Future<void> load() async {
    try {
      final libraryType = ref.read(selectedLibraryTypeProvider);
      final search = ref.read(resourceSearchProvider).trim();
      final sort = ref.read(resourceSortProvider);
      final result = await _svc.list(
        libraryType: libraryType.name,
        modality: libraryType.modality.name,
        pageSize: 200,
        search: search.isNotEmpty ? search : null,
        sortBy: sort.apiValue,
      );
      state = AsyncValue.data(result.items);
    } catch (e, st) {
      debugPrint('ResourceList load failed: $e\n$st');
      state = AsyncValue.error(e, st);
    }
  }

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
    } catch (e, st) {
      debugPrint('addResource failed: $e\n$st');
      final current = state.value ?? [];
      state = AsyncValue.data([...current, r]);
      rethrow;
    }
  }

  Future<void> removeResource(String id) async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((r) => r.id != id).toList());
    try {
      await _svc.delete(id);
    } catch (e, st) {
      debugPrint('removeResource($id) failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateResource(Resource updated) async {
    final current = state.value ?? [];
    state = AsyncValue.data([
      for (final r in current)
        if (r.id == updated.id) updated else r,
    ]);
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
    } catch (e, st) {
      debugPrint('updateResource(${updated.id}) failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> batchRemove(Set<String> ids) async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((r) => !ids.contains(r.id)).toList());
    for (final id in ids) {
      try {
        await _svc.delete(id);
      } catch (e, st) {
        debugPrint('batchRemove($id) failed: $e\n$st');
      }
    }
  }

  Future<void> batchMoveToLibrary(
    Set<String> ids,
    String newLibraryType,
    String newModality,
  ) async {
    final current = state.value ?? [];
    final updated = <Resource>[];
    for (final r in current) {
      if (ids.contains(r.id) && r.id != null) {
        try {
          final res = await _svc.update(
            r.id!,
            libraryType: newLibraryType,
            modality: newModality,
          );
          updated.add(res);
        } catch (e, st) {
          debugPrint('batchMoveToLibrary(${r.id}) failed: $e\n$st');
          updated.add(
            r.copyWith(libraryType: newLibraryType, modality: newModality),
          );
        }
      } else {
        updated.add(r);
      }
    }
    state = AsyncValue.data(updated);
  }

  /// 音色克隆生成，返回生成的 Resource
  Future<Resource> generateVoice({
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
    return result.resource;
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

  /// 图生：调用统一 API /ai/generate/image，output.type=resource
  Future<String?> generateImage({
    required String name,
    required String libraryType,
    required String modality,
    required String prompt,
    String negativePrompt = '',
    String referenceImageUrl = '',
    String provider = '',
    String model = '',
    int? width,
    int? height,
    String size = '',
    void Function(int)? onProgress,
  }) async {
    final aiSvc = ref.read(_aiSvcProvider);
    final resource = await aiSvc.generateImage(
      prompt: prompt,
      negativePrompt: negativePrompt,
      referenceImageUrls:
          referenceImageUrl.isNotEmpty ? [referenceImageUrl] : [],
      provider: provider,
      model: model,
      width: width,
      height: height,
      output: ImageGenOutput.resource(
        libraryType: libraryType,
        modality: modality,
        name: name,
      ),
    );
    final current = state.value ?? [];
    state = AsyncValue.data([...current, resource]);
    return resource.id;
  }

  /// 生成预览文本
  Future<String> generatePreviewText({required String voicePrompt}) async {
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

/// 提示词库资源列表（用于创作助理/提示词库弹窗，跨子库场景）
final promptResourcesProvider =
    FutureProvider.autoDispose<List<Resource>>((ref) async {
  final svc = ref.read(_resourceSvcProvider);
  final result = await svc.list(
    libraryType: 'prompt',
    modality: 'text',
    pageSize: 200,
  );
  return result.items;
});

/// 各子库资源数量统计（从资源列表本地计算）
final resourceCountsProvider = Provider<Map<String, int>>((ref) {
  final asyncList = ref.watch(resourceListProvider);
  return asyncList.when(
    data: (list) {
      final counts = <String, int>{};
      for (final r in list) {
        counts[r.libraryType] = (counts[r.libraryType] ?? 0) + 1;
      }
      return counts;
    },
    loading: () => {},
    error: (e, st) => {},
  );
});
