/// 项目成员（对应后端 project_members 表）
class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final String role;
  final List<String> jobRoles;
  final String joinedAt;
  final String username;
  final String displayName;

  const ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    this.jobRoles = const [],
    this.joinedAt = '',
    this.username = '',
    this.displayName = '',
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) => ProjectMember(
        id: _str(json['id']),
        projectId: _str(json['project_id'] ?? json['projectId']),
        userId: _str(json['user_id'] ?? json['userId']),
        role: json['role'] as String? ?? 'viewer',
        jobRoles: (json['job_roles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            (json['jobRoles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        joinedAt: json['joined_at'] as String? ??
            json['joinedAt'] as String? ??
            '',
        username: json['username'] as String? ?? '',
        displayName: json['display_name'] as String? ??
            json['displayName'] as String? ??
            '',
      );

  bool get isOwner => role == 'owner';

  ProjectMember copyWith({
    String? role,
    List<String>? jobRoles,
  }) =>
      ProjectMember(
        id: id,
        projectId: projectId,
        userId: userId,
        role: role ?? this.role,
        jobRoles: jobRoles ?? this.jobRoles,
        joinedAt: joinedAt,
        username: username,
        displayName: displayName,
      );
}

String _str(dynamic v) {
  if (v is String) return v;
  if (v != null) return v.toString();
  return '';
}
