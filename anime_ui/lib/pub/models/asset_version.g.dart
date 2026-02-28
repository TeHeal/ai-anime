// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetVersion _$AssetVersionFromJson(Map<String, dynamic> json) =>
    _AssetVersion(
      id: (json['id'] as num?)?.toInt(),
      projectId: (json['projectId'] as num?)?.toInt(),
      version: (json['version'] as num?)?.toInt() ?? 0,
      action: json['action'] as String? ?? '',
      statsJson: json['statsJson'] as String? ?? '',
      deltaJson: json['deltaJson'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AssetVersionToJson(_AssetVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'version': instance.version,
      'action': instance.action,
      'statsJson': instance.statsJson,
      'deltaJson': instance.deltaJson,
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
