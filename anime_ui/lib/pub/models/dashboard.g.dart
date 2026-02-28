// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Dashboard _$DashboardFromJson(Map<String, dynamic> json) => _Dashboard(
  totalEpisodes: (json['totalEpisodes'] as num?)?.toInt() ?? 0,
  statusCounts:
      (json['statusCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  phaseCounts:
      (json['phaseCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, StepCount.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  assetSummary: json['assetSummary'] == null
      ? null
      : AssetSummary.fromJson(json['assetSummary'] as Map<String, dynamic>),
  reviewSummary: json['reviewSummary'] == null
      ? null
      : ReviewSummary.fromJson(json['reviewSummary'] as Map<String, dynamic>),
  episodes:
      (json['episodes'] as List<dynamic>?)
          ?.map((e) => DashboardEpisode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DashboardToJson(_Dashboard instance) =>
    <String, dynamic>{
      'totalEpisodes': instance.totalEpisodes,
      'statusCounts': instance.statusCounts,
      'phaseCounts': instance.phaseCounts,
      'assetSummary': instance.assetSummary,
      'reviewSummary': instance.reviewSummary,
      'episodes': instance.episodes,
    };

_StepCount _$StepCountFromJson(Map<String, dynamic> json) => _StepCount(
  done: (json['done'] as num?)?.toInt() ?? 0,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StepCountToJson(_StepCount instance) =>
    <String, dynamic>{'done': instance.done, 'total': instance.total};

_AssetSummary _$AssetSummaryFromJson(Map<String, dynamic> json) =>
    _AssetSummary(
      charactersTotal: (json['charactersTotal'] as num?)?.toInt() ?? 0,
      charactersConfirmed: (json['charactersConfirmed'] as num?)?.toInt() ?? 0,
      locationsTotal: (json['locationsTotal'] as num?)?.toInt() ?? 0,
      locationsConfirmed: (json['locationsConfirmed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AssetSummaryToJson(_AssetSummary instance) =>
    <String, dynamic>{
      'charactersTotal': instance.charactersTotal,
      'charactersConfirmed': instance.charactersConfirmed,
      'locationsTotal': instance.locationsTotal,
      'locationsConfirmed': instance.locationsConfirmed,
    };

_ReviewSummary _$ReviewSummaryFromJson(Map<String, dynamic> json) =>
    _ReviewSummary(
      totalShots: (json['totalShots'] as num?)?.toInt() ?? 0,
      pendingReview: (json['pendingReview'] as num?)?.toInt() ?? 0,
      approved: (json['approved'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReviewSummaryToJson(_ReviewSummary instance) =>
    <String, dynamic>{
      'totalShots': instance.totalShots,
      'pendingReview': instance.pendingReview,
      'approved': instance.approved,
      'rejected': instance.rejected,
    };

_DashboardEpisode _$DashboardEpisodeFromJson(Map<String, dynamic> json) =>
    _DashboardEpisode(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String? ?? '',
      sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      status: json['status'] as String? ?? 'not_started',
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      currentPhase: json['currentPhase'] as String? ?? 'story',
      sceneCount: (json['sceneCount'] as num?)?.toInt() ?? 0,
      characterNames:
          (json['characterNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      progress: json['progress'] == null
          ? null
          : EpisodeProgress.fromJson(json['progress'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardEpisodeToJson(_DashboardEpisode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sortIndex': instance.sortIndex,
      'summary': instance.summary,
      'status': instance.status,
      'currentStep': instance.currentStep,
      'currentPhase': instance.currentPhase,
      'sceneCount': instance.sceneCount,
      'characterNames': instance.characterNames,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'progress': instance.progress,
    };
