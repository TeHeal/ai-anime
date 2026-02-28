// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voiceover.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Voiceover _$VoiceoverFromJson(Map<String, dynamic> json) => _Voiceover(
  id: (json['id'] as num?)?.toInt(),
  projectId: (json['projectId'] as num?)?.toInt(),
  shotId: (json['shotId'] as num?)?.toInt(),
  text: json['text'] as String? ?? '',
  voiceId: json['voiceId'] as String? ?? '',
  voiceName: json['voiceName'] as String? ?? '',
  emotion: json['emotion'] as String? ?? '',
  provider: json['provider'] as String? ?? '',
  model: json['model'] as String? ?? '',
  audioUrl: json['audioUrl'] as String? ?? '',
  duration: (json['duration'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String? ?? 'pending',
  taskId: json['taskId'] as String? ?? '',
);

Map<String, dynamic> _$VoiceoverToJson(_Voiceover instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'shotId': instance.shotId,
      'text': instance.text,
      'voiceId': instance.voiceId,
      'voiceName': instance.voiceName,
      'emotion': instance.emotion,
      'provider': instance.provider,
      'model': instance.model,
      'audioUrl': instance.audioUrl,
      'duration': instance.duration,
      'status': instance.status,
      'taskId': instance.taskId,
    };
