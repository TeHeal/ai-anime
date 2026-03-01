import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:anime_ui/pub/utils/json_id.dart';
import 'scene.dart';

part 'episode.freezed.dart';
part 'episode.g.dart';

@freezed
abstract class Episode with _$Episode {
  const factory Episode({
    @JsonKey(fromJson: nullableIdFromJson) String? id,
    @JsonKey(fromJson: nullableIdFromJson) String? projectId,
    @Default('') String title,
    @Default(0) int sortIndex,
    @Default('') String summary,
    @Default('not_started') String status,
    @Default(0) int currentStep,
    DateTime? lastActiveAt,
    @Default([]) List<Scene> scenes,
  }) = _Episode;

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
}
