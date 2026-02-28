class LockStatus {
  final bool storyLocked;
  final DateTime? storyLockedAt;
  final bool assetsLocked;
  final DateTime? assetsLockedAt;
  final bool scriptLocked;
  final DateTime? scriptLockedAt;

  const LockStatus({
    this.storyLocked = false,
    this.storyLockedAt,
    this.assetsLocked = false,
    this.assetsLockedAt,
    this.scriptLocked = false,
    this.scriptLockedAt,
  });

  factory LockStatus.fromJson(Map<String, dynamic> json) => LockStatus(
        storyLocked: json['story_locked'] as bool? ?? false,
        storyLockedAt: json['story_locked_at'] != null
            ? DateTime.tryParse(json['story_locked_at'] as String)
            : null,
        assetsLocked: json['assets_locked'] as bool? ?? false,
        assetsLockedAt: json['assets_locked_at'] != null
            ? DateTime.tryParse(json['assets_locked_at'] as String)
            : null,
        scriptLocked: json['script_locked'] as bool? ?? false,
        scriptLockedAt: json['script_locked_at'] != null
            ? DateTime.tryParse(json['script_locked_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'story_locked': storyLocked,
        if (storyLockedAt != null)
          'story_locked_at': storyLockedAt!.toIso8601String(),
        'assets_locked': assetsLocked,
        if (assetsLockedAt != null)
          'assets_locked_at': assetsLockedAt!.toIso8601String(),
        'script_locked': scriptLocked,
        if (scriptLockedAt != null)
          'script_locked_at': scriptLockedAt!.toIso8601String(),
      };

  bool isLocked(String phase) {
    switch (phase) {
      case 'story':
        return storyLocked;
      case 'assets':
        return assetsLocked;
      case 'script':
        return scriptLocked;
      default:
        return false;
    }
  }
}
