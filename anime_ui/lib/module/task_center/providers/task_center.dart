import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/task.dart';
import 'package:anime_ui/pub/services/task_svc.dart';

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

  int get runningCount => tasks.where((t) => t.isRunning).length;
  int get pendingCount => tasks.where((t) => t.isPending).length;
}

class TaskCenterNotifier extends Notifier<TaskCenterState> {
  final _svc = TaskService();

  @override
  TaskCenterState build() {
    _load();
    return const TaskCenterState(loading: true);
  }

  Future<void> _load() async {
    try {
      final tasks = await _svc.list(limit: 50);
      state = TaskCenterState(tasks: tasks, loading: false);
    } catch (e) {
      state = TaskCenterState(loading: false, error: e.toString());
    }
  }
}

final taskCenterProvider =
    NotifierProvider<TaskCenterNotifier, TaskCenterState>(
  TaskCenterNotifier.new,
);
