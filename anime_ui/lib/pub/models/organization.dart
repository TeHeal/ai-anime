class Organization {
  final int id;
  final String name;
  final String avatarUrl;
  final int ownerId;

  Organization({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    required this.ownerId,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json['id'] as int,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String? ?? '',
        ownerId: json['owner_id'] as int,
      );
}
