// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Asset _$AssetFromJson(Map<String, dynamic> json) => _Asset(
  id: (json['id'] as num?)?.toInt(),
  projectId: (json['projectId'] as num?)?.toInt(),
  type: json['type'] as String? ?? 'scene',
  name: json['name'] as String? ?? '',
  desc: json['desc'] as String? ?? '',
  imageUrl: json['imageUrl'] as String? ?? '',
  tags: json['tags'] as String? ?? '',
  shared: json['shared'] as bool? ?? false,
);

Map<String, dynamic> _$AssetToJson(_Asset instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'type': instance.type,
  'name': instance.name,
  'desc': instance.desc,
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
  'shared': instance.shared,
};
