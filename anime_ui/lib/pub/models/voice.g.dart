// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Voice _$VoiceFromJson(Map<String, dynamic> json) => _Voice(
  id: json['id'] as String?,
  name: json['name'] as String? ?? '',
  gender: json['gender'] as String? ?? '',
  voiceId: json['voiceId'] as String? ?? '',
  provider: json['provider'] as String? ?? '',
  audioUrl: json['audioUrl'] as String? ?? '',
  status: json['status'] as String? ?? 'pending',
  taskId: json['taskId'] as String? ?? '',
  error: json['error'] as String?,
  shared: json['shared'] as bool? ?? false,
);

Map<String, dynamic> _$VoiceToJson(_Voice instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'gender': instance.gender,
  'voiceId': instance.voiceId,
  'provider': instance.provider,
  'audioUrl': instance.audioUrl,
  'status': instance.status,
  'taskId': instance.taskId,
  'error': instance.error,
  'shared': instance.shared,
};
