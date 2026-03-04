import 'package:anime_ui/pub/models/team.dart';
import 'package:anime_ui/pub/models/team_member.dart';
import 'api_svc.dart';

/// 团队 API 服务 — 路由: /orgs/:orgId/teams/...
class TeamService {
  Future<List<Team>> listByOrg(String orgId) async {
    final resp = await dio.get('/orgs/$orgId/teams');
    return extractDataList(resp, Team.fromJson);
  }

  Future<Team> create(String orgId, String name, String description) async {
    final resp = await dio.post('/orgs/$orgId/teams', data: {
      'name': name,
      'description': description,
    });
    return extractDataObject(resp, Team.fromJson);
  }

  Future<Team> get(String orgId, String teamId) async {
    final resp = await dio.get('/orgs/$orgId/teams/$teamId');
    return extractDataObject(resp, Team.fromJson);
  }

  Future<Team> update(String orgId, String teamId, {String? name, String? description}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    final resp = await dio.put('/orgs/$orgId/teams/$teamId', data: body);
    return extractDataObject(resp, Team.fromJson);
  }

  Future<void> delete(String orgId, String teamId) async {
    await dio.delete('/orgs/$orgId/teams/$teamId');
  }

  Future<List<TeamMember>> listMembers(String orgId, String teamId) async {
    final resp = await dio.get('/orgs/$orgId/teams/$teamId/members');
    return extractDataList(resp, TeamMember.fromJson);
  }

  Future<void> addMember(
    String orgId,
    String teamId, {
    required String userId,
    String role = 'viewer',
    List<String> jobRoles = const [],
  }) async {
    await dio.post('/orgs/$orgId/teams/$teamId/members', data: {
      'userId': userId,
      'role': role,
      'jobRoles': jobRoles,
    });
  }

  Future<void> updateMember(
    String orgId,
    String teamId,
    String userId, {
    String? role,
    List<String>? jobRoles,
  }) async {
    final body = <String, dynamic>{};
    if (role != null) body['role'] = role;
    if (jobRoles != null) body['jobRoles'] = jobRoles;
    await dio.put('/orgs/$orgId/teams/$teamId/members/$userId', data: body);
  }

  Future<void> removeMember(String orgId, String teamId, String userId) async {
    await dio.delete('/orgs/$orgId/teams/$teamId/members/$userId');
  }
}
