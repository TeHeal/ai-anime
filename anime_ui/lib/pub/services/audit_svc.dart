import 'api.dart';

class AuditLog {
  final int id;
  final int projectId;
  final int userId;
  final String action;
  final String detail;
  final String createdAt;

  AuditLog({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.action,
    required this.detail,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        userId: json['user_id'] as int,
        action: json['action'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );
}

class AuditService {
  Future<List<AuditLog>> listByProject(
    int projectId, {
    int? limit,
    int? offset,
  }) async {
    final params = <String, dynamic>{};
    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;
    final resp = await dio.get(
      '/projects/$projectId/audit-logs',
      queryParameters: params,
    );
    return extractDataList(resp, AuditLog.fromJson);
  }
}
