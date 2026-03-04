import 'package:anime_ui/pub/models/project_member.dart';
import 'api_svc.dart';

/// 项目成员 API 服务 — 路由: /projects/:id/members/...
class ProjectMemberService {
  Future<List<ProjectMember>> list(String projectId) async {
    final resp = await dio.get('/projects/$projectId/members');
    return extractDataList(resp, ProjectMember.fromJson);
  }

  Future<ProjectMember> add(
    String projectId, {
    required String userId,
    String role = 'viewer',
    List<String> jobRoles = const [],
  }) async {
    final resp = await dio.post('/projects/$projectId/members', data: {
      'userId': userId,
      'role': role,
      'job_roles': jobRoles,
    });
    return extractDataObject(resp, ProjectMember.fromJson);
  }

  Future<void> updateRole(
    String projectId,
    String userId, {
    required String role,
  }) async {
    await dio.put('/projects/$projectId/members/$userId', data: {
      'role': role,
    });
  }

  Future<void> updateJobRoles(
    String projectId,
    String userId, {
    required List<String> jobRoles,
  }) async {
    await dio.put('/projects/$projectId/members/$userId/job-roles', data: {
      'job_roles': jobRoles,
    });
  }

  Future<void> remove(String projectId, String userId) async {
    await dio.delete('/projects/$projectId/members/$userId');
  }
}
