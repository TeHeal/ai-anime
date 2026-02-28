class TeamMember {
  final int id;
  final int teamId;
  final int userId;
  final String role;
  final String joinedAt;

  TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.role,
    this.joinedAt = '',
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as int,
        teamId: json['team_id'] as int,
        userId: json['user_id'] as int,
        role: json['role'] as String? ?? 'viewer',
        joinedAt: json['joined_at'] as String? ?? '',
      );
}
