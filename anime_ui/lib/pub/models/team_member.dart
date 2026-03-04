class TeamMember {
  final String id;
  final String teamId;
  final String userId;
  final String role;
  final List<String> jobRoles;
  final String joinedAt;
  final String username;
  final String displayName;

  const TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.role,
    this.jobRoles = const [],
    this.joinedAt = '',
    this.username = '',
    this.displayName = '',
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String? ?? '',
        teamId: json['teamId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        role: json['role'] as String? ?? 'viewer',
        jobRoles: (json['jobRoles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        joinedAt: json['joinedAt'] as String? ?? '',
        username: json['username'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
      );
}
