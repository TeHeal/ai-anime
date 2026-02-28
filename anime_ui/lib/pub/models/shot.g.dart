// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoryboardShot _$StoryboardShotFromJson(Map<String, dynamic> json) =>
    _StoryboardShot(
      id: (json['id'] as num?)?.toInt(),
      projectId: (json['projectId'] as num?)?.toInt(),
      segmentId: (json['segmentId'] as num?)?.toInt(),
      sceneId: (json['sceneId'] as num?)?.toInt(),
      sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
      prompt: json['prompt'] as String? ?? '',
      stylePrompt: json['stylePrompt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      taskId: json['taskId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      duration: (json['duration'] as num?)?.toInt() ?? 5,
      cameraType: json['cameraType'] as String?,
      cameraAngle: json['cameraAngle'] as String?,
      dialogue: json['dialogue'] as String?,
      voice: json['voice'] as String?,
      lipSync: json['lipSync'] as String? ?? '口型同步',
      characterName: json['characterName'] as String?,
      characterId: (json['characterId'] as num?)?.toInt(),
      emotion: json['emotion'] as String?,
      voiceName: json['voiceName'] as String?,
      transition: json['transition'] as String?,
      audioDesign: json['audioDesign'] as String?,
      priority: json['priority'] as String?,
      negativePrompt: json['negativePrompt'] as String?,
      reviewStatus: json['reviewStatus'] as String? ?? 'pending',
      reviewComment: json['reviewComment'] as String?,
    );

Map<String, dynamic> _$StoryboardShotToJson(_StoryboardShot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'segmentId': instance.segmentId,
      'sceneId': instance.sceneId,
      'sortIndex': instance.sortIndex,
      'prompt': instance.prompt,
      'stylePrompt': instance.stylePrompt,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'taskId': instance.taskId,
      'status': instance.status,
      'duration': instance.duration,
      'cameraType': instance.cameraType,
      'cameraAngle': instance.cameraAngle,
      'dialogue': instance.dialogue,
      'voice': instance.voice,
      'lipSync': instance.lipSync,
      'characterName': instance.characterName,
      'characterId': instance.characterId,
      'emotion': instance.emotion,
      'voiceName': instance.voiceName,
      'transition': instance.transition,
      'audioDesign': instance.audioDesign,
      'priority': instance.priority,
      'negativePrompt': instance.negativePrompt,
      'reviewStatus': instance.reviewStatus,
      'reviewComment': instance.reviewComment,
    };
