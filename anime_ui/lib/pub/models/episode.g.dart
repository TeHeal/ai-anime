// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Episode _$EpisodeFromJson(Map<String, dynamic> json) => _Episode(
  id: (json['id'] as num?)?.toInt(),
  projectId: (json['projectId'] as num?)?.toInt(),
  title: json['title'] as String? ?? '',
  sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
  summary: json['summary'] as String? ?? '',
  status: json['status'] as String? ?? 'not_started',
  currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
  scenes:
      (json['scenes'] as List<dynamic>?)
          ?.map((e) => Scene.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$EpisodeToJson(_Episode instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'title': instance.title,
  'sortIndex': instance.sortIndex,
  'summary': instance.summary,
  'status': instance.status,
  'currentStep': instance.currentStep,
  'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
  'scenes': instance.scenes,
};
