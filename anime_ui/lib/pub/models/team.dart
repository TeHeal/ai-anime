class Team {
  final String id;
  final String orgId;
  final String name;
  final String description;

  const Team({
    required this.id,
    required this.orgId,
    required this.name,
    this.description = '',
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as String? ?? '',
        orgId: json['orgId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}
