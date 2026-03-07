import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/image_gen_output.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/ai_svc.dart';
import 'package:anime_ui/pub/services/realtime_svc.dart';
import 'package:anime_ui/pub/services/resource_svc.dart';

import '../models/resource_category.dart';
import 'resource_filters.dart';

/// 资源服务，供 content_area 等调用试听等接口
final resourceSvcProvider = Provider((_) => ResourceService());
final _aiSvcProvider = Provider((_) => AiService());

/// 资源生成任务的实时状态
class ResourceTaskState {
  const ResourceTaskState({
    this.status = 'pending',
    this.progress = 0,
    this.resourceId,
    this.type = '',
    this.title = '',
  });
  final String status;
  final int progress;
  final String? resourceId;
  final String type;
  final String title;

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

/// 资源列表（CRUD + 生成操作 + WebSocket 实时任务合并）
class ResourceListNotifier extends Notifier<AsyncValue<List<Resource>>> {
  ResourceService get _svc => ref.read(resourceSvcProvider);
  StreamSubscription<Map<String, dynamic>>? _wsSub;
  StreamSubscription<void>? _reconnectSub;
  Timer? _flushTimer;

  @override
  AsyncValue<List<Resource>> build() {
    _listenRealtimeEvents();
    _listenReconnect();
    ref.onDispose(() {
      _wsSub?.cancel();
      _reconnectSub?.cancel();
      _flushTimer?.cancel();
    });
    return const AsyncValue.data([]);
  }

  /// WebSocket 重连后刷新资源列表
  void _listenReconnect() {
    _reconnectSub?.cancel();
    _reconnectSub = realtimeWS.onReconnected.listen((_) {
      debugPrint('ResourceList: WS 重连成功，刷新列表');
      load();
    });
  }

  /// 监听 WebSocket 事件：
  /// - resource_created → 刷新列表（后端异步完成后推送）
  /// - task_progress / task_complete / task_error → 合并生成进度到卡片
  void _listenRealtimeEvents() {
    _wsSub?.cancel();
    _wsSub = realtimeWS.events.listen((event) {
      final type = event['type'] as String?;

      if (type == 'resource_created') {
        _scheduleFlush();
        return;
      }

      if (type == 'task_progress' ||
          type == 'task_complete' ||
          type == 'task_error') {
        _handleTaskUpdate(event, type!);
      }
    });
  }

  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(milliseconds: 200), () => load());
  }

  /// 处理后端推送的任务进度事件，驱动 resourceTasksProvider + taskCenterProvider
  void _handleTaskUpdate(Map<String, dynamic> event, String eventType) {
    final payload =
        (event['payload'] as Map<String, dynamic>?) ?? event;
    final taskId = (payload['taskId'] as String?) ??
        (event['taskId'] as String?) ??
        '';
    if (taskId.isEmpty) return;

    String status;
    switch (eventType) {
      case 'task_complete':
        status = 'completed';
        break;
      case 'task_error':
        status = 'failed';
        break;
      default:
        status = (payload['status'] as String?) ?? 'running';
    }

    final progress = (payload['progress'] as num?)?.toInt() ?? 0;
    final resourceId = (payload['resourceId'] as String?) ??
        (event['resourceId'] as String?);
    final taskType = (payload['type'] as String?) ?? '';
    final title = (payload['title'] as String?) ?? '';

    final taskState = ResourceTaskState(
      status: status,
      progress: progress,
      resourceId: resourceId,
      type: taskType,
      title: title,
    );
    ref.read(resourceTasksProvider.notifier).upsert(taskId, taskState);

    // 完成后刷新列表 + 延迟清理进度状态
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
        includeSystemVoices: libraryType == ResourceLibraryType.voice,
      );
      final merged = [...result.systemVoices, ...result.items];
      state = AsyncValue.data(merged);
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

  /// 音色克隆生成
  /// 后端为异步：立即返回占位 Resource + taskId，WebSocket 推送进度
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

    // 后端已创建占位资源，插入列表顶部
    final current = state.value ?? [];
    state = AsyncValue.data([result.resource, ...current]);

    // 注册任务状态（WebSocket 后续会更新）
    if (result.taskId.isNotEmpty) {
      ref.read(resourceTasksProvider.notifier).upsert(
            result.taskId,
            ResourceTaskState(
              status: 'running',
              resourceId: result.resource.id,
              type: 'tts',
              title: '音色克隆: $name',
            ),
          );
    }
    return result.resource;
  }

  /// 音色设计生成
  /// 后端为异步：立即返回占位 Resource + taskId，WebSocket 推送进度
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
    state = AsyncValue.data([result.resource, ...current]);

    if (result.taskId.isNotEmpty) {
      ref.read(resourceTasksProvider.notifier).upsert(
            result.taskId,
            ResourceTaskState(
              status: 'running',
              resourceId: result.resource.id,
              type: 'tts',
              title: '音色设计: $name',
            ),
          );
    }
    return result.resource;
  }

  /// 图生：调用统一 API /ai/generate/image，output.type=resource
  /// 后端为异步：立即返回占位 Resource + taskId，WebSocket 推送进度
  Future<Resource?> generateImage({
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
    final result = await aiSvc.generateImage(
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
    state = AsyncValue.data([result.resource, ...current]);

    if (result.taskId.isNotEmpty) {
      ref.read(resourceTasksProvider.notifier).upsert(
            result.taskId,
            ResourceTaskState(
              status: 'running',
              resourceId: result.resource.id,
              type: 'image',
              title: '图片生成: $name',
            ),
          );
    }
    return result.resource;
  }

  /// 生成预览文本
  Future<String> generatePreviewText({required String voicePrompt}) async {
    return _svc.generatePreviewText(voicePrompt: voicePrompt);
  }

  /// LLM 提示词生成
  /// 后端为异步：立即返回占位 Resource + taskId，WebSocket 推送进度
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
    final result = await _svc.generatePrompt(
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
    state = AsyncValue.data([result.resource, ...current]);

    if (result.taskId.isNotEmpty) {
      ref.read(resourceTasksProvider.notifier).upsert(
            result.taskId,
            ResourceTaskState(
              status: 'running',
              resourceId: result.resource.id,
              type: 'text',
              title: '提示词生成: $name',
            ),
          );
    }
    return result.resource;
  }
}

final resourceListProvider =
    NotifierProvider<ResourceListNotifier, AsyncValue<List<Resource>>>(
      ResourceListNotifier.new,
    );

/// 提示词库资源列表（用于创作助理/提示词库弹窗，跨子库场景）
final promptResourcesProvider =
    FutureProvider.autoDispose<List<Resource>>((ref) async {
  final svc = ref.read(resourceSvcProvider);
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
