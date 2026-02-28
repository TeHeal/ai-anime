// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Scene _$SceneFromJson(Map<String, dynamic> json) => _Scene(
  id: json['id'] as String?,
  episodeId: json['episodeId'] as String?,
  sceneId: json['sceneId'] as String? ?? '',
  location: json['location'] as String? ?? '',
  time: json['time'] as String? ?? '',
  interiorExterior: json['interiorExterior'] as String? ?? '',
  characters:
      (json['characters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
  blocks:
      (json['blocks'] as List<dynamic>?)
          ?.map((e) => SceneBlock.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SceneToJson(_Scene instance) => <String, dynamic>{
  'id': instance.id,
  'episodeId': instance.episodeId,
  'sceneId': instance.sceneId,
  'location': instance.location,
  'time': instance.time,
  'interiorExterior': instance.interiorExterior,
  'characters': instance.characters,
  'sortIndex': instance.sortIndex,
  'blocks': instance.blocks,
};
