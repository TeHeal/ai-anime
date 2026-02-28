// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectConfig _$ProjectConfigFromJson(Map<String, dynamic> json) =>
    _ProjectConfig(
      ratio: json['ratio'] as String? ?? '1:1',
      imageModel: json['imageModel'] as String? ?? '',
      videoModel: json['videoModel'] as String? ?? '',
      narration: json['narration'] as String? ?? '无',
      shotDuration: json['shotDuration'] as String? ?? '5',
      videoStyle: json['videoStyle'] as String? ?? '',
      lipSyncMode: json['lipSyncMode'] as String? ?? '',
    );

Map<String, dynamic> _$ProjectConfigToJson(_ProjectConfig instance) =>
    <String, dynamic>{
      'ratio': instance.ratio,
      'imageModel': instance.imageModel,
      'videoModel': instance.videoModel,
      'narration': instance.narration,
      'shotDuration': instance.shotDuration,
      'videoStyle': instance.videoStyle,
      'lipSyncMode': instance.lipSyncMode,
    };

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String? ?? 'Untitled',
  story: json['story'] as String? ?? '',
  storyMode: json['storyMode'] as String? ?? 'full_script',
  config: json['config'] == null
      ? null
      : ProjectConfig.fromJson(json['config'] as Map<String, dynamic>),
  mirrorMode: json['mirrorMode'] as bool? ?? true,
  segmentIds:
      (json['segmentIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'story': instance.story,
  'storyMode': instance.storyMode,
  'config': instance.config,
  'mirrorMode': instance.mirrorMode,
  'segmentIds': instance.segmentIds,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
