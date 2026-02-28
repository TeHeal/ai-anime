import 'package:freezed_annotation/freezed_annotation.dart';

part 'episode_progress.freezed.dart';
part 'episode_progress.g.dart';

@freezed
abstract class EpisodeProgress with _$EpisodeProgress {
  const factory EpisodeProgress({
    int? id,
    @Default(0) int episodeId,
    @Default(0) int projectId,

    @Default(false) bool storyDone,
    @Default(false) bool assetsDone,
    @Default(false) bool scriptDone,
    @Default(false) bool storyboardDone,
    @Default(false) bool shotsDone,
    @Default(false) bool episodeDone,

    @Default(0) int storyPct,
    @Default(0) int assetsPct,
    @Default(0) int scriptPct,
    @Default(0) int storyboardPct,
    @Default(0) int shotsPct,
    @Default(0) int episodePct,

    @Default(0) int currentStep,
    @Default('story') String currentPhase,
    @Default(0) int overallPct,
  }) = _EpisodeProgress;

  factory EpisodeProgress.fromJson(Map<String, dynamic> json) =>
      _$EpisodeProgressFromJson(json);
}
