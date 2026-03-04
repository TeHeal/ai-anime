import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_ui/pub/models/project_member.dart';
import 'package:anime_ui/pub/services/project_member_svc.dart';

final projectMemberServiceProvider = Provider((_) => ProjectMemberService());

/// 项目成员列表 Provider（按 projectId 族化，autoDispose 减少内存开销）
final projectMembersProvider =
    FutureProvider.autoDispose.family<List<ProjectMember>, String>(
  (ref, projectId) async {
    final svc = ref.read(projectMemberServiceProvider);
    return svc.list(projectId);
  },
);

/// 操作类封装（添加/更新/移除后 invalidate provider 即可刷新）
class ProjectMemberActions {
  final ProjectMemberService _svc;
  const ProjectMemberActions(this._svc);

  Future<void> addMember(
    String projectId, {
    required String userId,
    String role = 'viewer',
    List<String> jobRoles = const [],
  }) =>
      _svc.add(projectId, userId: userId, role: role, jobRoles: jobRoles);

  Future<void> updateJobRoles(
    String projectId,
    String userId,
    List<String> jobRoles,
  ) =>
      _svc.updateJobRoles(projectId, userId, jobRoles: jobRoles);

  Future<void> updateRole(
    String projectId,
    String userId,
    String role,
  ) =>
      _svc.updateRole(projectId, userId, role: role);

  Future<void> removeMember(String projectId, String userId) =>
      _svc.remove(projectId, userId);
}

final projectMemberActionsProvider = Provider(
  (ref) => ProjectMemberActions(ref.read(projectMemberServiceProvider)),
);
