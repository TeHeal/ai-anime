import 'package:anime_ui/pub/models/team.dart';
import 'package:anime_ui/pub/models/team_member.dart';
import 'api.dart';

class TeamService {
  Future<List<Team>> listByOrg(String orgId) async {
    final resp = await dio.get('/orgs/$orgId/teams');
    return extractDataList(resp, Team.fromJson);
  }

  Future<List<Team>> listMyTeams() async {
    final resp = await dio.get('/teams');
    return extractDataList(resp, Team.fromJson);
  }

  Future<Team> create(String orgId, String name, String description) async {
    final resp = await dio.post('/orgs/$orgId/teams', data: {
      'name': name,
      'description': description,
    });
    return extractDataObject(resp, Team.fromJson);
  }

  Future<List<TeamMember>> listMembers(String teamId) async {
    final resp = await dio.get('/teams/$teamId/members');
    return extractDataList(resp, TeamMember.fromJson);
  }

  Future<void> addMember(String teamId, String userId, String role) async {
    final resp = await dio.post('/teams/$teamId/members', data: {
      'user_id': userId,
      'role': role,
    });
    extractData<dynamic>(resp);
  }

  Future<void> updateMemberRole(String teamId, String userId, String role) async {
    final resp = await dio.put('/teams/$teamId/members/$userId', data: {
      'role': role,
    });
    extractData<dynamic>(resp);
  }

  Future<void> removeMember(String teamId, String userId) async {
    final resp = await dio.delete('/teams/$teamId/members/$userId');
    extractData<dynamic>(resp);
  }
}
