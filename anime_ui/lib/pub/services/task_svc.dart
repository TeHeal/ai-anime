import 'dart:async';

import 'package:anime_ui/pub/models/task.dart';
import 'api.dart';

class TaskService {
  Future<Task> get(String taskId) async {
    final resp = await dio.get('/tasks/$taskId');
    return extractDataObject(resp, Task.fromJson);
  }

  Future<List<Task>> list({String? type, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (type != null) params['type'] = type;
    final resp = await dio.get('/tasks', queryParameters: params);
    return extractDataList(resp, Task.fromJson);
  }

  Future<List<Task>> batchGet(List<String> taskIds) async {
    final resp = await dio.post('/tasks/batch', data: {'task_ids': taskIds});
    return extractDataList(resp, Task.fromJson);
  }

  /// Polls a task until it's finished. Yields each intermediate state.
  Stream<Task> poll(String taskId, {Duration interval = const Duration(seconds: 2)}) async* {
    while (true) {
      final task = await get(taskId);
      yield task;
      if (task.isFinished) break;
      await Future.delayed(interval);
    }
  }
}
