// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PromptRecord _$PromptRecordFromJson(Map<String, dynamic> json) =>
    _PromptRecord(
      id: (json['id'] as num?)?.toInt(),
      projectId: (json['projectId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      episodeId: (json['episodeId'] as num?)?.toInt(),
      sceneId: (json['sceneId'] as num?)?.toInt(),
      shotId: (json['shotId'] as num?)?.toInt(),
      characterId: (json['characterId'] as num?)?.toInt(),
      locationId: (json['locationId'] as num?)?.toInt(),
      type: json['type'] as String? ?? '',
      inputText: json['inputText'] as String? ?? '',
      fullPrompt: json['fullPrompt'] as String? ?? '',
      negativePrompt: json['negativePrompt'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      paramsJson: json['paramsJson'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? 'ai',
      assetIds: json['assetIds'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PromptRecordToJson(_PromptRecord instance) =>
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
      'inputText': instance.inputText,
      'fullPrompt': instance.fullPrompt,
      'negativePrompt': instance.negativePrompt,
      'provider': instance.provider,
      'model': instance.model,
      'paramsJson': instance.paramsJson,
      'createdBy': instance.createdBy,
      'assetIds': instance.assetIds,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
