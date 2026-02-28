// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaAsset _$MediaAssetFromJson(Map<String, dynamic> json) => _MediaAsset(
  id: (json['id'] as num?)?.toInt(),
  projectId: (json['projectId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  episodeId: (json['episodeId'] as num?)?.toInt(),
  sceneId: (json['sceneId'] as num?)?.toInt(),
  shotId: (json['shotId'] as num?)?.toInt(),
  characterId: (json['characterId'] as num?)?.toInt(),
  locationId: (json['locationId'] as num?)?.toInt(),
  type: json['type'] as String? ?? '',
  subType: json['subType'] as String? ?? '',
  name: json['name'] as String? ?? '',
  fileUrl: json['fileUrl'] as String? ?? '',
  filePath: json['filePath'] as String? ?? '',
  fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
  fileHash: json['fileHash'] as String? ?? '',
  mimeType: json['mimeType'] as String? ?? '',
  width: (json['width'] as num?)?.toInt() ?? 0,
  height: (json['height'] as num?)?.toInt() ?? 0,
  duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
  source: json['source'] as String? ?? 'ai',
  promptId: (json['promptId'] as num?)?.toInt(),
  taskId: json['taskId'] as String? ?? '',
  provider: json['provider'] as String? ?? '',
  model: json['model'] as String? ?? '',
  version: (json['version'] as num?)?.toInt() ?? 1,
  parentId: (json['parentId'] as num?)?.toInt(),
  status: json['status'] as String? ?? 'active',
  roleIds: json['roleIds'] as String? ?? '',
  tags: json['tags'] as String? ?? '',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MediaAssetToJson(_MediaAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'userId': instance.userId,
      'episodeId': instance.episodeId,
      'sceneId': instance.sceneId,
      'shotId': instance.shotId,
      'characterId': instance.characterId,
      'locationId': instance.locationId,
      'type': instance.type,
      'subType': instance.subType,
      'name': instance.name,
      'fileUrl': instance.fileUrl,
      'filePath': instance.filePath,
      'fileSize': instance.fileSize,
      'fileHash': instance.fileHash,
      'mimeType': instance.mimeType,
      'width': instance.width,
      'height': instance.height,
      'duration': instance.duration,
      'source': instance.source,
      'promptId': instance.promptId,
      'taskId': instance.taskId,
      'provider': instance.provider,
      'model': instance.model,
      'version': instance.version,
      'parentId': instance.parentId,
      'status': instance.status,
      'roleIds': instance.roleIds,
      'tags': instance.tags,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_MediaAssetStats _$MediaAssetStatsFromJson(Map<String, dynamic> json) =>
    _MediaAssetStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      byType:
          (json['byType'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, TypeStats.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      byStatus:
          (json['byStatus'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      totalFileSize: (json['totalFileSize'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MediaAssetStatsToJson(_MediaAssetStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'byType': instance.byType,
      'byStatus': instance.byStatus,
      'totalFileSize': instance.totalFileSize,
    };

_TypeStats _$TypeStatsFromJson(Map<String, dynamic> json) => _TypeStats(
  total: (json['total'] as num?)?.toInt() ?? 0,
  active: (json['active'] as num?)?.toInt() ?? 0,
  deprecated: (json['deprecated'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TypeStatsToJson(_TypeStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'active': instance.active,
      'deprecated': instance.deprecated,
    };
