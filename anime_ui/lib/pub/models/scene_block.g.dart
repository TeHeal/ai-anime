// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SceneBlock _$SceneBlockFromJson(Map<String, dynamic> json) => _SceneBlock(
  id: json['id'] as String?,
  sceneId: json['sceneId'] as String?,
  type: json['type'] as String? ?? 'action',
  character: json['character'] as String? ?? '',
  emotion: json['emotion'] as String? ?? '',
  content: json['content'] as String? ?? '',
  sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SceneBlockToJson(_SceneBlock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sceneId': instance.sceneId,
      'type': instance.type,
      'character': instance.character,
      'emotion': instance.emotion,
      'content': instance.content,
      'sortIndex': instance.sortIndex,
    };
