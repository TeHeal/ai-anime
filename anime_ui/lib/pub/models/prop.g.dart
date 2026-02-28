// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Prop _$PropFromJson(Map<String, dynamic> json) => _Prop(
  id: _nullableIdFromJson(json['id']),
  projectId: _nullableIdFromJson(json['projectId']),
  name: json['name'] as String? ?? '',
  appearance: json['appearance'] as String? ?? '',
  isKeyProp: json['isKeyProp'] as bool? ?? false,
  style: json['style'] as String? ?? '',
  styleOverride: json['styleOverride'] as bool? ?? false,
  referenceImagesJson: json['referenceImagesJson'] as String? ?? '',
  imageUrl: json['imageUrl'] as String? ?? '',
  usedByJson: json['usedByJson'] as String? ?? '',
  scenesJson: json['scenesJson'] as String? ?? '',
  status: json['status'] as String? ?? 'draft',
  source: json['source'] as String? ?? 'manual',
);

Map<String, dynamic> _$PropToJson(_Prop instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'name': instance.name,
  'appearance': instance.appearance,
  'isKeyProp': instance.isKeyProp,
  'style': instance.style,
  'styleOverride': instance.styleOverride,
  'referenceImagesJson': instance.referenceImagesJson,
  'imageUrl': instance.imageUrl,
  'usedByJson': instance.usedByJson,
  'scenesJson': instance.scenesJson,
  'status': instance.status,
  'source': instance.source,
};
