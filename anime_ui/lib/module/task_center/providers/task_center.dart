import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/task.dart';
import 'package:anime_ui/pub/services/task_svc.dart';
import 'package:anime_ui/pub/services/realtime_svc.dart';

class TaskCenterState {
  final List<Task> tasks;
  final bool loading;
  final String? error;
  final String? statusFilter;
  final String? typeFilter;

  const TaskCenterState({
    this.tasks = const [],
    this.loading = false,
    this.error,
    this.statusFilter,
    this.typeFilter,
  });

  TaskCenterState copyWith({
    List<Task>? tasks,
    bool? loading,
    String? error,
    String? statusFilter,
    String? typeFilter,
  }) {
    return TaskCenterState(
      tasks: tasks ?? this.tasks,
      loading: loading ?? this.loading,
      error: error,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }

  int get runningCount => tasks.where((t) => t.isRunning).length;
  int get pendingCount => tasks.where((t) => t.isPending).length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get failedCount => tasks.where((t) => t.isFailed).length;

  /// 按筛选条件过滤后的任务列表
  List<Task> get filteredTasks {
    var result = tasks;
    if (statusFilter != null && statusFilter!.isNotEmpty) {
      result = result.where((t) => t.status == statusFilter).toList();
    }
    if (typeFilter != null && typeFilter!.isNotEmpty) {
      result = result.where((t) => t.type == typeFilter).toList();
    }
    return result;
  }

  /// 按类型分组
  Map<String, List<Task>> get groupedByType {
    final map = <String, List<Task>>{};
    for (final t in filteredTasks) {
      map.putIfAbsent(t.type, () => []).add(t);
    }
    return map;
  }
}

class TaskCenterNotifier extends Notifier<TaskCenterState> {
  final _svc = TaskService();
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  @override
  TaskCenterState build() {
    _load();
    _listenWs();
    ref.onDispose(() => _wsSub?.cancel());
    return const TaskCenterState(loading: true);
  }

  Future<void> _load() async {
    try {
      final tasks = await _svc.list(limit: 50);
      state = state.copyWith(tasks: tasks, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void _listenWs() {
    _wsSub = realtimeWS.events.listen((event) {
      final type = event['type'] as String?;
      if (type != 'task_progress' &&
          type != 'task_complete' &&
          type != 'task_error') return;
      final data = event['data'];
      if (data is! Map<String, dynamic>) return;
      try {
        final updated = Task.fromJson(data);
        _upsertTask(updated);
      } catch (e, st) {
        debugPrint('解析 WS 任务更新失败: $e\n$st');
      }
    });
  }

  void _upsertTask(Task updated) {
    final tasks = [...state.tasks];
    final idx = tasks.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) {
      tasks[idx] = updated;
    } else {
      tasks.insert(0, updated);
    }
    state = state.copyWith(tasks: tasks);
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    await _load();
  }

  void setStatusFilter(String? filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setTypeFilter(String? filter) {
    state = state.copyWith(typeFilter: filter);
  }
}

final taskCenterProvider =
    NotifierProvider<TaskCenterNotifier, TaskCenterState>(
  TaskCenterNotifier.new,
);
