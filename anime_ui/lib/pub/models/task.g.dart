// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  type: json['type'] as String,
  status: json['status'] as String,
  provider: json['provider'] as String? ?? '',
  model: json['model'] as String? ?? '',
  error: json['error'] as String?,
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  result: json['result'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'type': instance.type,
  'status': instance.status,
  'provider': instance.provider,
  'model': instance.model,
  'error': instance.error,
  'progress': instance.progress,
  'result': instance.result,
};
