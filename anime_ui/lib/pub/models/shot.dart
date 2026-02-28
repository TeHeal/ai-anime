import 'package:freezed_annotation/freezed_annotation.dart';

part 'shot.freezed.dart';
part 'shot.g.dart';

@freezed
abstract class StoryboardShot with _$StoryboardShot {
  const StoryboardShot._();

  const factory StoryboardShot({
    String? id,
    String? projectId,
    String? segmentId,
    String? sceneId,
    @Default(0) int sortIndex,
    @Default('') String prompt,
    @Default('') String stylePrompt,
    @Default('') String imageUrl,
    @Default('') String videoUrl,
    @Default('') String taskId,
    @Default('pending') String status,
    @Default(5) int duration,
    String? cameraType,
    String? cameraAngle,
    String? dialogue,
    String? voice,
    @Default('口型同步') String lipSync,
    String? characterName,
    String? characterId,
    String? emotion,
    String? voiceName,
    String? transition,
    String? audioDesign,
    String? priority,
    String? negativePrompt,
    @Default('pending') String reviewStatus,
    String? reviewComment,
  }) = _StoryboardShot;

  factory StoryboardShot.fromJson(Map<String, dynamic> json) =>
      _$StoryboardShotFromJson(json);

  /// 与另一 shot 是否属于同一场景（用于侧边栏联动）
  bool isSameSceneAs(StoryboardShot? other) =>
      other != null && sceneId != null && sceneId == other.sceneId;

  bool get isGenerating => status == 'generating';
  bool get hasImage => imageUrl.isNotEmpty;
  bool get hasVideo => videoUrl.isNotEmpty;
}
