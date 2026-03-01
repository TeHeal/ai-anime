// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScriptSegment _$ScriptSegmentFromJson(Map<String, dynamic> json) =>
    _ScriptSegment(
      id: nullableIdFromJson(json['id']),
      projectId: nullableIdFromJson(json['projectId']),
      sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
      content: json['content'] as String? ?? '',
    );

Map<String, dynamic> _$ScriptSegmentToJson(_ScriptSegment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'sortIndex': instance.sortIndex,
      'content': instance.content,
    };
