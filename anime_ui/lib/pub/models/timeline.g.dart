// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackItem _$TrackItemFromJson(Map<String, dynamic> json) => _TrackItem(
  id: json['id'] as String,
  sourceId: json['sourceId'] as String?,
  sourceUrl: json['sourceUrl'] as String? ?? '',
  label: json['label'] as String? ?? '',
  startAt: (json['startAt'] as num?)?.toDouble() ?? 0,
  duration: (json['duration'] as num?)?.toDouble() ?? 0,
  volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
  trim: (json['trim'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$TrackItemToJson(_TrackItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceId': instance.sourceId,
      'sourceUrl': instance.sourceUrl,
      'label': instance.label,
      'startAt': instance.startAt,
      'duration': instance.duration,
      'volume': instance.volume,
      'trim': instance.trim,
    };

_Track _$TrackFromJson(Map<String, dynamic> json) => _Track(
  id: json['id'] as String,
  type: json['type'] as String,
  name: json['name'] as String? ?? '',
  muted: json['muted'] as bool? ?? false,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => TrackItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TrackToJson(_Track instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
  'muted': instance.muted,
  'items': instance.items,
};

_ProjectTimeline _$ProjectTimelineFromJson(Map<String, dynamic> json) =>
    _ProjectTimeline(
      id: json['id'] as String?,
      projectId: json['projectId'] as String?,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      tracks:
          (json['tracks'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProjectTimelineToJson(_ProjectTimeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'duration': instance.duration,
      'tracks': instance.tracks,
    };
