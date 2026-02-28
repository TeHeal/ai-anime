class Team {
  final int id;
  final int orgId;
  final String name;
  final String description;

  Team({
    required this.id,
    required this.orgId,
    required this.name,
    this.description = '',
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as int,
        orgId: json['org_id'] as int,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
      );
}
