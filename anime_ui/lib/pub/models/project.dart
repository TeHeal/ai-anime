import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
abstract class ProjectConfig with _$ProjectConfig {
  const factory ProjectConfig({
    @Default('1:1') String ratio,
    @Default('') String imageModel,
    @Default('') String videoModel,
    @Default('无') String narration,
    @Default('5') String shotDuration,
    @Default('') String videoStyle,
    @Default('') String lipSyncMode,
  }) = _ProjectConfig;

  factory ProjectConfig.fromJson(Map<String, dynamic> json) =>
      _$ProjectConfigFromJson(json);
}

@freezed
abstract class Project with _$Project {
  const factory Project({
    int? id,
    @Default('Untitled') String name,
    @Default('') String story,
    @Default('full_script') String storyMode,
    ProjectConfig? config,
    @Default(true) bool mirrorMode,
    @Default([]) List<int> segmentIds,
    DateTime? updatedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
