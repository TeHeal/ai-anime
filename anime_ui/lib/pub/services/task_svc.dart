import 'dart:async';

import 'package:anime_ui/pub/models/task.dart';
import 'api_svc.dart';

class TaskService {
  /// 获取单个任务详情
  Future<Task> get(String taskId) async {
    final resp = await dio.get('/tasks/$taskId');
    return extractDataObject(resp, Task.fromJson);
  }

  /// 任务列表（支持 project_id、type、status 过滤和分页）
  Future<List<Task>> list({
    String? projectId,
    String? type,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (projectId != null) params['project_id'] = projectId;
    if (type != null) params['type'] = type;
    if (status != null) params['status'] = status;
    final resp = await dio.get('/tasks', queryParameters: params);
    final wrapper = extractData<Map<String, dynamic>>(resp);
    final items = wrapper['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 批量获取任务
  Future<List<Task>> batchGet(List<String> taskIds) async {
    final resp = await dio.post('/tasks/batch', data: {
      'action': 'get',
      'task_ids': taskIds,
    });
    final wrapper = extractData<Map<String, dynamic>>(resp);
    final items = wrapper['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 取消单个任务
  Future<Task> cancel(String taskId) async {
    final resp = await dio.put('/tasks/$taskId/cancel');
    return extractDataObject(resp, Task.fromJson);
  }

  /// 批量取消任务
  Future<void> batchCancel(List<String> taskIds) async {
    final resp = await dio.post('/tasks/batch', data: {
      'action': 'cancel',
      'task_ids': taskIds,
    });
    extractData(resp);
  }

  /// 轮询任务直到结束，逐次返回中间状态
  Stream<Task> poll(String taskId, {Duration interval = const Duration(seconds: 2)}) async* {
    while (true) {
      final task = await get(taskId);
      yield task;
      if (task.isFinished) break;
      await Future.delayed(interval);
    }
  }
}
