import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_asset.freezed.dart';
part 'media_asset.g.dart';

@freezed
abstract class MediaAsset with _$MediaAsset {
  const MediaAsset._();

  const factory MediaAsset({
    String? id,
    required String projectId,
    required String userId,
    String? episodeId,
    String? sceneId,
    String? shotId,
    String? characterId,
    String? locationId,
    @Default('') String type,
    @Default('') String subType,
    @Default('') String name,
    @Default('') String fileUrl,
    @Default('') String filePath,
    @Default(0) int fileSize,
    @Default('') String fileHash,
    @Default('') String mimeType,
    @Default(0) int width,
    @Default(0) int height,
    @Default(0.0) double duration,
    @Default('ai') String source,
    String? promptId,
    @Default('') String taskId,
    @Default('') String provider,
    @Default('') String model,
    @Default(1) int version,
    String? parentId,
    @Default('active') String status,
    @Default('') String roleIds,
    @Default('') String tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MediaAsset;

  factory MediaAsset.fromJson(Map<String, dynamic> json) =>
      _$MediaAssetFromJson(json);

  bool get isActive => status == 'active';
  bool get isApproved => status == 'approved';
  bool get isDeprecated => status == 'deprecated';
  bool get isImage => type.contains('image');
  bool get isVideo => type.contains('video');
  bool get isAudio => type == 'voiceover' || type == 'bgm' || type == 'sfx';

  String get fileSizeHuman {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

@freezed
abstract class MediaAssetStats with _$MediaAssetStats {
  const factory MediaAssetStats({
    @Default(0) int total,
    @Default({}) Map<String, TypeStats> byType,
    @Default({}) Map<String, int> byStatus,
    @Default(0) int totalFileSize,
  }) = _MediaAssetStats;

  factory MediaAssetStats.fromJson(Map<String, dynamic> json) =>
      _$MediaAssetStatsFromJson(json);
}

@freezed
abstract class TypeStats with _$TypeStats {
  const factory TypeStats({
    @Default(0) int total,
    @Default(0) int active,
    @Default(0) int deprecated,
  }) = _TypeStats;

  factory TypeStats.fromJson(Map<String, dynamic> json) =>
      _$TypeStatsFromJson(json);
}
