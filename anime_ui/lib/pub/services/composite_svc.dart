import 'api.dart';

/// 成片导出任务（README 成片阶段）
class CompositeTask {
  CompositeTask({
    required this.id,
    required this.projectId,
    required this.episodeId,
    this.taskId,
    required this.status,
    this.outputUrl,
    this.errorMsg,
  });

  final String id;
  final String projectId;
  final String episodeId;
  final String? taskId;
  final String status;
  final String? outputUrl;
  final String? errorMsg;

  static CompositeTask fromJson(Map<String, dynamic> json) {
    return CompositeTask(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      episodeId: json['episode_id']?.toString() ?? '',
      taskId: json['task_id']?.toString(),
      status: json['status'] as String? ?? 'pending',
      outputUrl: json['output_url']?.toString(),
      errorMsg: json['error_msg']?.toString(),
    );
  }

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isExporting => status == 'exporting';
}

/// 成片导出服务（README 2.1 成片模块）
class CompositeService {
  /// 创建导出任务
  Future<CompositeTask> createExport(
    String projectId,
    String episodeId, {
    String? episodeIdOverride,
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/episodes/$episodeId/export',
      data: episodeIdOverride != null ? {'episode_id': episodeIdOverride} : {},
    );
    final data = extractData<Map<String, dynamic>>(resp);
    return CompositeTask.fromJson(data);
  }

  /// 获取单个成片任务状态
  Future<CompositeTask> get(String projectId, String taskId) async {
    final resp = await dio.get('/projects/$projectId/composite/$taskId');
    final data = extractData<Map<String, dynamic>>(resp);
    return CompositeTask.fromJson(data);
  }

  /// 按集列出成片任务
  Future<List<CompositeTask>> listByEpisode(
    String projectId,
    String episodeId,
  ) async {
    final resp = await dio.get(
      '/projects/$projectId/episodes/$episodeId/composite',
    );
    final data = extractData<Map<String, dynamic>>(resp);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CompositeTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 按项目列出成片任务
  Future<List<CompositeTask>> listByProject(String projectId) async {
    final resp = await dio.get('/projects/$projectId/composite');
    final data = extractData<Map<String, dynamic>>(resp);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CompositeTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
