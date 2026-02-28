// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Location _$LocationFromJson(Map<String, dynamic> json) => _Location(
  id: _nullableIdFromJson(json['id']),
  projectId: _nullableIdFromJson(json['projectId']),
  name: json['name'] as String? ?? '',
  time: json['time'] as String? ?? '',
  interiorExterior: json['interiorExterior'] as String? ?? '',
  atmosphere: json['atmosphere'] as String? ?? '',
  colorTone: json['colorTone'] as String? ?? '',
  layout: json['layout'] as String? ?? '',
  style: json['style'] as String? ?? '',
  styleOverride: json['styleOverride'] as bool? ?? false,
  styleNote: json['styleNote'] as String? ?? '',
  imageUrl: json['imageUrl'] as String? ?? '',
  referenceImagesJson: json['referenceImagesJson'] as String? ?? '',
  taskId: json['taskId'] as String? ?? '',
  imageStatus: json['imageStatus'] as String? ?? 'none',
  status: json['status'] as String? ?? 'draft',
  source: json['source'] as String? ?? 'manual',
);

Map<String, dynamic> _$LocationToJson(_Location instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'name': instance.name,
  'time': instance.time,
  'interiorExterior': instance.interiorExterior,
  'atmosphere': instance.atmosphere,
  'colorTone': instance.colorTone,
  'layout': instance.layout,
  'style': instance.style,
  'styleOverride': instance.styleOverride,
  'styleNote': instance.styleNote,
  'imageUrl': instance.imageUrl,
  'referenceImagesJson': instance.referenceImagesJson,
  'taskId': instance.taskId,
  'imageStatus': instance.imageStatus,
  'status': instance.status,
  'source': instance.source,
};
