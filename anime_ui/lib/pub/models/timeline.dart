import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline.freezed.dart';
part 'timeline.g.dart';

@freezed
abstract class TrackItem with _$TrackItem {
  const factory TrackItem({
    required String id,
    String? sourceId,
    @Default('') String sourceUrl,
    @Default('') String label,
    @Default(0) double startAt,
    @Default(0) double duration,
    @Default(1.0) double volume,
    @Default(0) double trim,
  }) = _TrackItem;

  factory TrackItem.fromJson(Map<String, dynamic> json) =>
      _$TrackItemFromJson(json);
}

@freezed
abstract class Track with _$Track {
  const factory Track({
    required String id,
    required String type,
    @Default('') String name,
    @Default(false) bool muted,
    @Default([]) List<TrackItem> items,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}

@freezed
abstract class ProjectTimeline with _$ProjectTimeline {
  const factory ProjectTimeline({
    String? id,
    String? projectId,
    @Default(0) double duration,
    @Default([]) List<Track> tracks,
  }) = _ProjectTimeline;

  factory ProjectTimeline.fromJson(Map<String, dynamic> json) =>
      _$ProjectTimelineFromJson(json);
}
