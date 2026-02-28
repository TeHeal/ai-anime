import 'package:freezed_annotation/freezed_annotation.dart';

import 'episode_progress.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

@freezed
abstract class Dashboard with _$Dashboard {
  const factory Dashboard({
    @Default(0) int totalEpisodes,
    @Default({}) Map<String, int> statusCounts,
    @Default({}) Map<String, StepCount> phaseCounts,
    AssetSummary? assetSummary,
    ReviewSummary? reviewSummary,
    @Default([]) List<DashboardEpisode> episodes,
  }) = _Dashboard;

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);
}

@freezed
abstract class StepCount with _$StepCount {
  const factory StepCount({
    @Default(0) int done,
    @Default(0) int total,
  }) = _StepCount;

  factory StepCount.fromJson(Map<String, dynamic> json) =>
      _$StepCountFromJson(json);
}

@freezed
abstract class AssetSummary with _$AssetSummary {
  const factory AssetSummary({
    @Default(0) int charactersTotal,
    @Default(0) int charactersConfirmed,
    @Default(0) int locationsTotal,
    @Default(0) int locationsConfirmed,
  }) = _AssetSummary;

  factory AssetSummary.fromJson(Map<String, dynamic> json) =>
      _$AssetSummaryFromJson(json);
}

@freezed
abstract class ReviewSummary with _$ReviewSummary {
  const factory ReviewSummary({
    @Default(0) int totalShots,
    @Default(0) int pendingReview,
    @Default(0) int approved,
    @Default(0) int rejected,
  }) = _ReviewSummary;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) =>
      _$ReviewSummaryFromJson(json);
}

@freezed
abstract class DashboardEpisode with _$DashboardEpisode {
  const factory DashboardEpisode({
    String? id,
    @Default('') String title,
    @Default(0) int sortIndex,
    @Default('') String summary,
    @Default('not_started') String status,
    @Default(0) int currentStep,
    @Default('story') String currentPhase,
    @Default(0) int sceneCount,
    @Default([]) List<String> characterNames,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    EpisodeProgress? progress,
  }) = _DashboardEpisode;

  factory DashboardEpisode.fromJson(Map<String, dynamic> json) =>
      _$DashboardEpisodeFromJson(json);
}
