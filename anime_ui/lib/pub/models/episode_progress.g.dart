// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EpisodeProgress _$EpisodeProgressFromJson(Map<String, dynamic> json) =>
    _EpisodeProgress(
      id: (json['id'] as num?)?.toInt(),
      episodeId: (json['episodeId'] as num?)?.toInt() ?? 0,
      projectId: (json['projectId'] as num?)?.toInt() ?? 0,
      storyDone: json['storyDone'] as bool? ?? false,
      assetsDone: json['assetsDone'] as bool? ?? false,
      scriptDone: json['scriptDone'] as bool? ?? false,
      storyboardDone: json['storyboardDone'] as bool? ?? false,
      shotsDone: json['shotsDone'] as bool? ?? false,
      episodeDone: json['episodeDone'] as bool? ?? false,
      storyPct: (json['storyPct'] as num?)?.toInt() ?? 0,
      assetsPct: (json['assetsPct'] as num?)?.toInt() ?? 0,
      scriptPct: (json['scriptPct'] as num?)?.toInt() ?? 0,
      storyboardPct: (json['storyboardPct'] as num?)?.toInt() ?? 0,
      shotsPct: (json['shotsPct'] as num?)?.toInt() ?? 0,
      episodePct: (json['episodePct'] as num?)?.toInt() ?? 0,
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      currentPhase: json['currentPhase'] as String? ?? 'story',
      overallPct: (json['overallPct'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EpisodeProgressToJson(_EpisodeProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'episodeId': instance.episodeId,
      'projectId': instance.projectId,
      'storyDone': instance.storyDone,
      'assetsDone': instance.assetsDone,
      'scriptDone': instance.scriptDone,
      'storyboardDone': instance.storyboardDone,
      'shotsDone': instance.shotsDone,
      'episodeDone': instance.episodeDone,
      'storyPct': instance.storyPct,
      'assetsPct': instance.assetsPct,
      'scriptPct': instance.scriptPct,
      'storyboardPct': instance.storyboardPct,
      'shotsPct': instance.shotsPct,
      'episodePct': instance.episodePct,
      'currentStep': instance.currentStep,
      'currentPhase': instance.currentPhase,
      'overallPct': instance.overallPct,
    };
