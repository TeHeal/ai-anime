import 'package:anime_ui/pub/models/organization.dart';
import 'package:anime_ui/pub/models/user.dart';
import 'api.dart';

class OrgService {
  Future<List<Organization>> list() async {
    final resp = await dio.get('/orgs');
    return extractDataList(resp, Organization.fromJson);
  }

  Future<Organization> create(String name) async {
    final resp = await dio.post('/orgs', data: {'name': name});
    return extractDataObject(resp, Organization.fromJson);
  }

  Future<List<User>> listMembers(int orgId) async {
    final resp = await dio.get('/orgs/$orgId/members');
    return extractDataList(resp, User.fromJson);
  }

  Future<void> addMember(int orgId, int userId, String role) async {
    final resp = await dio.post('/orgs/$orgId/members', data: {
      'user_id': userId,
      'role': role,
    });
    extractData<dynamic>(resp);
  }

  Future<void> removeMember(int orgId, int userId) async {
    final resp = await dio.delete('/orgs/$orgId/members/$userId');
    extractData<dynamic>(resp);
  }
}
