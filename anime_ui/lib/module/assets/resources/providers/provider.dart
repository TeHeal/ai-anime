import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/image_gen_output.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/ai_svc.dart';
import 'package:anime_ui/pub/services/resource_svc.dart';
import 'package:anime_ui/pub/services/task_svc.dart';

import '../models/resource_category.dart';
import '../models/resource_meta_schema.dart';

final _resourceSvcProvider = Provider((_) => ResourceService());
final _aiSvcProvider = Provider((_) => AiService());
final _taskSvcProvider = Provider(
  (_) => TaskService(),
); // 供 generateVoice 等轮询任务用

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

  Future<void> removeResource(String id) async {
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

  Future<void> batchRemove(Set<String> ids) async {
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
        } catch (e) {
          debugPrint('batchMoveToLibrary(${r.id}) failed: $e');
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
      () => _ValueNotifier(ResourceLibraryType.character),
    );

/// 搜索关键词（用于筛选资源）
final resourceSearchProvider =
    NotifierProvider<_ValueNotifier<String>, String>(() => _ValueNotifier(''));

/// 排序方式
enum ResourceSort {
  newest('最近创建'),
  oldest('最早创建'),
  nameAsc('名称 A→Z'),
  nameDesc('名称 Z→A');

  const ResourceSort(this.label);
  final String label;
}

final resourceSortProvider =
    NotifierProvider<_ValueNotifier<ResourceSort>, ResourceSort>(
  () => _ValueNotifier(ResourceSort.newest),
);

/// 选中的标签（用于筛选）
class SelectedTagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void set(List<String> tags) => state = tags;

  void toggle(String tag) {
    if (state.contains(tag)) {
      state = state.where((t) => t != tag).toList();
    } else {
      state = [...state, tag];
    }
  }

  void clear() => state = [];
}

final selectedTagsProvider =
    NotifierProvider<SelectedTagsNotifier, List<String>>(
  SelectedTagsNotifier.new,
);

/// 选中的元数据筛选（key -> value）
class MetaFiltersNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void set(String key, String value) {
    if (state[key] == value) {
      state = {...state}..remove(key);
    } else {
      state = {...state, key: value};
    }
  }

  void clear() => state = {};
}

final selectedMetaFiltersProvider =
    NotifierProvider<MetaFiltersNotifier, Map<String, String>>(
  MetaFiltersNotifier.new,
);

/// 当前子库资源（仅按 libraryType 过滤，用于提取可用标签/元数据值）
final _libraryResourcesProvider = Provider<List<Resource>>((ref) {
  final libraryType = ref.watch(selectedLibraryTypeProvider);
  final asyncList = ref.watch(resourceListProvider);
  return asyncList.when(
    data: (list) =>
        list.where((r) => r.libraryType == libraryType.name).toList(),
    loading: () => [],
    error: (_, Object? err) => [],
  );
});

/// 当前子库资源的可用标签列表
final availableTagsProvider = Provider<List<String>>((ref) {
  final resources = ref.watch(_libraryResourcesProvider);
  final tags = <String>{};
  for (final r in resources) {
    for (final t in r.tags) {
      if (t.trim().isNotEmpty) tags.add(t.trim());
    }
  }
  return tags.toList()..sort();
});

/// 各可筛选字段的可用值（预设 + 资源中已用值）
final availableMetaValuesProvider =
    Provider<Map<String, List<String>>>((ref) {
  final resources = ref.watch(_libraryResourcesProvider);
  final libraryType = ref.watch(selectedLibraryTypeProvider);
  final filterableFields =
      ResourceMetaSchema.filterableFields(libraryType);

  final result = <String, List<String>>{};

  for (final field in filterableFields) {
    final preset = field.options ?? [];
    final usedValues = <String>{};

    for (final r in resources) {
      final meta = r.metadata;
      final val = meta[field.key];
      if (val != null && val is String && val.isNotEmpty) {
        usedValues.add(val);
      }
    }

    final merged = [...preset];
    for (final v in usedValues) {
      if (!merged.contains(v)) merged.add(v);
    }
    result[field.key] = merged;
  }

  return result;
});

/// 视图模式
enum ViewMode { grid, list, preview }

final viewModeProvider =
    NotifierProvider<_ValueNotifier<ViewMode>, ViewMode>(
  () => _ValueNotifier(ViewMode.grid),
);

/// 批量模式开关
final batchModeProvider =
    NotifierProvider<_ValueNotifier<bool>, bool>(() => _ValueNotifier(false));

/// 批量选中的资源 ID
class SelectedResourceIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void setAll(Iterable<String> ids) => state = ids.toSet();

  void clear() => state = {};
}

final selectedResourceIdsProvider =
    NotifierProvider<SelectedResourceIdsNotifier, Set<String>>(
  SelectedResourceIdsNotifier.new,
);

/// 按当前选中的库类型、搜索、标签、元数据筛选、排序后的资源列表
final filteredResourceListProvider = Provider<List<Resource>>((ref) {
  final libraryType = ref.watch(selectedLibraryTypeProvider);
  final search = ref.watch(resourceSearchProvider).trim().toLowerCase();
  final selectedTags = ref.watch(selectedTagsProvider);
  final metaFilters = ref.watch(selectedMetaFiltersProvider);
  final sort = ref.watch(resourceSortProvider);
  final asyncList = ref.watch(resourceListProvider);

  return asyncList.when(
    data: (list) {
      var filtered = list
          .where((r) => r.libraryType == libraryType.name)
          .toList();

      if (search.isNotEmpty) {
        filtered = filtered.where((r) {
          final matchName = r.name.toLowerCase().contains(search);
          final matchTags =
              r.tags.any((t) => t.toLowerCase().contains(search));
          return matchName || matchTags;
        }).toList();
      }

      if (selectedTags.isNotEmpty) {
        filtered = filtered.where((r) {
          return selectedTags.every((tag) =>
              r.tags.any((t) => t.toLowerCase() == tag.toLowerCase()));
        }).toList();
      }

      for (final e in metaFilters.entries) {
        filtered = filtered.where((r) {
          final meta = r.metadata;
          final val = meta[e.key];
          return val != null && val.toString() == e.value;
        }).toList();
      }

      switch (sort) {
        case ResourceSort.newest:
          filtered.sort((a, b) =>
              (b.updatedAt ?? b.createdAt ?? DateTime(0))
                  .compareTo(a.updatedAt ?? a.createdAt ?? DateTime(0)));
          break;
        case ResourceSort.oldest:
          filtered.sort((a, b) =>
              (a.updatedAt ?? a.createdAt ?? DateTime(0))
                  .compareTo(b.updatedAt ?? b.createdAt ?? DateTime(0)));
          break;
        case ResourceSort.nameAsc:
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case ResourceSort.nameDesc:
          filtered.sort((a, b) => b.name.compareTo(a.name));
          break;
      }

      return filtered;
    },
    loading: () => [],
    error: (_, Object? err) => [],
  );
});
