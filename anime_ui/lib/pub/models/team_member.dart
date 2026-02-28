class TeamMember {
  final String id;
  final String teamId;
  final String userId;
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
        id: json['id'].toString(),
        teamId: json['team_id'].toString(),
        userId: json['user_id'].toString(),
        role: json['role'] as String? ?? 'viewer',
        joinedAt: json['joined_at'] as String? ?? '',
      );
}
