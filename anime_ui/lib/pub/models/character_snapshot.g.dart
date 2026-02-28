// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CharacterSnapshot _$CharacterSnapshotFromJson(Map<String, dynamic> json) =>
    _CharacterSnapshot(
      id: json['id'] as String?,
      characterId: json['characterId'] as String,
      projectId: json['projectId'] as String,
      startSceneId: json['startSceneId'] as String? ?? '',
      endSceneId: json['endSceneId'] as String? ?? '',
      triggerEvent: json['triggerEvent'] as String? ?? '',
      costume: json['costume'] as String? ?? '',
      hairstyle: json['hairstyle'] as String? ?? '',
      physicalMarks: json['physicalMarks'] as String? ?? '',
      accessories: json['accessories'] as String? ?? '',
      mentalState: json['mentalState'] as String? ?? '',
      demeanor: json['demeanor'] as String? ?? '',
      relationshipsJson: json['relationshipsJson'] as String? ?? '',
      composedAppearance: json['composedAppearance'] as String? ?? '',
      sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
      source: json['source'] as String? ?? 'ai',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CharacterSnapshotToJson(_CharacterSnapshot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'characterId': instance.characterId,
      'projectId': instance.projectId,
      'startSceneId': instance.startSceneId,
      'endSceneId': instance.endSceneId,
      'triggerEvent': instance.triggerEvent,
      'costume': instance.costume,
      'hairstyle': instance.hairstyle,
      'physicalMarks': instance.physicalMarks,
      'accessories': instance.accessories,
      'mentalState': instance.mentalState,
      'demeanor': instance.demeanor,
      'relationshipsJson': instance.relationshipsJson,
      'composedAppearance': instance.composedAppearance,
      'sortIndex': instance.sortIndex,
      'source': instance.source,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
