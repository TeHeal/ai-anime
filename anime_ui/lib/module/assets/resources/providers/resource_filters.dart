import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/resource.dart';

import '../models/resource_category.dart';
import '../models/resource_meta_schema.dart';
import 'resource_list.dart';

/// 泛型简单值 Notifier，用于单值状态管理
class _ValueNotifier<T> extends Notifier<T> {
  _ValueNotifier(this._initial);
  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

/// 选中模态
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

  /// API sort_by 参数值
  String get apiValue => switch (this) {
        ResourceSort.newest => 'newest',
        ResourceSort.oldest => 'oldest',
        ResourceSort.nameAsc => 'name_asc',
        ResourceSort.nameDesc => 'name_desc',
      };

  /// 排序方向图标
  IconData get sortIcon => switch (this) {
        ResourceSort.newest => Icons.arrow_downward,
        ResourceSort.oldest => Icons.arrow_upward,
        ResourceSort.nameAsc => Icons.sort_by_alpha,
        ResourceSort.nameDesc => Icons.sort_by_alpha,
      };
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

/// 是否有活跃的筛选条件（用于显示「清除筛选」按钮）
final hasActiveFiltersProvider = Provider<bool>((ref) {
  final tags = ref.watch(selectedTagsProvider);
  final meta = ref.watch(selectedMetaFiltersProvider);
  final search = ref.watch(resourceSearchProvider);
  return tags.isNotEmpty || meta.isNotEmpty || search.trim().isNotEmpty;
});

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
