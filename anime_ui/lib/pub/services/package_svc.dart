import 'api.dart';

/// 按集打包配置
class PackageConfig {
  PackageConfig({
    this.includeShotImages = true,
    this.includeVoices = true,
    this.includeShots = true,
    this.includeFinal = true,
  });

  final bool includeShotImages;
  final bool includeVoices;
  final bool includeShots;
  final bool includeFinal;

  Map<String, dynamic> toJson() => {
        'include_shot_images': includeShotImages,
        'include_voices': includeVoices,
        'include_shots': includeShots,
        'include_final': includeFinal,
      };
}

/// 按集打包任务（README 2.7 生成物下载）
class PackageTask {
  PackageTask({
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

  static PackageTask fromJson(Map<String, dynamic> json) {
    return PackageTask(
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
  bool get isPackaging => status == 'packaging';
}

/// 按集打包服务（README 2.7）
class PackageService {
  /// 请求按集打包
  Future<PackageTask> requestPackage(
    String projectId,
    String episodeId, {
    PackageConfig? config,
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/episodes/$episodeId/package',
      data: config != null ? {'config': config.toJson()} : {},
    );
    final data = extractData<Map<String, dynamic>>(resp);
    return PackageTask.fromJson(data);
  }

  /// 获取单个打包任务状态
  Future<PackageTask> get(String projectId, String taskId) async {
    final resp = await dio.get('/projects/$projectId/package/$taskId');
    final data = extractData<Map<String, dynamic>>(resp);
    return PackageTask.fromJson(data);
  }

  /// 按集列出打包任务
  Future<List<PackageTask>> listByEpisode(
    String projectId,
    String episodeId,
  ) async {
    final resp = await dio.get(
      '/projects/$projectId/episodes/$episodeId/package',
    );
    final data = extractData<Map<String, dynamic>>(resp);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => PackageTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
