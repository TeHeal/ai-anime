// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExportRecord _$ExportRecordFromJson(Map<String, dynamic> json) =>
    _ExportRecord(
      id: (json['id'] as num?)?.toInt(),
      projectId: (json['projectId'] as num?)?.toInt(),
      format: json['format'] as String? ?? 'mp4',
      resolution: json['resolution'] as String? ?? '1080p',
      status: json['status'] as String? ?? 'pending',
      outputUrl: json['outputUrl'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      taskId: json['taskId'] as String? ?? '',
      error: json['error'] as String?,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ExportRecordToJson(_ExportRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'format': instance.format,
      'resolution': instance.resolution,
      'status': instance.status,
      'outputUrl': instance.outputUrl,
      'fileSize': instance.fileSize,
      'taskId': instance.taskId,
      'error': instance.error,
      'progress': instance.progress,
    };
