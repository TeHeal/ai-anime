// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Music _$MusicFromJson(Map<String, dynamic> json) => _Music(
  id: json['id'] as String?,
  projectId: json['projectId'] as String?,
  title: json['title'] as String? ?? '',
  prompt: json['prompt'] as String? ?? '',
  provider: json['provider'] as String? ?? '',
  model: json['model'] as String? ?? '',
  audioUrl: json['audioUrl'] as String? ?? '',
  duration: (json['duration'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String? ?? 'pending',
  taskId: json['taskId'] as String? ?? '',
);

Map<String, dynamic> _$MusicToJson(_Music instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'title': instance.title,
  'prompt': instance.prompt,
  'provider': instance.provider,
  'model': instance.model,
  'audioUrl': instance.audioUrl,
  'duration': instance.duration,
  'status': instance.status,
  'taskId': instance.taskId,
};
