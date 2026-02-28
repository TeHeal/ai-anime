// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Resource _$ResourceFromJson(Map<String, dynamic> json) => _Resource(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  name: json['name'] as String? ?? '',
  libraryType: json['libraryType'] as String? ?? '',
  modality: json['modality'] as String? ?? '',
  thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
  tagsJson: json['tagsJson'] as String? ?? '',
  version: json['version'] as String? ?? '',
  metadataJson: json['metadataJson'] as String? ?? '',
  bindingIdsJson: json['bindingIdsJson'] as String? ?? '',
  description: json['description'] as String? ?? '',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ResourceToJson(_Resource instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'libraryType': instance.libraryType,
  'modality': instance.modality,
  'thumbnailUrl': instance.thumbnailUrl,
  'tagsJson': instance.tagsJson,
  'version': instance.version,
  'metadataJson': instance.metadataJson,
  'bindingIdsJson': instance.bindingIdsJson,
  'description': instance.description,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
