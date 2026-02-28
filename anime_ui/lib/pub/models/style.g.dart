// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Style _$StyleFromJson(Map<String, dynamic> json) => _Style(
  id: (json['id'] as num?)?.toInt(),
  projectId: (json['projectId'] as num?)?.toInt(),
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  negativePrompt: json['negativePrompt'] as String? ?? '',
  referenceImagesJson: json['referenceImagesJson'] as String? ?? '',
  thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
  isPreset: json['isPreset'] as bool? ?? false,
  isProjectDefault: json['isProjectDefault'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$StyleToJson(_Style instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'name': instance.name,
  'description': instance.description,
  'negativePrompt': instance.negativePrompt,
  'referenceImagesJson': instance.referenceImagesJson,
  'thumbnailUrl': instance.thumbnailUrl,
  'isPreset': instance.isPreset,
  'isProjectDefault': instance.isProjectDefault,
  'createdAt': instance.createdAt?.toIso8601String(),
};
